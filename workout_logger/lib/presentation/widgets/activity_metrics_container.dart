import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ActivityMetricsContainer extends StatelessWidget {
  final int workoutsThisWeek;
  final int caloriesThisWeek;
  final int activeMinutesThisWeek;

  const ActivityMetricsContainer({
    super.key,
    required this.workoutsThisWeek,
    required this.caloriesThisWeek,
    required this.activeMinutesThisWeek,
  });

  String _formatMinutes(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _metric(context, Icons.fitness_center, 'Workouts', '$workoutsThisWeek'),
          _metric(context, Icons.local_fire_department, 'Calories', '$caloriesThisWeek'),
          _metric(context, Icons.timer_outlined, 'Active Time', _formatMinutes(activeMinutesThisWeek)),
        ],
      ),
    );
  }

  Widget _metric(BuildContext context, IconData icon, String categoryLabel, String value) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.lime, size: 22),
        const SizedBox(height: 8),
        Text(categoryLabel, style: TextStyle(fontSize: 11, color: AppTheme.textSecondary(context))),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary(context))),
        const SizedBox(height: 2),
        Text('This Week', style: TextStyle(fontSize: 9.5, color: AppTheme.textSecondary(context).withValues(alpha: 0.7))),
      ],
    );
  }
}