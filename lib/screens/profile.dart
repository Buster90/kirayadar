import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/store.dart';
import '../theme.dart';
import '../widgets/common.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Profile & Settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const SyncIndicator(),
            const SizedBox(height: 12),
            appCard(child: Row(children: [
              const CircleAvatar(radius: 28, backgroundColor: AppColors.mint, child: Text('MA', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 18))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Muhammad Asif Khan', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                const Text('Verified Landlord • ${'5'} Units Active', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                const Text('Karachi • +92 300 8291044', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                const Text('CNIC 42201-1982734-1', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ])),
              const Icon(Icons.verified, color: AppColors.green),
            ])),
            const SizedBox(height: 12),
            appCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Kiraya Premium Plan', style: TextStyle(fontWeight: FontWeight.w800)), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: AppColors.mint, borderRadius: BorderRadius.circular(12)), child: const Text('ACTIVE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary)))]),
              const SizedBox(height: 6),
              const Text('PKR 1,000/month • Renews 15 Sep 2025', style: TextStyle(color: AppColors.textMuted)),
              const Text('JazzCash Auto-debit enabled', style: TextStyle(color: AppColors.textMuted)),
            ])),
            const SizedBox(height: 12),
            appCard(child: Column(children: [
              SwitchListTile(title: const Text('WhatsApp Reminders'), value: store.whatsappReminders, onChanged: (v) async { await store.toggleReminders(v); if (context.mounted) showSnack(context, v ? 'WhatsApp reminders ON' : 'WhatsApp reminders OFF'); }, activeColor: AppColors.primary),
              ListTile(title: const Text('Language'), trailing: DropdownButton<String>(value: store.language, items: const ['Bilingual', 'English', 'Urdu'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) { if (v != null) store.setLanguage(v); })),
              Row(children: [
                const Expanded(child: Text('Grace Period', style: TextStyle(fontWeight: FontWeight.w600))),
                IconButton(onPressed: () => store.setGraceDays((store.graceDays - 1).clamp(0, 15)), icon: const Icon(Icons.remove_circle_outline)),
                Text('${store.graceDays} Days', style: const TextStyle(fontWeight: FontWeight.w800)),
                IconButton(onPressed: () => store.setGraceDays((store.graceDays + 1).clamp(0, 15)), icon: const Icon(Icons.add_circle_outline)),
              ]),
            ])),
            const SizedBox(height: 12),
            appCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Bank & Payments', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              _copyRow(context, 'Meezan Bank', 'PK64MEZN00010982390192'),
              _copyRow(context, 'Raast / JazzCash', '0300-8291044'),
            ])),
            const SizedBox(height: 12),
            appCard(child: Column(children: [
              ListTile(leading: const Icon(Icons.cloud_done), title: const Text('Encrypted Cloud Backup'), trailing: const Text('ON', style: TextStyle(color: AppColors.green, fontWeight: FontWeight.w700))),
              ListTile(leading: const Icon(Icons.file_download), title: const Text('Export Excel / CSV'), onTap: () => showSnack(context, 'Ledger exported as CSV')),
              ListTile(leading: const Icon(Icons.archive), title: const Text('Rent Receipts Zip'), onTap: () => showSnack(context, 'Receipts zip prepared')),
              ListTile(leading: const Icon(Icons.support_agent), title: const Text('Contact WhatsApp Support'), onTap: () => showSnack(context, 'Support: WhatsApp 0300-8291044')),
              ListTile(leading: const Icon(Icons.star), title: const Text('Rate the App'), onTap: () => showSnack(context, 'Thank you for rating Kiraya Manager!')),
            ])),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () async {
              await context.read<AppStore>().setLoggedIn(false);
              if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
            }, icon: const Icon(Icons.logout, color: AppColors.red), label: const Text('Log Out', style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w700)), style: OutlinedButton.styleFrom(minimumSize: const Size(0, 54), side: const BorderSide(color: AppColors.red)))),
            const SizedBox(height: 16),
            const Center(child: Text('v1.2.4  •  Build 42', style: TextStyle(color: AppColors.textMuted, fontSize: 12))),
          ]),
        ),
      ),
    );
  }

  Widget _copyRow(BuildContext context, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)), Text(value, style: const TextStyle(fontWeight: FontWeight.w700))])), IconButton(icon: const Icon(Icons.copy, size: 18), onPressed: () { Clipboard.setData(ClipboardData(text: value)); showSnack(context, '$label copied'); })]),
  );
}
