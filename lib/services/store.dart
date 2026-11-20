import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/seed_data.dart';
import '../models.dart';

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

  int get totalMonthly => units.fold(0, (s, u) => s + u.rent);
  int get collected => units.where((u) => u.status == UnitStatus.paid).fold(0, (s, u) => s + u.rent);
  int get pending => totalMonthly - collected;
  int get paidCount => units.where((u) => u.status == UnitStatus.paid).length;
  int get overdueCount => units.where((u) => u.status == UnitStatus.overdue).length;
  int get totalExpenses => expenses.fold(0, (s, e) => s + e.amount.abs());

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
    notifyListeners();
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

  Future<void> setLoggedIn(bool v) async { loggedIn = v; await save(); notifyListeners(); }
  Future<void> setOnboardingDone(bool v) async { onboardingDone = v; await save(); notifyListeners(); }
  Future<void> toggleReminders(bool v) async { whatsappReminders = v; await save(); notifyListeners(); }
  Future<void> setGraceDays(int v) async { graceDays = v; await save(); notifyListeners(); }
  Future<void> setLanguage(String v) async { language = v; await save(); notifyListeners(); }

  Future<void> markPaid(String unitId, {int? amount, String method = 'Cash', String month = 'Aug 2025'}) async {
    final unit = unitById(unitId);
    if (unit == null) return;
    unit.status = UnitStatus.paid;
    unit.receivedNote = 'Received 10th Aug';
    ledger.insert(0, LedgerEntry(id: 'l${DateTime.now().millisecondsSinceEpoch}', unitId: unitId, month: month, amount: amount ?? unit.rent, status: 'Paid', method: method, date: '10 Aug 2025', receipt: 'Receipt #2025-0810'));
    await save(); notifyListeners();
  }

  Future<void> addPayment(String unitId, int amount, String method, String month) async {
    final unit = unitById(unitId);
    if (unit == null) return;
    ledger.insert(0, LedgerEntry(id: 'l${DateTime.now().millisecondsSinceEpoch}', unitId: unitId, month: month, amount: amount, status: 'Paid', method: method, date: '10 Aug 2025'));
    if (amount >= unit.rent) { unit.status = UnitStatus.paid; unit.receivedNote = 'Received 10th Aug'; }
    await save(); notifyListeners();
  }

  Future<void> addUnit(RentalUnit unit) async { units.add(unit); await save(); notifyListeners(); }

  Future<void> addExpense(Expense e) async { expenses.insert(0, e); await save(); notifyListeners(); }
}
