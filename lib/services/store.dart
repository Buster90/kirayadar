import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/seed_data.dart';
import '../models.dart';
import 'firebase_service.dart';
import 'firestore_service.dart';

/// Where the data currently lives / what the last sync did.
enum SyncStatus { localOnly, syncing, synced, error }

class AppStore extends ChangeNotifier {
  List<RentalUnit> units = [];
  List<LedgerEntry> ledger = [];
  List<Expense> expenses = [];
  bool loggedIn = false;
  bool onboardingDone = false;
  bool whatsappReminders = true;
  int graceDays = 5;
  String language = 'Bilingual';
  bool _loaded = false;

  /// Offline-first sync state, shown in the Dashboard / Profile UI.
  SyncStatus syncStatus = SyncStatus.localOnly;
  DateTime? lastSyncedAt;
  String? syncError;

  final FirestoreService _firestore = FirestoreService();

  int get totalMonthly => units.fold(0, (s, u) => s + u.rent);
  int get collected => units.where((u) => u.status == UnitStatus.paid).fold(0, (s, u) => s + u.rent);
  int get pending => totalMonthly - collected;
  int get paidCount => units.where((u) => u.status == UnitStatus.paid).length;
  int get overdueCount => units.where((u) => u.status == UnitStatus.overdue).length;
  int get totalExpenses => expenses.fold(0, (s, e) => s + e.amount.abs());

  /// Human-readable sync label for the UI, e.g. "Saved locally" or
  /// "Saved to Firebase • last synced 20:41".
  String get syncLabel {
    switch (syncStatus) {
      case SyncStatus.localOnly:
        return 'Saved locally';
      case SyncStatus.syncing:
        return 'Syncing…';
      case SyncStatus.synced:
        if (lastSyncedAt == null) return 'Saved to Firebase';
        final h = lastSyncedAt!.hour.toString().padLeft(2, '0');
        final m = lastSyncedAt!.minute.toString().padLeft(2, '0');
        return 'Saved to Firebase • last synced $h:$m';
      case SyncStatus.error:
        return 'Saved locally • sync failed';
    }
  }

  RentalUnit? unitById(String id) {
    try { return units.firstWhere((u) => u.id == id); } catch (_) { return null; }
  }

