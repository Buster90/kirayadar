import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models.dart';
import 'firebase_service.dart';

/// Data returned by [FirestoreService.loadAll].
class FirestoreData {
  final List<RentalUnit> units;
  final List<LedgerEntry> ledger;
  final List<Expense> expenses;
  final Map<String, dynamic> settings;
  const FirestoreData({
    required this.units,
    required this.ledger,
    required this.expenses,
    required this.settings,
  });
}

/// Firestore access for Kirayadar.
///
/// Data model (see README for the full description):
///   landlords/{landlordId}/properties/{propertyId}
///     └─ ledger/{ledgerEntryId}            (subcollection per property)
///   landlords/{landlordId}/expenses/{expenseId}
///   landlords/{landlordId}/settings/profile (single document)
///
/// Landlord ID: the signed-in FirebaseAuth UID when available, otherwise a
/// stable local ID stored in SharedPreferences. Every call is wrapped in
/// try/catch with a timeout and returns false / null on failure — Firestore
/// errors must never throw into the UI. The store treats local
/// SharedPreferences as the source of truth when Firebase is unavailable.
class FirestoreService {
  static const String _landlordIdKey = 'landlordId';
  static const String defaultLocalLandlordId = 'local-landlord-muhammad-asif-khan';
  static const Duration _timeout = Duration(seconds: 10);

  bool get available => FirebaseService.initialized;

