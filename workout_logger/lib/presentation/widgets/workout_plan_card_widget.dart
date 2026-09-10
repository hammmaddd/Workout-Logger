import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class WorkoutPlanCardWidget extends StatelessWidget {
  final String title;
  final int exerciseCount;
  final int durationMinutes;
  final bool isPrimary;
  final VoidCallback onStartPressed;

  const WorkoutPlanCardWidget({
    super.key,
    required this.title,
    required this.exerciseCount,
    required this.durationMinutes,
    required this.onStartPressed,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isPrimary ? AppTheme.lime : AppTheme.card(context);
    final fg = isPrimary ? Colors.black : AppTheme.textPrimary(context);
    final fgMuted = isPrimary ? Colors.black.withValues(alpha: 0.6) : AppTheme.textSecondary(context);
    final badgeColor = isPrimary ? Colors.white.withValues(alpha: 0.35) : Colors.white.withValues(alpha: 0.08);

    return Container(
      width: 240,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(28),
        border: isPrimary ? null : Border.all(color: AppTheme.divider(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Workout Plan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fgMuted)),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle),
                child: Icon(Icons.fitness_center, color: fg, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(title,
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: fg, height: 1.15),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 14),
          Text('$exerciseCount Exercises', style: TextStyle(fontSize: 12.5, color: fgMuted)),
          const SizedBox(height: 3),
          Text('$durationMinutes min', style: TextStyle(fontSize: 12.5, color: fgMuted)),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: onStartPressed,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isPrimary ? Colors.black : AppTheme.lime,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Start Workout',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isPrimary ? Colors.white : Colors.black)),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 15, color: isPrimary ? Colors.white : Colors.black),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}