  List<LedgerEntry> ledgerFor(String unitId) => ledger.where((e) => e.unitId == unitId).toList();

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    final prefs = await SharedPreferences.getInstance();
    loggedIn = prefs.getBool('loggedIn') ?? false;
    onboardingDone = prefs.getBool('onboardingDone') ?? false;
    whatsappReminders = prefs.getBool('whatsappReminders') ?? true;
    graceDays = prefs.getInt('graceDays') ?? 5;
    language = prefs.getString('language') ?? 'Bilingual';
    final u = prefs.getString('units');
    final l = prefs.getString('ledger');
    final e = prefs.getString('expenses');
    if (u == null) {
      units = seedUnits(); ledger = seedLedger(); expenses = seedExpenses();
      await save();
    } else {
      units = (jsonDecode(u) as List).map((x) => RentalUnit.fromJson(x as Map<String, dynamic>)).toList();
      ledger = l == null ? seedLedger() : (jsonDecode(l) as List).map((x) => LedgerEntry.fromJson(x as Map<String, dynamic>)).toList();
      expenses = e == null ? seedExpenses() : (jsonDecode(e) as List).map((x) => Expense.fromJson(x as Map<String, dynamic>)).toList();
    }
    syncStatus = FirebaseService.initialized ? SyncStatus.syncing : SyncStatus.localOnly;
    notifyListeners();
    // Local data is shown instantly; Firestore sync runs in the background
    // and merges on top of it (never blocks the UI).
    unawaited(_syncFromFirestore());
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('units', jsonEncode(units.map((u) => u.toJson()).toList()));
    await prefs.setString('ledger', jsonEncode(ledger.map((e) => e.toJson()).toList()));
    await prefs.setString('expenses', jsonEncode(expenses.map((e) => e.toJson()).toList()));
    await prefs.setBool('loggedIn', loggedIn);
    await prefs.setBool('onboardingDone', onboardingDone);
    await prefs.setBool('whatsappReminders', whatsappReminders);
    await prefs.setInt('graceDays', graceDays);
    await prefs.setString('language', language);
  }

  /// Fire-and-forget push of the current local state to Firestore.
  /// Local data is always saved first (see the mutation methods below);
  /// a Firestore failure only changes [syncStatus], never loses data.
  Future<void> _syncToFirestore() async {
    if (!FirebaseService.initialized) {
      syncStatus = SyncStatus.localOnly;
      notifyListeners();
      return;
    }
    syncStatus = SyncStatus.syncing;
    notifyListeners();
    try {
      final ok = await _firestore.saveAll(
        units: units,
        ledger: ledger,
        expenses: expenses,
        whatsappReminders: whatsappReminders,
        graceDays: graceDays,
        language: language,
      ).timeout(const Duration(seconds: 30));
      if (ok) {
        syncStatus = SyncStatus.synced;
        lastSyncedAt = DateTime.now();
        syncError = null;
      } else {
        syncStatus = SyncStatus.error;
        syncError = 'Some Firestore writes failed';
      }
    } catch (e) {
      syncStatus = SyncStatus.error;
      syncError = '$e';
    }
    notifyListeners();
  }

  /// Background pull + merge. Firestore wins only for a record whose
  /// `updatedAt` is newer than the local copy; otherwise local is kept.
  /// If Firestore is empty and local has data, local is pushed up instead
  /// of wiping it.
  Future<void> _syncFromFirestore() async {
    if (!FirebaseService.initialized) {
      syncStatus = SyncStatus.localOnly;
      notifyListeners();
      return;
    }
    try {
      final remote = await _firestore.loadAll().timeout(const Duration(seconds: 30));
      if (remote == null) {
        syncStatus = SyncStatus.error;
        syncError = 'Could not reach Firestore';
        notifyListeners();
        return;
      }
      if (remote.units.isEmpty && remote.ledger.isEmpty && remote.expenses.isEmpty && units.isNotEmpty) {
        // First run against a fresh Firestore project: seed it from local.
        await _syncToFirestore();
        return;
      }
      units = _mergeUnits(units, remote.units);
      ledger = _mergeLedger(ledger, remote.ledger);
      expenses = _mergeExpenses(expenses, remote.expenses);
      if (remote.settings.isNotEmpty) {
        final r = remote.settings;
        if (r['whatsappReminders'] is bool) whatsappReminders = r['whatsappReminders'] as bool;
        if (r['graceDays'] is num) graceDays = (r['graceDays'] as num).toInt();
        if (r['language'] is String) language = r['language'] as String;
      }
      await save();
      syncStatus = SyncStatus.synced;
      lastSyncedAt = DateTime.now();
      syncError = null;
    } catch (e) {
      syncStatus = SyncStatus.error;
      syncError = '$e';
    }
    notifyListeners();
  }

  /// Public manual sync, used by the sync indicator in the UI.
  Future<void> syncNow() async {
    await _syncFromFirestore();
    // Push any local changes that are newer than what was just pulled.
    if (syncStatus == SyncStatus.synced) {
      await _syncToFirestore();
    }
  }

  static bool _remoteIsNewer(DateTime? remote, DateTime? local) {
    if (remote == null) return false;
    if (local == null) return true;
    return remote.isAfter(local);
  }

  static List<RentalUnit> _mergeUnits(List<RentalUnit> local, List<RentalUnit> remote) {
    final byId = {for (final u in local) u.id: u};
    for (final r in remote) {
      final l = byId[r.id];
      if (l == null || _remoteIsNewer(r.updatedAt, l.updatedAt)) byId[r.id] = r;
    }
    return byId.values.toList();
  }

  static List<LedgerEntry> _mergeLedger(List<LedgerEntry> local, List<LedgerEntry> remote) {
    final byId = {for (final e in local) e.id: e};
    for (final r in remote) {
      final l = byId[r.id];
      if (l == null || _remoteIsNewer(r.updatedAt, l.updatedAt)) byId[r.id] = r;
    }
    final merged = byId.values.toList();
    merged.sort((a, b) => b.date.compareTo(a.date));
    return merged;
  }

  static List<Expense> _mergeExpenses(List<Expense> local, List<Expense> remote) {
    final byId = {for (final e in local) e.id: e};
    for (final r in remote) {
      final l = byId[r.id];
      if (l == null || _remoteIsNewer(r.updatedAt, l.updatedAt)) byId[r.id] = r;
    }
    return byId.values.toList();
  }

  Future<void> setLoggedIn(bool v) async { loggedIn = v; await save(); notifyListeners(); }
  Future<void> setOnboardingDone(bool v) async { onboardingDone = v; await save(); notifyListeners(); }
  Future<void> toggleReminders(bool v) async { whatsappReminders = v; await save(); notifyListeners(); unawaited(_syncToFirestore()); }
  Future<void> setGraceDays(int v) async { graceDays = v; await save(); notifyListeners(); unawaited(_syncToFirestore()); }
  Future<void> setLanguage(String v) async { language = v; await save(); notifyListeners(); unawaited(_syncToFirestore()); }

  Future<void> markPaid(String unitId, {int? amount, String method = 'Cash', String month = 'Aug 2025'}) async {
    final unit = unitById(unitId);
    if (unit == null) return;
    final now = DateTime.now();
    unit.status = UnitStatus.paid;
    unit.receivedNote = 'Received 10th Aug';
    unit.updatedAt = now;
    ledger.insert(0, LedgerEntry(id: 'l${now.millisecondsSinceEpoch}', unitId: unitId, month: month, amount: amount ?? unit.rent, status: 'Paid', method: method, date: '10 Aug 2025', receipt: 'Receipt #2025-0810', updatedAt: now));
    await save(); notifyListeners();
    unawaited(_syncToFirestore());
  }

  Future<void> addPayment(String unitId, int amount, String method, String month) async {
    final unit = unitById(unitId);
    if (unit == null) return;
    final now = DateTime.now();
    ledger.insert(0, LedgerEntry(id: 'l${now.millisecondsSinceEpoch}', unitId: unitId, month: month, amount: amount, status: 'Paid', method: method, date: '10 Aug 2025', updatedAt: now));
    if (amount >= unit.rent) { unit.status = UnitStatus.paid; unit.receivedNote = 'Received 10th Aug'; unit.updatedAt = now; }
    await save(); notifyListeners();
    unawaited(_syncToFirestore());
  }

  Future<void> addUnit(RentalUnit unit) async {
    unit.updatedAt = DateTime.now();
    units.add(unit);
    await save(); notifyListeners();
    unawaited(_syncToFirestore());
  }

  Future<void> deleteUnit(String unitId) async {
    units.removeWhere((u) => u.id == unitId);
    ledger.removeWhere((e) => e.unitId == unitId);
    await save(); notifyListeners();
    if (FirebaseService.initialized) {
      unawaited(_firestore.deleteProperty(unitId).then((_) => _syncToFirestore()));
    }
  }

  Future<void> addExpense(Expense e) async {
    e.updatedAt = DateTime.now();
    expenses.insert(0, e);
    await save(); notifyListeners();
    unawaited(_syncToFirestore());
  }

  Future<void> deleteExpense(String expenseId) async {
    expenses.removeWhere((e) => e.id == expenseId);
    await save(); notifyListeners();
    if (FirebaseService.initialized) {
      unawaited(_firestore.deleteExpense(expenseId).then((_) => _syncToFirestore()));
    }
  }
}
