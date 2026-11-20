import 'package:flutter_test/flutter_test.dart';
import 'package:kirayadar/data/seed_data.dart';
import 'package:kirayadar/theme.dart';

void main() {
  test('seed data has 6 units and totals compute', () {
    final units = seedUnits();
    expect(units.length, 6);
    expect(units.where((u) => u.tenantName == 'Tariq Mehmood').first.rent, 55000);
    expect(fmtRs(45000), 'Rs. 45,000');
  });
}
