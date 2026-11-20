import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/store.dart';
import '../services/whatsapp_service.dart';
import '../theme.dart';
import '../widgets/common.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final months = ['Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug'];
    final values = [270000, 270000, 255000, 270000, 270000, 285000];
    final maxV = 285000.0;
    final totalExp = store.totalExpenses;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Reports & Analytics', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const Text('FY 2024-25  •  All properties', style: TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 14),
            Container(width: double.infinity, padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
              child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('TOTAL RENTAL INFLOW', style: TextStyle(color: AppColors.mint, fontWeight: FontWeight.w700)),
                Text('Rs. 1,620,000', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
                Text('+8.2% YoY  •  Collection Rate 96.4%', style: TextStyle(color: Colors.white70)),
                SizedBox(height: 8),
                Text('Net Profit  Rs. 1,485,000', style: TextStyle(color: AppColors.mint, fontWeight: FontWeight.w700)),
              ])),
            const SizedBox(height: 12),
            PrimaryButton(label: 'Download FBR Tax Statement', onPressed: () async {
              await Share.share('FBR Tax Statement FY 2024-25 — Kiraya Manager\nTotal Rental Inflow: Rs. 1,620,000\nNet Profit: Rs. 1,485,000\nCollection Rate: 96.4%');
              if (context.mounted) showSnack(context, 'FBR Tax Statement shared');
            }),
            const SizedBox(height: 16),
            const Text('Monthly Collection Flow', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
            const SizedBox(height: 10),
            appCard(child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: List.generate(months.length, (i) => Expanded(
              child: Column(children: [
                Text('${(values[i] / 1000).round()}k', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Container(height: 110 * (values[i] / maxV), decoration: BoxDecoration(color: i == 5 ? AppColors.primary : AppColors.mint, borderRadius: BorderRadius.circular(6))),
                const SizedBox(height: 6),
                Text(months[i], style: const TextStyle(fontSize: 11)),
              ]),
            )))),
            const SizedBox(height: 16),
            const Text('Expenses', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
            Text('Total ${fmtRs(totalExp)}  •  Plumbing 55%  •  Govt 32%  •  Society 13%', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
            const SizedBox(height: 8),
            Row(children: [
              SizedBox(width: 110, height: 110, child: CustomPaint(painter: _DonutPainter(), child: Center(child: Text('${fmtRs(totalExp)}\nTotal', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11))))),
              const SizedBox(width: 12),
              Expanded(child: Column(children: [
                _legend('Plumbing 55%', AppColors.primary),
                _legend('Govt 32%', AppColors.darkGreen2),
                _legend('Society 13%', AppColors.mint),
              ])),
            ]),
            const SizedBox(height: 12),
            ...store.expenses.map((e) => Padding(padding: const EdgeInsets.only(bottom: 8), child: appCard(child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(e.title, style: const TextStyle(fontWeight: FontWeight.w700)), Text('${e.propertyTitle} • ${e.date} • ${e.category}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted))])),
              Text('-${fmtRs(e.amount.abs())}', style: const TextStyle(color: AppColors.red, fontWeight: FontWeight.w800)),
            ])))),
            const SizedBox(height: 8),
            appCard(child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Tenant Reliability Scorecard', style: TextStyle(fontWeight: FontWeight.w800)),
              SizedBox(height: 8),
              Text('Tariq Jameel  •  98%  •  Always on time', style: TextStyle(fontSize: 13)),
              Text('Muhammad Aslam  •  97%  •  Always on time', style: TextStyle(fontSize: 13)),
              Text('Tariq Mehmood  •  72%  •  Late this month', style: TextStyle(fontSize: 13, color: AppColors.red)),
              Text('Rashid Khan  •  88%  •  Usually on time', style: TextStyle(fontSize: 13)),
            ])),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: OutlinedButton(onPressed: () async {
                final csv = 'Month,Unit,Amount,Status\n${store.ledger.map((e) => '${e.month},${e.unitId},${e.amount},${e.status}').join('\n')}';
                await Share.share(csv, subject: 'Full Ledger — Kiraya Manager');
              }, child: const Text('Export Full Ledger'))),
              const SizedBox(width: 10),
              Expanded(child: OutlinedButton(onPressed: () => WhatsAppService.openChat(context, '03008291044', 'Full khata statement — Total Inflow Rs. 1,620,000, Net Profit Rs. 1,485,000. – Kiraya Manager'), child: const Text('WhatsApp Statement'))),
            ]),
            const SizedBox(height: 12),
            PrimaryButton(label: '+ Add Expense', onPressed: () => Navigator.pushNamed(context, '/add-expense')),
          ]),
        ),
      ),
    );
  }

  Widget _legend(String t, Color c) => Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(children: [Container(width: 12, height: 12, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(3))), const SizedBox(width: 8), Text(t)]));
}

class _DonutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paints = [Paint()..color = AppColors.primary..style = PaintingStyle.stroke..strokeWidth = 22,
      Paint()..color = AppColors.darkGreen2..style = PaintingStyle.stroke..strokeWidth = 22,
      Paint()..color = AppColors.mint..style = PaintingStyle.stroke..strokeWidth = 22];
    final sweeps = [3.45, 2.01, 0.82];
    double start = -1.57;
    for (var i = 0; i < 3; i++) { canvas.drawArc(rect.deflate(14), start, sweeps[i], false, paints[i]); start += sweeps[i]; }
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
