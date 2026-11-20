import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models.dart';
import '../services/store.dart';
import '../services/whatsapp_service.dart';
import '../theme.dart';
import '../widgets/common.dart';

class TenantDetailsScreen extends StatelessWidget {
  const TenantDetailsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final unitId = ModalRoute.of(context)?.settings.arguments as String? ?? 'u4';
    final store = context.watch<AppStore>();
    final unit = store.unitById(unitId) ?? store.units.first;
    final entries = store.ledgerFor(unit.id);
    return Scaffold(
      appBar: AppBar(title: Text(unit.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          appCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Expanded(child: Text(unit.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18))), statusChip(unit.status)]),
            Text(unit.location, style: const TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Monthly Rent'), Text(fmtRs(unit.rent), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18))]),
            Text('Due ${unit.dueDay}th of month • ${unit.receivedNote}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ])),
          const SizedBox(height: 12),
          appCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Tenant', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 8),
            _row('Name', unit.tenantName),
            _row('Mobile', unit.tenantPhone),
            _row('CNIC', unit.tenantCnic),
            _row('Lease', '${unit.leaseStart} – ${unit.leaseEnd}'),
            _row('Tenant Since', unit.tenantSince),
            _row('Security Deposit', fmtRs(unit.security)),
            if (unit.monthsLeft.isNotEmpty) _row('Lease Left', unit.monthsLeft),
          ])),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: PrimaryButton(label: 'Mark August Rent Paid', onPressed: () async {
              await store.markPaid(unit.id);
              if (context.mounted) showSnack(context, 'August rent marked as Paid for ${unit.tenantName}');
            })),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: OutlinedButton.icon(onPressed: () => WhatsAppService.openChat(context, unit.tenantPhone, WhatsAppService.reminderText(unit.tenantName, unit.rent, 'Aug 2025')), icon: const Icon(Icons.chat), label: const Text('Reminder'))),
            const SizedBox(width: 10),
            Expanded(child: OutlinedButton.icon(onPressed: () => Navigator.pushNamed(context, '/agreement', arguments: unit.id), icon: const Icon(Icons.description), label: const Text('Lease Deed PDF'))),
          ]),
          const SizedBox(height: 16),
          const Text('Khata Ledger', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 8),
          ...entries.map((e) => Padding(padding: const EdgeInsets.only(bottom: 8), child: appCard(child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(e.month, style: const TextStyle(fontWeight: FontWeight.w700)), Text('${e.method} • ${e.date}${e.receipt.isNotEmpty ? ' • ${e.receipt}' : ''}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted))])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(fmtRs(e.amount), style: const TextStyle(fontWeight: FontWeight.w800)), Text(e.status, style: TextStyle(color: e.status == 'Paid' ? AppColors.green : AppColors.red, fontWeight: FontWeight.w700, fontSize: 12))]),
          ])))),
          const SizedBox(height: 12),
          appCard(child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Unit Notes & Repair Log', style: TextStyle(fontWeight: FontWeight.w800)),
            SizedBox(height: 6),
            Text('• Water pump rewound on 12 Aug 2025 (Flat 402).\n• Exterior paint due next quarter.', style: TextStyle(color: AppColors.textMuted)),
          ])),
          const SizedBox(height: 12),
          appCard(child: Row(children: [
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('WhatsApp Statement', style: TextStyle(fontWeight: FontWeight.w800)), Text('Send full khata statement to tenant', style: TextStyle(fontSize: 12, color: AppColors.textMuted))])),
            ElevatedButton(onPressed: () => WhatsAppService.openChat(context, unit.tenantPhone, 'Khata Statement for ${unit.title}: Aug 2025 ${unit.status.label}, Rent ${fmtRs(unit.rent)}. – Kiraya Manager'), child: const Text('Send')),
          ])),
        ]),
      ),
    );
  }

  Widget _row(String k, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(k, style: const TextStyle(color: AppColors.textMuted)), Text(v, style: const TextStyle(fontWeight: FontWeight.w600))]));
}
