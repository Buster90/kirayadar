import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models.dart';
import '../services/store.dart';
import '../theme.dart';
import '../widgets/common.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});
  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final formKey = GlobalKey<FormState>();
  String category = 'Flat';
  final nameCtrl = TextEditingController();
  String city = 'Karachi';
  final addressCtrl = TextEditingController();
  final rentCtrl = TextEditingController();
  String due = '5th';
  final securityCtrl = TextEditingController();
  String escalation = '10%';
  bool occupied = true;
  final tenantCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final cnicCtrl = TextEditingController();
  final dateCtrl = TextEditingController(text: '01 Sep 2025');

  Future<void> save({bool draft = false}) async {
    if (!draft && !formKey.currentState!.validate()) return;
    final store = context.read<AppStore>();
    final unit = RentalUnit(
      id: 'u${DateTime.now().millisecondsSinceEpoch}',
      title: nameCtrl.text.isEmpty ? '$category, $city' : nameCtrl.text,
      subtitle: category, location: addressCtrl.text.isEmpty ? city : addressCtrl.text,
      tenantName: tenantCtrl.text.isEmpty ? 'Vacant' : tenantCtrl.text,
      tenantPhone: phoneCtrl.text, tenantCnic: cnicCtrl.text,
      rent: int.tryParse(rentCtrl.text) ?? 0,
      status: occupied ? UnitStatus.due : UnitStatus.vacant,
      dueDay: int.tryParse(due.replaceAll(RegExp(r'[^0-9]'), '')) ?? 5,
      security: int.tryParse(securityCtrl.text) ?? 0,
      leaseStart: dateCtrl.text, leaseEnd: '31 Aug 2026', tenantSince: 'Aug 2025',
    );
    await store.addUnit(unit);
    if (!mounted) return;
    showSnack(context, draft ? 'Saved as draft' : 'Property saved & Rent Khata generated');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Property')),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Step 1 of 2  •  Property Details', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textMuted)),
            const SizedBox(height: 14),
            const Text('Property Category', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 4, crossAxisSpacing: 8, childAspectRatio: 1.1,
              children: ['Portion', 'Flat', 'House', 'Shop'].map((c) => GestureDetector(onTap: () => setState(() => category = c),
                child: Container(alignment: Alignment.center, decoration: BoxDecoration(color: category == c ? AppColors.primary : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border2)), child: Text(c, style: TextStyle(color: category == c ? Colors.white : AppColors.text, fontWeight: FontWeight.w600, fontSize: 13))))).toList()),
            const SizedBox(height: 14),
            TextFormField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Unit Name *'), validator: (v) => (v == null || v.isEmpty) ? 'Required' : null),
            const SizedBox(height: 12),
            const Text('City', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            FilterChips(options: const ['Karachi', 'Lahore', 'Islamabad', 'Rawalpindi'], selected: city, onSelected: (v) => setState(() => city = v)),
            const SizedBox(height: 12),
            TextFormField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Address')),
            const SizedBox(height: 12),
            TextFormField(controller: rentCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Monthly Rent (Rs.) *', prefixText: 'Rs. '), validator: (v) => (v == null || v.isEmpty) ? 'Required' : null),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: ['35000', '45000', '55000', '75000'].map((a) => ActionChip(label: Text('Rs. $a'), onPressed: () => setState(() => rentCtrl.text = a))).toList()),
            const SizedBox(height: 12),
            const Text('Due Date', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            FilterChips(options: const ['1st', '5th', '10th', '15th'], selected: due, onSelected: (v) => setState(() => due = v)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextFormField(controller: securityCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Security (Rs.)'))),
              const SizedBox(width: 10),
              Expanded(child: DropdownButtonFormField<String>(value: escalation, decoration: const InputDecoration(labelText: 'Annual Escalation'), items: const ['5%', '10%', '15%'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => escalation = v ?? '10%'))),
            ]),
            const SizedBox(height: 12),
            SwitchListTile(title: Text(occupied ? 'Occupied' : 'Vacant'), value: occupied, onChanged: (v) => setState(() => occupied = v), activeColor: AppColors.primary),
            const Divider(),
            const Text('Tenant Details', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 10),
            TextFormField(controller: tenantCtrl, decoration: const InputDecoration(labelText: 'Tenant Name')),
            const SizedBox(height: 12),
            TextFormField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'WhatsApp Number', prefixText: '+92 ')),
            const SizedBox(height: 12),
            TextFormField(controller: cnicCtrl, decoration: const InputDecoration(labelText: 'CNIC')),
            const SizedBox(height: 12),
            TextFormField(controller: dateCtrl, decoration: const InputDecoration(labelText: 'Agreement Date')),
            const SizedBox(height: 20),
            PrimaryButton(label: 'Save & Generate Rent Khata', onPressed: () => save()),
            const SizedBox(height: 10),
            MintButton(label: 'Save as Draft', onPressed: () => save(draft: true)),
          ]),
        ),
      ),
    );
  }
}
