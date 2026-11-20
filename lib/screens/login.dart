import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/store.dart';
import '../theme.dart';
import '../widgets/common.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneCtrl = TextEditingController(text: '300 8291044');
  final List<TextEditingController> otp = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> nodes = List.generate(4, (_) => FocusNode());
  String method = 'WhatsApp';
  int seconds = 42;
  Timer? timer;
  String error = '';

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (seconds > 0) setState(() => seconds--);
    });
  }

  @override
  void dispose() { timer?.cancel(); phoneCtrl.dispose(); for (final c in otp) { c.dispose(); } for (final n in nodes) { n.dispose(); } super.dispose(); }

  String get code => otp.map((c) => c.text).join();

  Future<void> verify() async {
    if (code == '4820') {
      final store = context.read<AppStore>();
      await store.setLoggedIn(true);
      if (!mounted) return;
      if (store.onboardingDone) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
      } else {
        Navigator.pushNamed(context, '/onboarding');
      }
    } else {
      setState(() => error = 'Wrong code. Demo code is 4820.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Enter your Mobile Number', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text('We will send a verification code to confirm it is you.', style: TextStyle(color: AppColors.textMuted)),
          const SizedBox(height: 20),
          TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(prefixText: '+92 ', labelText: 'Mobile Number')),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _method('WhatsApp', 'Send via WhatsApp')),
            const SizedBox(width: 10),
            Expanded(child: _method('SMS', 'Receive via SMS')),
          ]),
          const SizedBox(height: 24),
          const Text('Enter OTP', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 10),
          Row(children: List.generate(4, (i) => Expanded(
            child: Container(margin: EdgeInsets.only(right: i < 3 ? 10 : 0),
              child: TextField(controller: otp[i], focusNode: nodes[i], keyboardType: TextInputType.number, maxLength: 1, textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                decoration: const InputDecoration(counterText: ''),
                onChanged: (v) { if (v.isNotEmpty && i < 3) nodes[i + 1].requestFocus(); if (v.isEmpty && i > 0) nodes[i - 1].requestFocus(); },
              )),
          ))),
          const SizedBox(height: 10),
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.mint.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(12)),
            child: const Row(children: [Icon(Icons.info_outline, color: AppColors.primary, size: 18), SizedBox(width: 8), Text('Demo code: 4820', style: TextStyle(fontWeight: FontWeight.w700))])),
          if (error.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 10), child: Text(error, style: const TextStyle(color: AppColors.red, fontWeight: FontWeight.w600))),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Resend in 00:${seconds.toString().padLeft(2, '0')}', style: const TextStyle(color: AppColors.textMuted)),
            TextButton(onPressed: seconds == 0 ? () => setState(() => seconds = 42) : null, child: const Text('Resend Code')),
          ]),
          const SizedBox(height: 8),
          PrimaryButton(label: 'Verify & Continue', onPressed: verify),
        ]),
      ),
    );
  }

  Widget _method(String value, String label) {
    final sel = method == value;
    return GestureDetector(
      onTap: () => setState(() => method = value),
      child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: sel ? AppColors.primary : Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: sel ? AppColors.primary : AppColors.border2)),
        child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: sel ? Colors.white : AppColors.text, fontWeight: FontWeight.w600, fontSize: 13))),
    );
  }
}
