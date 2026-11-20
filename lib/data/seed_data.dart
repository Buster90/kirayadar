import '../models.dart';

List<RentalUnit> seedUnits() => [
      RentalUnit(id: 'u1', title: 'Gulshan Flat B-4', subtitle: 'Flat B-4', location: 'Gulshan-e-Iqbal, Karachi', tenantName: 'Tariq Jameel', tenantPhone: '0300-1234567', tenantCnic: '42201-1234567-1', rent: 45000, status: UnitStatus.paid, dueDay: 5, receivedNote: 'Received 6th Aug', security: 90000, leaseStart: '1 Jan 2025', leaseEnd: '31 Dec 2025', tenantSince: 'Jan 2025', beds: '2 Bed'),
      RentalUnit(id: 'u2', title: 'House 14-B, Defence Phase 6', subtitle: 'House 14-B', location: 'Defence Phase 6, Karachi', tenantName: 'Muhammad Aslam', tenantPhone: '0301-2345678', tenantCnic: '42201-2345678-2', rent: 75000, status: UnitStatus.paid, dueDay: 5, receivedNote: 'Received', security: 150000, leaseStart: '1 Feb 2025', leaseEnd: '31 Jan 2026', tenantSince: 'Feb 2025'),
      RentalUnit(id: 'u3', title: 'Shop #3, Saddar Commercial', subtitle: 'Shop 12', location: 'Saddar Commercial, Karachi', tenantName: 'Usman Ali Motors', tenantPhone: '0302-3456789', tenantCnic: '42201-3456789-3', rent: 60000, status: UnitStatus.paid, dueDay: 5, receivedNote: 'Direct Deposit 4th Aug', monthsLeft: '10 Months Left', security: 120000, leaseStart: '1 Mar 2025', leaseEnd: '28 Feb 2026', tenantSince: 'Mar 2025'),
      RentalUnit(id: 'u4', title: 'Flat B-2, Clifton Block 5', subtitle: 'Flat B-2', location: 'Clifton Block 5, Karachi', tenantName: 'Tariq Mehmood', tenantPhone: '0321-9876543', tenantCnic: '42101-7654321-9', rent: 55000, status: UnitStatus.overdue, dueDay: 5, receivedNote: 'Due 5th Aug • Late by 5 days', security: 110000, leaseStart: '1 Jan 2025', leaseEnd: '31 Dec 2025', tenantSince: 'Jan 2025', beds: '2 Bed'),
      RentalUnit(id: 'u5', title: 'Upper Portion, Sector G-9', subtitle: 'Upper Portion', location: 'Sector G-9, Islamabad', tenantName: 'Rashid Khan', tenantPhone: '0333-4567890', tenantCnic: '61101-4567890-4', rent: 35000, status: UnitStatus.due, dueDay: 10, receivedNote: 'Due in 3 days • Target 10th Aug', security: 70000, leaseStart: '1 Apr 2025', leaseEnd: '31 Mar 2026', tenantSince: 'Apr 2025'),
      RentalUnit(id: 'u6', title: 'Flat 402, Al-Rehman Heights', subtitle: 'Flat 402', location: 'Al-Rehman Heights, Karachi', tenantName: 'Farhan Zaidi', tenantPhone: '0304-5678901', tenantCnic: '42201-5678901-5', rent: 60000, status: UnitStatus.paid, dueDay: 1, receivedNote: 'Paid • Next Due 1st Sep', security: 120000, leaseStart: '1 May 2025', leaseEnd: '30 Apr 2026', tenantSince: 'May 2025'),
    ];

List<LedgerEntry> seedLedger() => [
      LedgerEntry(id: 'l1', unitId: 'u4', month: 'Aug 2025', amount: 55000, status: 'Overdue', method: '—', date: 'Due 5 Aug 2025'),
      LedgerEntry(id: 'l2', unitId: 'u4', month: 'Jul 2025', amount: 55000, status: 'Paid', method: 'Cash', date: '06 Jul 2025', receipt: 'Receipt #2025-0731'),
      LedgerEntry(id: 'l3', unitId: 'u4', month: 'Jun 2025', amount: 55000, status: 'Paid', method: 'Meezan Bank', date: '04 Jun 2025', receipt: 'Verified'),
      LedgerEntry(id: 'l4', unitId: 'u4', month: 'May 2025', amount: 55000, status: 'Paid', method: 'Cash', date: '05 May 2025'),
      LedgerEntry(id: 'l5', unitId: 'u4', month: 'Apr 2025', amount: 55000, status: 'Paid', method: 'Cash', date: '05 Apr 2025'),
      LedgerEntry(id: 'l6', unitId: 'u4', month: 'Mar 2025', amount: 55000, status: 'Paid', method: 'Bank Transfer', date: '07 Mar 2025'),
      LedgerEntry(id: 'l7', unitId: 'u4', month: 'Security Deposit', amount: 110000, status: 'Paid', method: 'Bank', date: '28 Dec 2024'),
      LedgerEntry(id: 'l8', unitId: 'u1', month: 'Aug 2025', amount: 45000, status: 'Paid', method: 'Cash', date: '06 Aug 2025'),
      LedgerEntry(id: 'l9', unitId: 'u2', month: 'Aug 2025', amount: 75000, status: 'Paid', method: 'Bank Transfer', date: '05 Aug 2025'),
      LedgerEntry(id: 'l10', unitId: 'u3', month: 'Aug 2025', amount: 60000, status: 'Paid', method: 'Direct Deposit', date: '04 Aug 2025'),
      LedgerEntry(id: 'l11', unitId: 'u6', month: 'Aug 2025', amount: 60000, status: 'Paid', method: 'JazzCash', date: '03 Aug 2025'),
    ];

List<Expense> seedExpenses() => [
      Expense(id: 'e1', propertyTitle: 'Flat 402, Al-Rehman Heights', category: 'Plumbing', title: 'Water Pump Rewind', amount: -8500, date: '12 Aug 2025', method: 'Cash', paidTo: 'Plumber'),
      Expense(id: 'e2', propertyTitle: 'House 14-B, Defence Phase 6', category: 'Paint', title: 'Exterior Paint', amount: -18000, date: '28 Jul 2025', method: 'Bank Transfer', paidTo: 'Painter'),
      Expense(id: 'e3', propertyTitle: 'Flat B-2, Clifton Block 5', category: 'Govt', title: 'Property Tax Challan — Clifton', amount: -14500, date: '10 Jun 2025', method: 'Bank Transfer', paidTo: 'Govt. of Sindh'),
    ];
