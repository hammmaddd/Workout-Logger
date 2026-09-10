import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'custom_card.dart';

class MetricCardWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;
  final Color accent;
  final VoidCallback? onTap;

  const MetricCardWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
    required this.accent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: accent.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: Icon(icon, color: accent, size: 16),
              ),
              if (onTap != null)
                Icon(Icons.chevron_right, size: 16, color: AppTheme.textSecondary(context)),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary(context))),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, color: AppTheme.textSecondary(context))),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle!, style: TextStyle(fontSize: 9, color: accent)),
          ],
        ],
      ),
    );
  }
}