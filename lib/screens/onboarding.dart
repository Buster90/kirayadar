import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/store.dart';
import '../theme.dart';
import '../widgets/common.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int step = 2;
  final steps = [
    ('Welcome to Kiraya Manager', 'Your rent khata, finally organised.', Icons.home),
    ('WhatsApp Reminders', 'Courteous reminders, sent automatically on the due date.', Icons.chat_bubble_outline),
    ('Track Every Rupee', 'Ledger, receipts and reports in one place.', Icons.receipt_long),
  ];

  Future<void> finish() async {
    await context.read<AppStore>().setOnboardingDone(true);
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final s = steps[step - 1];
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Step $step of 3', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textMuted)),
              TextButton(onPressed: finish, child: const Text('Skip to Dashboard')),
            ]),
            Row(children: List.generate(3, (i) => Expanded(child: Container(height: 6, margin: EdgeInsets.only(right: i < 2 ? 6 : 0), decoration: BoxDecoration(color: i < step ? AppColors.primary : AppColors.border2, borderRadius: BorderRadius.circular(4)))))),
            const SizedBox(height: 28),
            Container(width: 80, height: 80, decoration: BoxDecoration(color: AppColors.mint, borderRadius: BorderRadius.circular(24)), child: Icon(s.$3, color: AppColors.primary, size: 40)),
            const SizedBox(height: 20),
            Text(s.$1, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(s.$2, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textMuted, fontSize: 15)),
            const SizedBox(height: 20),
            if (step == 2) ...[
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
                child: const Row(children: [Icon(Icons.check_circle, color: AppColors.mint), SizedBox(width: 8), Expanded(child: Text('WhatsApp Reminder active', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)))])),
              const SizedBox(height: 12),
              appCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Row(children: [CircleAvatar(backgroundColor: AppColors.mint, child: Icon(Icons.person, color: AppColors.primary)), SizedBox(width: 10), Text('Tariq Mehmood', style: TextStyle(fontWeight: FontWeight.w700))]),
                const SizedBox(height: 10),
                Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12)),
                  child: const Text('Salam Tariq Bhai! A friendly reminder: rent of Rs. 55,000 for Aug 2025 is due on the 5th. – Kiraya Manager')),
              ])),
              const SizedBox(height: 12),
              const FilterChips(options: ['Polite', 'On Due Date', 'Auto Receipt'], selected: 'Polite', onSelected: _noop),
            ],
            const Spacer(),
            Row(children: [
              if (step > 1) Expanded(child: OutlinedButton(onPressed: () => setState(() => step--), style: OutlinedButton.styleFrom(minimumSize: const Size(0, 54)), child: const Text('Previous'))),
              if (step > 1) const SizedBox(width: 10),
              Expanded(flex: 2, child: PrimaryButton(label: step == 3 ? 'Go to Dashboard' : 'Next: Setup Your First Property', onPressed: () { if (step < 3) { setState(() => step++); } else { finish(); } })),
            ]),
          ]),
        ),
      ),
    );
  }
}

void _noop(String _) {}
