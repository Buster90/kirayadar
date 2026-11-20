import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final features = [
      ('Trusted Landlord Network', 'Over Rs. 25 Crore Rent Tracked', Icons.verified_outlined),
      ('100% Private Ledger', 'Your records stay yours', Icons.lock_outline),
      ('Courteous WhatsApp Slips', 'Polite receipts, automatically', Icons.chat_bubble_outline),
      ('Zero Commission. No Brokers.', 'Direct with your tenants', Icons.handshake_outlined),
    ];
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(children: [
            const SizedBox(height: 8),
            Container(width: 72, height: 72, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
              child: const Stack(alignment: Alignment.center, children: [Icon(Icons.home, color: Colors.white, size: 34), Positioned(right: 12, bottom: 12, child: Icon(Icons.access_time, color: AppColors.mint, size: 18))]),
            ),
            const SizedBox(height: 12),
            const Text('Kiraya Manager', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
            const Text('BILA-JHIJHAK RENT RECORDS', style: TextStyle(fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
            const SizedBox(height: 20),
            const Text('Track rent.\nSkip drama.', textAlign: TextAlign.center, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, height: 1.1)),
            const SizedBox(height: 10),
            const Text('بغیر کسی جھنجھٹ، کرایہ کا باوقار حساب کتاب', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2,
              crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.35,
              children: features.map((f) => appCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(f.$3, color: AppColors.primary), const SizedBox(height: 8),
                Text(f.$1, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                Text(f.$2, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ]))).toList(),
            ),
            const SizedBox(height: 14),
            appCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.mint, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.apartment, color: AppColors.primary)), const SizedBox(width: 10),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('3B Gulshan Flat B-4', style: TextStyle(fontWeight: FontWeight.w700)), Text('Tariq Jameel • 5th of month', style: TextStyle(fontSize: 12, color: AppColors.textMuted))]))]),
              const SizedBox(height: 10),
              const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Rs. 45,000', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)), Text('Received', style: TextStyle(color: AppColors.green, fontWeight: FontWeight.w700))]),
            ])),
            const SizedBox(height: 20),
            PrimaryButton(label: 'Get Started', onPressed: () => Navigator.pushNamed(context, '/login')),
            const SizedBox(height: 10),
            TextButton(onPressed: () => Navigator.pushNamed(context, '/login'), child: const Text('I already have an account • Login', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600))),
            const SizedBox(height: 12),
            const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.lock, size: 14, color: AppColors.textMuted), SizedBox(width: 4), Text('256-Bit Bank Grade Local Encryption', style: TextStyle(fontSize: 11, color: AppColors.textMuted))]),
          ]),
        ),
      ),
    );
  }
}
