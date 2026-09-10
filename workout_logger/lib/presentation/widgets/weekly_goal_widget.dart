import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/weekly_goal_provider.dart';
import '../../data/providers/workout_provider.dart';
import '../theme/app_theme.dart';
import 'custom_card.dart';
import 'goal_settings_bottom_sheet.dart';

class WeeklyGoalWidget extends StatelessWidget {
  const WeeklyGoalWidget({Key? key}) : super(key: key);

  static const _dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S']; // index-based, rotated with firstDayOfWeek

  List<DateTime> _computeWeekDates(int firstDayOfWeek) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayIndex = today.weekday % 7; // Sunday(7)->0 ... Saturday(6)->6
    final diff = (todayIndex - firstDayOfWeek + 7) % 7;
    final weekStart = today.subtract(Duration(days: diff));
    return List.generate(7, (i) => weekStart.add(Duration(days: i)));
  }

  bool _hasWorkoutOnDate(List workouts, DateTime date) {
    return workouts.any((w) => w.date.year == date.year && w.date.month == date.month && w.date.day == date.day);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<WeeklyGoalProvider, WorkoutProvider>(
      builder: (context, goalProvider, workoutProvider, _) {
        final weekDates = _computeWeekDates(goalProvider.firstDayOfWeek);
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        int completedCount = 0;
        for (final d in weekDates) {
          if (!d.isAfter(today) && _hasWorkoutOnDate(workoutProvider.workouts, d)) {
            completedCount++;
          }
        }

        return CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Weekly Goal', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary(context))),
                  Row(
                    children: [
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.lime),
                          children: [
                            TextSpan(text: '$completedCount'),
                            TextSpan(text: '/${goalProvider.targetDays}', style: TextStyle(color: AppTheme.textSecondary(context), fontWeight: FontWeight.normal)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => showModalBottomSheet(
                          context: context,
                          backgroundColor: AppTheme.card(context),
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                          builder: (_) => const GoalSettingsBottomSheet(),
                        ),
                        child: Icon(Icons.edit_outlined, size: 16, color: AppTheme.textSecondary(context)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: weekDates.map((d) {
                  final isToday = d.year == today.year && d.month == today.month && d.day == today.day;
                  final isFuture = d.isAfter(today);
                  final hasWorkout = !isFuture && _hasWorkoutOnDate(workoutProvider.workouts, d);

                  Widget circle;
                  if (hasWorkout) {
                    circle = Container(
                      width: 34, height: 34,
                      decoration: const BoxDecoration(color: AppTheme.lime, shape: BoxShape.circle),
                      child: const Icon(Icons.check, size: 18, color: Colors.black),
                    );
                  } else if (isToday) {
                    circle = Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppTheme.lime, width: 1.5)),
                      alignment: Alignment.center,
                      child: Text('${d.day}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.lime)),
                    );
                  } else {
                    circle = Container(
                      width: 34, height: 34,
                      alignment: Alignment.center,
                      child: Text(
                        '${d.day}',
                        style: TextStyle(fontSize: 12, color: isFuture ? AppTheme.textSecondary(context).withOpacity(0.5) : AppTheme.textSecondary(context)),
                      ),
                    );
                  }
                  return circle;
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}