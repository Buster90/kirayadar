enum UnitStatus { paid, overdue, due, vacant }

extension UnitStatusX on UnitStatus {
  String get label => switch (this) {
        UnitStatus.paid => 'Paid',
        UnitStatus.overdue => 'Overdue',
        UnitStatus.due => 'Due',
        UnitStatus.vacant => 'Vacant',
      };
}

class RentalUnit {
  final String id;
  final String title;
  final String subtitle;
  final String location;
  final String tenantName;
  final String tenantPhone;
  final String tenantCnic;
  final int rent;
  UnitStatus status;
  final int dueDay;
  String receivedNote;
  final String monthsLeft;
  final int security;
  final String leaseStart;
  final String leaseEnd;
  final String tenantSince;
  final String beds;

  RentalUnit({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.location,
    required this.tenantName,
    required this.tenantPhone,
    required this.tenantCnic,
    required this.rent,
    required this.status,
    required this.dueDay,
    this.receivedNote = '',
    this.monthsLeft = '',
    this.security = 0,
    this.leaseStart = '',
    this.leaseEnd = '',
    this.tenantSince = '',
    this.beds = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id, 'title': title, 'subtitle': subtitle, 'location': location,
        'tenantName': tenantName, 'tenantPhone': tenantPhone, 'tenantCnic': tenantCnic,
        'rent': rent, 'status': status.name, 'dueDay': dueDay, 'receivedNote': receivedNote,
        'monthsLeft': monthsLeft, 'security': security, 'leaseStart': leaseStart,
        'leaseEnd': leaseEnd, 'tenantSince': tenantSince, 'beds': beds,
      };

  factory RentalUnit.fromJson(Map<String, dynamic> j) => RentalUnit(
        id: j['id'] as String, title: j['title'] as String, subtitle: j['subtitle'] as String? ?? '',
        location: j['location'] as String? ?? '', tenantName: j['tenantName'] as String? ?? '',
        tenantPhone: j['tenantPhone'] as String? ?? '', tenantCnic: j['tenantCnic'] as String? ?? '',
        rent: (j['rent'] as num).toInt(),
        status: UnitStatus.values.firstWhere((e) => e.name == j['status'], orElse: () => UnitStatus.due),
        dueDay: (j['dueDay'] as num?)?.toInt() ?? 5,
        receivedNote: j['receivedNote'] as String? ?? '', monthsLeft: j['monthsLeft'] as String? ?? '',
        security: (j['security'] as num?)?.toInt() ?? 0, leaseStart: j['leaseStart'] as String? ?? '',
        leaseEnd: j['leaseEnd'] as String? ?? '', tenantSince: j['tenantSince'] as String? ?? '',
        beds: j['beds'] as String? ?? '',
      );
}

class LedgerEntry {
  final String id;
  final String unitId;
  final String month;
  final int amount;
  final String status;
  final String method;
  final String date;
  final String receipt;
  LedgerEntry({required this.id, required this.unitId, required this.month, required this.amount, required this.status, required this.method, required this.date, this.receipt = ''});
  Map<String, dynamic> toJson() => {'id': id, 'unitId': unitId, 'month': month, 'amount': amount, 'status': status, 'method': method, 'date': date, 'receipt': receipt};
  factory LedgerEntry.fromJson(Map<String, dynamic> j) => LedgerEntry(
        id: j['id'] as String, unitId: j['unitId'] as String, month: j['month'] as String,
        amount: (j['amount'] as num).toInt(), status: j['status'] as String,
        method: j['method'] as String, date: j['date'] as String, receipt: j['receipt'] as String? ?? '');
}

class Expense {
  final String id;
  final String propertyTitle;
  final String category;
  final String title;
  final int amount; // negative
  final String date;
  final String method;
  final String paidTo;
  final String notes;
  Expense({required this.id, required this.propertyTitle, required this.category, required this.title, required this.amount, required this.date, required this.method, this.paidTo = '', this.notes = ''});
  Map<String, dynamic> toJson() => {'id': id, 'propertyTitle': propertyTitle, 'category': category, 'title': title, 'amount': amount, 'date': date, 'method': method, 'paidTo': paidTo, 'notes': notes};
  factory Expense.fromJson(Map<String, dynamic> j) => Expense(
        id: j['id'] as String, propertyTitle: j['propertyTitle'] as String, category: j['category'] as String,
        title: j['title'] as String, amount: (j['amount'] as num).toInt(), date: j['date'] as String,
        method: j['method'] as String, paidTo: j['paidTo'] as String? ?? '', notes: j['notes'] as String? ?? '');
}
