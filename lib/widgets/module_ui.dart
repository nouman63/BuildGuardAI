import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ModuleHeading extends StatelessWidget {
  final String title, subtitle;
  const ModuleHeading(this.title, this.subtitle, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -.6)),
        const SizedBox(height: 6),
        Text(subtitle,
            style: const TextStyle(
                fontSize: 12.5, color: AppColors.textSecondary, height: 1.65)),
      ]));
}

class ModulePanel extends StatelessWidget {
  final String? title;
  final IconData? icon;
  final List<Widget> children;
  const ModulePanel({super.key, this.title, this.icon, required this.children});
  @override
  Widget build(BuildContext context) => Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.primarySoftStrong),
          boxShadow: [
            BoxShadow(
                color: AppColors.primary.withValues(alpha: .04),
                blurRadius: 16,
                offset: const Offset(0, 4))
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (title != null) ...[
          Row(children: [
            if (icon != null) ...[
              Icon(icon, color: AppColors.primary, size: 19),
              const SizedBox(width: 9)
            ],
            Expanded(
                child: Text(title!,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w800)))
          ]),
          const SizedBox(height: 18)
        ],
        ...children,
      ]));
}

class ModuleButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData icon;
  const ModuleButton(this.label,
      {super.key,
      required this.onPressed,
      this.icon = Icons.arrow_forward_rounded});
  @override
  Widget build(BuildContext context) => SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 18),
          label: Text(label),
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              textStyle:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w700))));
}

class Eyebrow extends StatelessWidget {
  final String text;
  const Eyebrow(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Text(text.toUpperCase(),
      style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
          color: AppColors.textMuted));
}
