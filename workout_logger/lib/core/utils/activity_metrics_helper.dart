import '../../data/models/workout_model.dart';

enum ActivityRange { day, week, month }

class ActivityMetrics {
  final int activeMinutes;
  final int estimatedCaloriesBurned;
  ActivityMetrics({required this.activeMinutes, required this.estimatedCaloriesBurned});
}

class ActivityMetricsHelper {
  static DateTime startDateForRange(ActivityRange range) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (range) {
      case ActivityRange.day:
        return today;
      case ActivityRange.week:
        final daysFromMonday = today.weekday - 1;
        return today.subtract(Duration(days: daysFromMonday));
      case ActivityRange.month:
        return DateTime(now.year, now.month, 1);
    }
  }

  static ActivityMetrics compute(List<WorkoutModel> workouts, ActivityRange range, double? userWeightKg) {
    final start = startDateForRange(range);
    final filtered = workouts.where((w) => !w.date.isBefore(start)).toList();

    int activeMinutes = 0;
    for (final w in filtered) {
      activeMinutes += w.duration ?? 0;
    }

    final weight = userWeightKg ?? 70;
    const met = 5.0;
    final hours = activeMinutes / 60;
    final calories = (met * weight * hours).round();

    return ActivityMetrics(activeMinutes: activeMinutes, estimatedCaloriesBurned: calories);
  }
}