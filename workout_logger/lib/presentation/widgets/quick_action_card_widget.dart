import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class QuickActionCardWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;

  const QuickActionCardWidget({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.accentColor = AppTheme.lime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 190,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.divider(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: accentColor.withOpacity(0.16), shape: BoxShape.circle),
              child: Icon(icon, color: accentColor, size: 22),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppTheme.textPrimary(context), height: 1.15),
                    maxLines: 2),
                const SizedBox(height: 6),
                Text(subtitle,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textSecondary(context)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 9),
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(30)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Open', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(width: 5),
                  const Icon(Icons.arrow_forward, size: 13, color: Colors.black),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}