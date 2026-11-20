import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models.dart';
import '../services/store.dart';
import '../theme.dart';
import '../widgets/common.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String query = '';
  String filter = 'All';

  List<RentalUnit> filtered(AppStore store) {
    var list = store.units.where((u) => (u.title + u.tenantName + u.location).toLowerCase().contains(query.toLowerCase())).toList();
    if (filter == 'Paid') list = list.where((u) => u.status == UnitStatus.paid).toList();
    if (filter == 'Overdue') list = list.where((u) => u.status == UnitStatus.overdue).toList();
    if (filter == 'Due') list = list.where((u) => u.status == UnitStatus.due).toList();
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final list = filtered(store);
    final progress = store.totalMonthly == 0 ? 0.0 : store.collected / store.totalMonthly;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.home, color: Colors.white)),
              const SizedBox(width: 10),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Kiraya Manager', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)), Text('Bila-Jhijhak Rent Records', style: TextStyle(fontSize: 11, color: AppColors.textMuted))])),
              IconButton(onPressed: () => showSnack(context, 'No new notifications'), icon: const Icon(Icons.notifications_outlined)),
              const CircleAvatar(backgroundColor: AppColors.mint, child: Text('MA', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800))),
            ]),
            const SizedBox(height: 16),
            const Text('Assalam-o-Alaikum,', style: TextStyle(fontSize: 15, color: AppColors.textMuted)),
            const Text('Muhammad Asif Khan', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const Row(children: [Icon(Icons.location_on, size: 14, color: AppColors.textMuted), SizedBox(width: 4), Text('Karachi, Pakistan', style: TextStyle(color: AppColors.textMuted))]),
            const SizedBox(height: 10),
            const SyncIndicator(),
            const SizedBox(height: 16),
            Container(width: double.infinity, padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('August 2025  •  Collected', style: TextStyle(color: AppColors.mint, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(fmtRs(store.collected), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
                Text('${store.paidCount}/${store.units.length} Units Paid • ${store.overdueCount} Tenant Overdue', style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 12),
                ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: progress, minHeight: 8, backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation(AppColors.mint))),
                const SizedBox(height: 8),
                Text('${fmtRs(store.collected)} of ${fmtRs(store.totalMonthly)} collected', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Pending Due ${fmtRs(store.pending)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  const Text('Net Profit Rs. 1,485,000', style: TextStyle(color: AppColors.mint, fontWeight: FontWeight.w700, fontSize: 12)),
                ]),
              ]),
            ),
            const SizedBox(height: 16),
            TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search Properties, Tenants, or Units…'), onChanged: (v) => setState(() => query = v)),
            const SizedBox(height: 12),
            FilterChips(options: const ['All', 'Due', 'Paid', 'Overdue'], selected: filter, onSelected: (v) => setState(() => filter = v)),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Rent Status  •  August 2025  •  ${list.length} Units', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              TextButton(onPressed: () => Navigator.pushNamed(context, '/record-payment'), child: const Text('+ Add Payment')),
            ]),
            ...list.map((u) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _rentRow(context, store, u))),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: PrimaryButton(label: 'Record Payment', onPressed: () => Navigator.pushNamed(context, '/record-payment'))),
              const SizedBox(width: 10),
              Expanded(child: MintButton(label: '+ Add Unit', onPressed: () => Navigator.pushNamed(context, '/add-property'))),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _rentRow(BuildContext context, AppStore store, RentalUnit u) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/tenant', arguments: u.id),
      child: appCard(child: Row(children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.mint, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.apartment, color: AppColors.primary)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(u.title, style: const TextStyle(fontWeight: FontWeight.w700)),
          Text('${u.tenantName} • ${u.receivedNote}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          if (u.monthsLeft.isNotEmpty) Text(u.monthsLeft, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(fmtRs(u.rent), style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          statusChip(u.status),
        ]),
        const SizedBox(width: 6),
        if (u.status != UnitStatus.paid)
          IconButton(icon: const Icon(Icons.check_circle, color: AppColors.green), tooltip: 'Mark Paid',
            onPressed: () async {
              await store.markPaid(u.id);
              if (context.mounted) showSnack(context, '${u.title} marked as Paid for August 2025');
            }),
      ])),
    );
  }
}
