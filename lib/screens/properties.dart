import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models.dart';
import '../services/store.dart';
import '../theme.dart';
import '../widgets/common.dart';

class PropertiesScreen extends StatefulWidget {
  const PropertiesScreen({super.key});
  @override
  State<PropertiesScreen> createState() => _PropertiesScreenState();
}

class _PropertiesScreenState extends State<PropertiesScreen> {
  String query = '';
  String filter = 'All Units';
  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    var list = store.units.where((u) => (u.title + u.tenantName + u.location).toLowerCase().contains(query.toLowerCase())).toList();
    if (filter == 'Overdue') list = list.where((u) => u.status == UnitStatus.overdue).toList();
    if (filter == 'Paid') list = list.where((u) => u.status == UnitStatus.paid).toList();
    if (filter == 'Vacant') list = list.where((u) => u.status == UnitStatus.vacant).toList();
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('My Properties', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const Text('Manage all your rentals in one khata', style: TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 14),
            appCard(child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _stat('${store.units.length}', 'Active Units'),
              _stat(fmtRs(store.totalMonthly), 'Total Monthly Rent'),
              _stat('${store.overdueCount}', 'Tenant Overdue'),
            ])),
            const SizedBox(height: 14),
            TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search properties…'), onChanged: (v) => setState(() => query = v)),
            const SizedBox(height: 12),
            FilterChips(options: const ['All Units', 'Overdue', 'Paid', 'Vacant'], selected: filter, onSelected: (v) => setState(() => filter = v)),
            const SizedBox(height: 14),
            ...list.map((u) => Padding(padding: const EdgeInsets.only(bottom: 10), child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/tenant', arguments: u.id),
              child: appCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Expanded(child: Text(u.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16))), statusChip(u.status)]),
                Text(u.location, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                const SizedBox(height: 8),
                Row(children: [const Icon(Icons.person, size: 16, color: AppColors.textMuted), const SizedBox(width: 6), Text(u.tenantName), const Spacer(), Text(fmtRs(u.rent), style: const TextStyle(fontWeight: FontWeight.w800))]),
                Text(u.receivedNote, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: OutlinedButton(onPressed: () => Navigator.pushNamed(context, '/record-payment', arguments: u.id), child: const Text('Record Payment'))),
                  const SizedBox(width: 8),
                  Expanded(child: OutlinedButton(onPressed: () => Navigator.pushNamed(context, '/tenant', arguments: u.id), child: const Text('View Details'))),
                ]),
              ])),
            ))),
            PrimaryButton(label: '+ Add New Property', onPressed: () => Navigator.pushNamed(context, '/add-property')),
          ]),
        ),
      ),
    );
  }

  Widget _stat(String value, String label) => Column(children: [Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)), Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted), textAlign: TextAlign.center)]);
}
