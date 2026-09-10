import '../../data/models/workout_model.dart';

enum ChartRange { sevenDays, thirtyDays, threeMonths, sixMonths, oneYear }

class PerformancePoint {
  final String label;
  final double volume;
  final double oneRM;
  PerformancePoint({required this.label, required this.volume, required this.oneRM});
}

class _Bucket {
  final DateTime start;
  final DateTime end;
  final String label;
  _Bucket({required this.start, required this.end, required this.label});
}

class ChartDataHelper {
  static const List<String> monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  static const List<String> dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  static DateTime startDateForRange(ChartRange range) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (range) {
      case ChartRange.sevenDays:
        return today.subtract(const Duration(days: 6));
      case ChartRange.thirtyDays:
        return today.subtract(const Duration(days: 27));
      case ChartRange.threeMonths:
        return today.subtract(const Duration(days: 90));
      case ChartRange.sixMonths:
        return DateTime(now.year, now.month - 5, 1);
      case ChartRange.oneYear:
        return DateTime(now.year, now.month - 11, 1);
    }
  }

  static List<PerformancePoint> buildSeries(List<WorkoutModel> workouts, ChartRange range) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    List<_Bucket> buckets;

    if (range == ChartRange.sevenDays) {
      buckets = List.generate(7, (i) {
        final date = today.subtract(Duration(days: 6 - i));
        return _Bucket(start: date, end: date.add(const Duration(days: 1)), label: dayNames[date.weekday - 1]);
      });
    } else if (range == ChartRange.sixMonths || range == ChartRange.oneYear) {
      final monthCount = range == ChartRange.sixMonths ? 6 : 12;
      buckets = List.generate(monthCount, (i) {
        final offset = monthCount - 1 - i;
        final monthDate = DateTime(now.year, now.month - offset, 1);
        final nextMonth = DateTime(monthDate.year, monthDate.month + 1, 1);
        return _Bucket(start: monthDate, end: nextMonth, label: monthNames[monthDate.month - 1]);
      });
    } else {
      final totalDays = range == ChartRange.thirtyDays ? 28 : 91;
      final weekCount = totalDays ~/ 7;
      buckets = List.generate(weekCount, (i) {
        final offset = weekCount - 1 - i;
        final weekStart = today.subtract(Duration(days: (offset + 1) * 7 - 1));
        final weekEnd = weekStart.add(const Duration(days: 7));
        return _Bucket(start: weekStart, end: weekEnd, label: 'W${i + 1}');
      });
    }

    return buckets.map((b) {
      double volume = 0;
      double bestOneRM = 0;
      for (final w in workouts) {
        if (!w.date.isBefore(b.start) && w.date.isBefore(b.end)) {
          volume += w.calculateVolume();
          final oneRM = w.weight * (1 + w.reps / 30);
          if (oneRM > bestOneRM) bestOneRM = oneRM;
        }
      }
      return PerformancePoint(label: b.label, volume: volume, oneRM: bestOneRM);
    }).toList();
  }
}