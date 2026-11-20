import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppService {
  static Future<bool> openChat(BuildContext context, String phone, String message) async {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final number = digits.startsWith('92') ? digits : '92${digits.startsWith('0') ? digits.substring(1) : digits}';
    final uri = Uri.parse('https://wa.me/$number?text=${Uri.encodeComponent(message)}');
    try {
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return true;
    } catch (_) {}
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('WhatsApp message: $message')));
    }
    return false;
  }

  static String receiptText(String tenant, int amount, String month, String mode, int outstanding) =>
      'Salam $tenant! Rent of Rs. $amount received for $month via $mode. Outstanding Balance: Rs. $outstanding. – Kiraya Manager';

  static String reminderText(String tenant, int amount, String month) =>
      'Salam $tenant! A friendly reminder: rent of Rs. $amount for $month is due. Please pay at your convenience. – Kiraya Manager';
}
