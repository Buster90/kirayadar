import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/store.dart';
import '../services/whatsapp_service.dart';
import '../theme.dart';
import '../widgets/common.dart';

class AgreementScreen extends StatefulWidget {
  const AgreementScreen({super.key});
  @override
  State<AgreementScreen> createState() => _AgreementScreenState();
}

class _AgreementScreenState extends State<AgreementScreen> {
  String term = '11 Months';
  String notice = '1 Mo';
  String agreementText(String tenant, String property, int rent, int security) =>
      'KIRAYANAMA (RENT AGREEMENT)\n\nLandlord: Muhammad Asif Khan\nTenant: $tenant\nProperty: $property\n\nTerm: $term (01 Sep 2025 – 31 Jul 2026)\nMonthly Rent: Rs. $rent, due on the 5th of each month\nSecurity Deposit: Rs. $security (refundable)\nAnnual Escalation: +10%\nNotice Period: $notice\nUtilities: Electricity, gas and water as per actual usage, payable by tenant.\n\nThis agreement is compliant with Sindh & Punjab Tenancy laws and is e-Stamp ready.\nGovt e-Stamp Ref #2025-PB-991204 • Stamp Duty Rs. 1,200\n\nSigned: Landlord ________  Tenant ________';

  Future<void> downloadPdf(String tenant, String property, int rent, int security) async {
    try {
      final doc = pw.Document();
      doc.addPage(pw.Page(build: (c) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [pw.Text('KIRAYANAMA', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)), pw.SizedBox(height: 12), pw.Text(agreementText(tenant, property, rent, security))])));
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/kirayanama.pdf');
      await file.writeAsBytes(await doc.save());
      await Share.shareXFiles([XFile(file.path)], text: 'Kirayanama — $property');
      if (mounted) showSnack(context, 'PDF generated and shared');
    } catch (e) {
      if (!mounted) return;
      showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Kirayanama'), content: SingleChildScrollView(child: Text(agreementText(tenant, property, rent, security))), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))]));
    }
  }

  @override
  Widget build(BuildContext context) {
    final unitId = ModalRoute.of(context)?.settings.arguments as String? ?? 'u4';
    final store = context.watch<AppStore>();
    final unit = store.unitById(unitId) ?? store.units.first;
    return Scaffold(
      appBar: AppBar(title: const Text('Agreement Generator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wrap(spacing: 8, children: const [
            Chip(label: Text('Sindh & Punjab Tenancy Compliant'), backgroundColor: AppColors.mint),
            Chip(label: Text('e-Stamp Ready'), backgroundColor: AppColors.paleBlue),
          ]),
          const SizedBox(height: 12),
          const Text('Kirayanama Generator', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const Text('کرایہ نامہ — باوقار اور قانونی', style: TextStyle(fontSize: 15)),
          const SizedBox(height: 12),
          appCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(unit.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            Text('${unit.tenantName} • ${unit.location}', style: const TextStyle(color: AppColors.textMuted)),
          ])),
          const SizedBox(height: 12),
          const Text('Lease Terms', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          FilterChips(options: const ['11 Months', '24 Months'], selected: term, onSelected: (v) => setState(() => term = v)),
          const SizedBox(height: 8),
          const Text('Notice Period', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          FilterChips(options: const ['1 Mo', '2 Mo'], selected: notice, onSelected: (v) => setState(() => notice = v)),
          const SizedBox(height: 12),
          appCard(child: Column(children: [
            _row('Monthly Rent', fmtRs(unit.rent)),
            _row('Due Date', '5th of month'),
            _row('Security', fmtRs(unit.security)),
            _row('Escalation', '+10% per year'),
            _row('Term', '$term • 01 Sep 2025 – 31 Jul 2026'),
            _row('Notice', notice),
            _row('Utilities', 'Tenant pays actual usage'),
          ])),
          const SizedBox(height: 12),
          appCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Stamp Paper Preview', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text('GOVT E-STAMP REF #2025-PB-991204', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
            const Text('Stamp Duty: Rs. 1,200', style: TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 8),
            Text(agreementText(unit.tenantName, unit.title, unit.rent, unit.security), style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ])),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: PrimaryButton(label: 'Download PDF', onPressed: () => downloadPdf(unit.tenantName, unit.title, unit.rent, unit.security))),
            const SizedBox(width: 10),
            Expanded(child: MintButton(label: 'Share via WhatsApp', onPressed: () => WhatsAppService.openChat(context, unit.tenantPhone, 'Kirayanama for ${unit.title} — ${fmtRs(unit.rent)}/month, $term, Security ${fmtRs(unit.security)}. e-Stamp Ref #2025-PB-991204. – Kiraya Manager'))),
          ]),
          const SizedBox(height: 10),
          OutlinedButton.icon(onPressed: () { Clipboard.setData(ClipboardData(text: agreementText(unit.tenantName, unit.title, unit.rent, unit.security))); showSnack(context, 'Agreement text copied'); }, icon: const Icon(Icons.copy), label: const Text('Copy Agreement Text')),
        ]),
      ),
    );
  }

  Widget _row(String k, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(k, style: const TextStyle(color: AppColors.textMuted)), Text(v, style: const TextStyle(fontWeight: FontWeight.w600))]));
}