  /// Stable landlord ID. Never throws.
  Future<String> landlordId() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null && uid.isNotEmpty) return uid;
    } catch (_) {
      // Auth unavailable (e.g. Firebase not configured) — fall through.
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_landlordIdKey);
      if (stored != null && stored.isNotEmpty) return stored;
      await prefs.setString(_landlordIdKey, defaultLocalLandlordId);
      return defaultLocalLandlordId;
    } catch (_) {
      return defaultLocalLandlordId;
    }
  }

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  Future<DocumentReference<Map<String, dynamic>>> _landlordDoc() async {
    final id = await landlordId();
    return _db.collection('landlords').doc(id);
  }

  Future<CollectionReference<Map<String, dynamic>>> _propertiesCol() async {
    final landlord = await _landlordDoc();
    return landlord.collection('properties');
  }

  Future<CollectionReference<Map<String, dynamic>>> _expensesCol() async {
    final landlord = await _landlordDoc();
    return landlord.collection('expenses');
  }

  /// Converts a model JSON map for Firestore: `updatedAt` (ms int) becomes
  /// a Firestore Timestamp so it can be compared / ordered server-side.
  Map<String, dynamic> _toFirestore(Map<String, dynamic> json) {
    final map = Map<String, dynamic>.from(json);
    final updatedAt = map['updatedAt'];
    if (updatedAt is int) {
      map['updatedAt'] = Timestamp.fromMillisecondsSinceEpoch(updatedAt);
    }
    map['updatedAtMs'] = updatedAt is int ? updatedAt : null;
    return map;
  }

  /// Parses an `updatedAt` coming back from Firestore: a Timestamp, an
  /// int (ms), an ISO string, or null. Falls back to the `updatedAtMs`
  /// mirror field written by [_toFirestore].
  static DateTime? parseFirestoreDate(Map<String, dynamic> json) {
    final v = json['updatedAt'];
    if (v is Timestamp) return v.toDate();
    final parsed = parseUpdatedAt(v);
    if (parsed != null) return parsed;
    final ms = json['updatedAtMs'];
    if (ms is int) return DateTime.fromMillisecondsSinceEpoch(ms);
    if (ms is num) return DateTime.fromMillisecondsSinceEpoch(ms.toInt());
    return null;
  }

  RentalUnit _unitFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = Map<String, dynamic>.from(doc.data() ?? {});
    data['id'] = doc.id;
    final unit = RentalUnit.fromJson(data);
    unit.updatedAt = parseFirestoreDate(data);
    return unit;
  }

  LedgerEntry _ledgerFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = Map<String, dynamic>.from(doc.data() ?? {});
    data['id'] = doc.id;
    final entry = LedgerEntry.fromJson(data);
    entry.updatedAt = parseFirestoreDate(data);
    return entry;
  }

  Expense _expenseFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = Map<String, dynamic>.from(doc.data() ?? {});
    data['id'] = doc.id;
    final expense = Expense.fromJson(data);
    expense.updatedAt = parseFirestoreDate(data);
    return expense;
  }

  Future<bool> saveProperty(RentalUnit unit, {List<LedgerEntry>? ledger}) async {
    if (!available) return false;
    try {
      final props = await _propertiesCol();
      final data = _toFirestore(unit.toJson());
      await props.doc(unit.id).set(data, SetOptions(merge: true)).timeout(_timeout);
      if (ledger != null) {
        final ledgerCol = props.doc(unit.id).collection('ledger');
        for (final entry in ledger) {
          await ledgerCol.doc(entry.id).set(_toFirestore(entry.toJson()), SetOptions(merge: true)).timeout(_timeout);
        }
      }
      return true;
    } catch (e) {
      debugPrint('Firestore saveProperty failed: $e');
      return false;
    }
  }

  Future<bool> deleteProperty(String propertyId) async {
    if (!available) return false;
    try {
      final props = await _propertiesCol();
      final ledgerCol = props.doc(propertyId).collection('ledger');
      final ledgerDocs = await ledgerCol.get().timeout(_timeout);
      final batch = _db.batch();
      for (final doc in ledgerDocs.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(props.doc(propertyId));
      await batch.commit().timeout(_timeout);
      return true;
    } catch (e) {
      debugPrint('Firestore deleteProperty failed: $e');
      return false;
    }
  }

  Future<bool> saveLedgerEntry(LedgerEntry entry) async {
    if (!available) return false;
    try {
      final props = await _propertiesCol();
      await props
          .doc(entry.unitId)
          .collection('ledger')
          .doc(entry.id)
          .set(_toFirestore(entry.toJson()), SetOptions(merge: true))
          .timeout(_timeout);
      return true;
    } catch (e) {
      debugPrint('Firestore saveLedgerEntry failed: $e');
      return false;
    }
  }

  Future<bool> saveExpense(Expense expense) async {
    if (!available) return false;
    try {
      final col = await _expensesCol();
      await col.doc(expense.id).set(_toFirestore(expense.toJson()), SetOptions(merge: true)).timeout(_timeout);
      return true;
    } catch (e) {
      debugPrint('Firestore saveExpense failed: $e');
      return false;
    }
  }

  Future<bool> deleteExpense(String expenseId) async {
    if (!available) return false;
    try {
      final col = await _expensesCol();
      await col.doc(expenseId).delete().timeout(_timeout);
      return true;
    } catch (e) {
      debugPrint('Firestore deleteExpense failed: $e');
      return false;
    }
  }

  Future<bool> saveSettings({
    required bool whatsappReminders,
    required int graceDays,
    required String language,
  }) async {
    if (!available) return false;
    try {
      final landlord = await _landlordDoc();
      await landlord.collection('settings').doc('profile').set({
        'whatsappReminders': whatsappReminders,
        'graceDays': graceDays,
        'language': language,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedAtMs': DateTime.now().millisecondsSinceEpoch,
      }, SetOptions(merge: true)).timeout(_timeout);
      return true;
    } catch (e) {
      debugPrint('Firestore saveSettings failed: $e');
      return false;
    }
  }

  /// Writes the whole local store to Firestore. Used after a local-first
  /// mutation and when first seeding a fresh Firestore landlord document.
  /// Returns true only if every collection write succeeded.
  Future<bool> saveAll({
    required List<RentalUnit> units,
    required List<LedgerEntry> ledger,
    required List<Expense> expenses,
    required bool whatsappReminders,
    required int graceDays,
    required String language,
  }) async {
    if (!available) return false;
    try {
      final ledgerByUnit = <String, List<LedgerEntry>>{};
      for (final entry in ledger) {
        ledgerByUnit.putIfAbsent(entry.unitId, () => []).add(entry);
      }
      var ok = true;
      for (final unit in units) {
        final saved = await saveProperty(unit, ledger: ledgerByUnit[unit.id] ?? const []);
        if (!saved) ok = false;
      }
      // Ledger entries whose unit is not in the list (defensive).
      for (final entry in ledger) {
        if (!units.any((u) => u.id == entry.unitId)) {
          final saved = await saveLedgerEntry(entry);
          if (!saved) ok = false;
        }
      }
      for (final expense in expenses) {
        final saved = await saveExpense(expense);
        if (!saved) ok = false;
      }
      final settingsOk = await saveSettings(
        whatsappReminders: whatsappReminders,
        graceDays: graceDays,
        language: language,
      );
      if (!settingsOk) ok = false;
      return ok;
    } catch (e) {
      debugPrint('Firestore saveAll failed: $e');
      return false;
    }
  }

  /// Reads the whole landlord document tree. Returns null on any failure
  /// (caller keeps local data). An empty-but-successful read returns
  /// empty lists and an empty settings map, so the caller can tell
  /// "Firestore has nothing yet" apart from "Firestore failed".
  Future<FirestoreData?> loadAll() async {
    if (!available) return null;
    try {
      final props = await _propertiesCol();
      final expensesCol = await _expensesCol();
      final landlord = await _landlordDoc();

      final propsSnap = await props.get().timeout(_timeout);
      final units = <RentalUnit>[];
      final ledger = <LedgerEntry>[];
      for (final doc in propsSnap.docs) {
        units.add(_unitFromDoc(doc));
        final ledgerSnap = await props.doc(doc.id).collection('ledger').get().timeout(_timeout);
        ledger.addAll(ledgerSnap.docs.map(_ledgerFromDoc));
      }
      final expensesSnap = await expensesCol.get().timeout(_timeout);
      final expenses = expensesSnap.docs.map(_expenseFromDoc).toList();
      final settingsSnap = await landlord.collection('settings').doc('profile').get().timeout(_timeout);
      final settings = settingsSnap.data() ?? <String, dynamic>{};
      return FirestoreData(units: units, ledger: ledger, expenses: expenses, settings: settings);
    } catch (e) {
      debugPrint('Firestore loadAll failed: $e');
      return null;
    }
  }
}
