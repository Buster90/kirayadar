import 'package:flutter/material.dart';
import '../theme.dart';
import '../models.dart';

Widget appCard({required Widget child, EdgeInsetsGeometry padding = const EdgeInsets.all(16)}) {
  return Container(
    width: double.infinity,
    padding: padding,
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.border),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
    ),
    child: child,
  );
}

Widget statusChip(UnitStatus s) {
  final color = s == UnitStatus.paid ? AppColors.green : s == UnitStatus.overdue ? AppColors.red : s == UnitStatus.due ? AppColors.amber : AppColors.textMuted;
  final bg = s == UnitStatus.paid ? const Color(0xFFE6F4EA) : s == UnitStatus.overdue ? const Color(0xFFFDECEA) : s == UnitStatus.due ? const Color(0xFFFEF3C7) : AppColors.border;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
    child: Text(s.label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
  );
}

class FilterChips extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;
  const FilterChips({super.key, required this.options, required this.selected, required this.onSelected});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: options.map((o) {
        final sel = o == selected;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(o, style: TextStyle(color: sel ? Colors.white : AppColors.text, fontWeight: FontWeight.w600)),
            selected: sel,
            selectedColor: AppColors.primary,
            backgroundColor: Colors.white,
            side: const BorderSide(color: AppColors.border2),
            showCheckmark: false,
            onSelected: (_) => onSelected(o),
          ),
        );
      }).toList()),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? color;
  const PrimaryButton({super.key, required this.label, required this.onPressed, this.color});
  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: color ?? AppColors.primary),
          onPressed: onPressed,
          child: Text(label),
        ),
      );
}

class MintButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const MintButton({super.key, required this.label, required this.onPressed});
  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.mint, foregroundColor: AppColors.primary),
          onPressed: onPressed,
          child: Text(label),
        ),
      );
}

void showSnack(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}
