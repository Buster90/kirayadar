import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/store.dart';
import '../services/whatsapp_service.dart';
import '../theme.dart';
import '../widgets/common.dart';

class RecordPaymentScreen extends StatefulWidget {
  const RecordPaymentScreen({super.key});
  @override
  State<RecordPaymentScreen> createState() => _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends State<RecordPaymentScreen> {
  String? unitId;
  String cycle = 'Aug 2025';
  String mode = 'Cash';
  bool full = true;
  final amountCtrl = TextEditingController();
  final remarksCtrl = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    unitId ??= ModalRoute.of(context)?.settings.arguments as String?;
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    unitId ??= store.units.isNotEmpty ? store.units.first.id : null;
    final unit = unitId == null ? null : store.unitById(unitId!);
    if (unit != null && amountCtrl.text.isEmpty) amountCtrl.text = unit.rent.toString();
    final amount = int.tryParse(amountCtrl.text) ?? (unit?.rent ?? 0);
    final outstanding = unit == null ? 0 : (unit.rent - amount).clamp(0, 999999999);
    final preview = unit == null ? '' : WhatsAppService.receiptText(unit.tenantName, amount, cycle, mode, outstanding);
    return Scaffold(
      appBar: AppBar(title: const Text('Record Payment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Property & Tenant', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(value: unitId, decoration: const InputDecoration(), items: store.units.map((u) => DropdownMenuItem(value: u.id, child: Text('${u.title} — ${u.tenantName}'))).toList(), onChanged: (v) => setState(() { unitId = v; amountCtrl.text = ''; })),
          const SizedBox(height: 16),
          const Text('Billing Cycle', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          FilterChips(options: const ['Aug 2025', 'Jul 2025 Arrears', 'Sep 2025'], selected: cycle, onSelected: (v) => setState(() => cycle = v)),
          const SizedBox(height: 16),
          const Text('Amount', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(child: _amountType(true, 'Full')),
            const SizedBox(width: 8),
            Expanded(child: _amountType(false, 'Partial')),
          ]),
          const SizedBox(height: 8),
          TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(prefixText: 'Rs. ', labelText: 'Amount'), onChanged: (_) => setState(() {})),
          const SizedBox(height: 16),
          const Text('Payment Mode', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Wrap(spacing: 8, runSpacing: 8, children: ['Cash', 'Bank Transfer', 'JazzCash', 'EP', 'Cheque'].map((m) => ChoiceChip(label: Text(m), selected: mode == m, selectedColor: AppColors.primary, labelStyle: TextStyle(color: mode == m ? Colors.white : AppColors.text), showCheckmark: false, onSelected: (_) => setState(() => mode = m))).toList()),
          const SizedBox(height: 16),
          appCard(child: const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Payment Date'), Text('Today • 10 August 2025', style: TextStyle(fontWeight: FontWeight.w700))])),
          const SizedBox(height: 12),
          TextField(controller: remarksCtrl, decoration: const InputDecoration(labelText: 'Remarks (optional)')),
          const SizedBox(height: 16),
          const Text('WhatsApp Preview', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFFDCF8C6), borderRadius: BorderRadius.circular(14)), child: Text(preview)),
          const SizedBox(height: 16),
          PrimaryButton(label: 'Save & Send WhatsApp Receipt', onPressed: () async {
            if (unit == null) return;
            await store.addPayment(unit.id, amount, mode, cycle);
            if (!mounted) return;
            await WhatsAppService.openChat(context, unit.tenantPhone, preview);
            if (mounted) { showSnack(context, 'Payment saved for ${unit.title}'); Navigator.pop(context); }
          }),
          const SizedBox(height: 10),
          MintButton(label: 'Save Khata Entry Only', onPressed: () async {
            if (unit == null) return;
            await store.addPayment(unit.id, amount, mode, cycle);
            if (!mounted) return;
            showSnack(context, 'Khata entry saved for ${unit.title}');
            Navigator.pop(context);
          }),
        ]),
      ),
    );
  }

  Widget _amountType(bool isFull, String label) {
    final sel = full == isFull;
    return GestureDetector(onTap: () => setState(() => full = isFull), child: Container(padding: const EdgeInsets.symmetric(vertical: 14), alignment: Alignment.center, decoration: BoxDecoration(color: sel ? AppColors.primary : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: sel ? AppColors.primary : AppColors.border2)), child: Text(label, style: TextStyle(color: sel ? Colors.white : AppColors.text, fontWeight: FontWeight.w700))));
  }
}
