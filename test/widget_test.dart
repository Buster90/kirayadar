import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kirayadar/data/seed_data.dart';
import 'package:kirayadar/models.dart';
import 'package:kirayadar/services/firestore_service.dart';
import 'package:kirayadar/theme.dart';

void main() {
  test('seed data has 6 units and totals compute', () {
    final units = seedUnits();
    expect(units.length, 6);
    expect(units.where((u) => u.tenantName == 'Tariq Mehmood').first.rent, 55000);
    expect(fmtRs(45000), 'Rs. 45,000');
  });

  test('updatedAt survives JSON round-trip (backward compatible)', () {
    final now = DateTime(2026, 11, 20, 20, 40);
    final unit = RentalUnit(
      id: 'u-test', title: 'Test Flat', subtitle: '', location: '',
      tenantName: 'Test', tenantPhone: '', tenantCnic: '', rent: 1000,
      status: UnitStatus.due, dueDay: 5, updatedAt: now,
    );
    final restored = RentalUnit.fromJson(unit.toJson());
    expect(restored.updatedAt, now);
    // Old data without updatedAt still parses.
    final legacy = RentalUnit.fromJson({'id': 'u-old', 'title': 'Old', 'rent': 1000, 'status': 'paid'});
    expect(legacy.updatedAt, isNull);
    expect(legacy.status, UnitStatus.paid);

    final entry = LedgerEntry(id: 'l1', unitId: 'u1', month: 'Aug 2025', amount: 1000, status: 'Paid', method: 'Cash', date: '10 Aug 2025', updatedAt: now);
    expect(LedgerEntry.fromJson(entry.toJson()).updatedAt, now);
    final expense = Expense(id: 'e1', propertyTitle: 'Test', category: 'Plumbing', title: 'Fix', amount: -500, date: '12 Aug 2025', method: 'Cash', updatedAt: now);
    expect(Expense.fromJson(expense.toJson()).updatedAt, now);
  });

  test('parseUpdatedAt handles int, ISO string and null', () {
    expect(parseUpdatedAt(null), isNull);
    expect(parseUpdatedAt(1763664000000), DateTime.fromMillisecondsSinceEpoch(1763664000000));
    expect(parseUpdatedAt('2026-11-20T20:40:00.000'), DateTime(2026, 11, 20, 20, 40));
  });

  test('Firestore date parsing handles Timestamp, int and missing', () {
    final ts = Timestamp.fromMillisecondsSinceEpoch(1763664000000);
    expect(
      FirestoreService.parseFirestoreDate({'updatedAt': ts}),
      DateTime.fromMillisecondsSinceEpoch(1763664000000),
    );
    expect(
      FirestoreService.parseFirestoreDate({'updatedAt': 1763664000000}),
      DateTime.fromMillisecondsSinceEpoch(1763664000000),
    );
    expect(FirestoreService.parseFirestoreDate({}), isNull);
    expect(
      FirestoreService.parseFirestoreDate({'updatedAtMs': 1763664000000}),
      DateTime.fromMillisecondsSinceEpoch(1763664000000),
    );
  });
}
