import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models.dart';
import '../services/store.dart';
import '../theme.dart';
import '../widgets/common.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});
  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  String? property;
  String category = 'Plumbing';
  final titleCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  String method = 'Cash';
  final dateCtrl = TextEditingController(text: '12 Aug 2025');
  final paidToCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  bool attached = false;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    property ??= store.units.isNotEmpty ? store.units.last.title : null;
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Property', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(value: property, decoration: const InputDecoration(), items: store.units.map((u) => DropdownMenuItem(value: u.title, child: Text(u.title))).toList(), onChanged: (v) => setState(() => property = v)),
          const SizedBox(height: 14),
          const Text('Category', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 2.2,
            children: ['Plumbing', 'Paint', 'Govt', 'Electricity', 'Society', 'Other'].map((c) => GestureDetector(onTap: () => setState(() => category = c),
              child: Container(alignment: Alignment.center, decoration: BoxDecoration(color: category == c ? AppColors.primary : Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border2)), child: Text(c, style: TextStyle(color: category == c ? Colors.white : AppColors.text, fontWeight: FontWeight.w600, fontSize: 12))))).toList()),
          const SizedBox(height: 14),
          TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title *')),
          const SizedBox(height: 12),
          TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount (Rs.) *', prefixText: '-Rs. ')),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: ['5000', '8500', '14500', '18000'].map((a) => ActionChip(label: Text('Rs. $a'), onPressed: () => setState(() => amountCtrl.text = a))).toList()),
          const SizedBox(height: 12),
          const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          FilterChips(options: const ['Cash', 'Bank Transfer', 'JazzCash'], selected: method, onSelected: (v) => setState(() => method = v)),
          const SizedBox(height: 12),
          TextField(controller: dateCtrl, decoration: const InputDecoration(labelText: 'Date')),
          const SizedBox(height: 12),
          TextField(controller: paidToCtrl, decoration: const InputDecoration(labelText: 'Paid To')),
          const SizedBox(height: 12),
          TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Notes')),
          const SizedBox(height: 12),
          GestureDetector(onTap: () => setState(() => attached = !attached), child: Container(width: double.infinity, padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border2, style: BorderStyle.solid)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(attached ? Icons.check_circle : Icons.upload_file, color: attached ? AppColors.green : AppColors.primary), const SizedBox(width: 8), Text(attached ? 'Bill attached' : 'Attach Bill (upload placeholder)')]))),
          const SizedBox(height: 18),
          PrimaryButton(label: 'Save Expense & Update Ledger', onPressed: () async {
            if (titleCtrl.text.isEmpty || amountCtrl.text.isEmpty) { showSnack(context, 'Please enter title and amount'); return; }
            final amt = int.tryParse(amountCtrl.text) ?? 0;
            await store.addExpense(Expense(id: 'e${DateTime.now().millisecondsSinceEpoch}', propertyTitle: property ?? '', category: category, title: titleCtrl.text, amount: -amt, date: dateCtrl.text, method: method, paidTo: paidToCtrl.text, notes: notesCtrl.text));
            if (!mounted) return;
            showSnack(context, 'Expense saved and ledger updated');
            Navigator.pop(context);
          }),
          const SizedBox(height: 10),
          SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () => Navigator.pop(context), style: OutlinedButton.styleFrom(minimumSize: const Size(0, 54)), child: const Text('Cancel'))),
        ]),
      ),
    );
  }
}
