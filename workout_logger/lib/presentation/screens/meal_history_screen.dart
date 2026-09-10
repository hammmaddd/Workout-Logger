import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/nutrition_provider.dart';
import '../../data/providers/workout_provider.dart';
import '../../data/providers/user_provider.dart';
import '../../data/models/workout_model.dart';
import '../widgets/custom_card.dart';
import '../theme/app_theme.dart';

class MealHistoryScreen extends StatelessWidget {
  const MealHistoryScreen({Key? key}) : super(key: key);

  int _estimateCaloriesBurnedForDate(List<WorkoutModel> workouts, DateTime date, double? weightKg) {
    final dayWorkouts = workouts.where((w) => w.date.year == date.year && w.date.month == date.month && w.date.day == date.day).toList();
    if (dayWorkouts.isEmpty) return 0;
    final weight = weightKg ?? 70;
    const met = 5.0;
    int totalMinutes = 0;
    for (final w in dayWorkouts) {
      totalMinutes += w.duration ?? 20;
    }
    final hours = totalMinutes / 60;
    return (met * weight * hours).round();
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meal History'), centerTitle: true, elevation: 0),
      body: Consumer3<NutritionProvider, WorkoutProvider, UserProvider>(
        builder: (context, nutritionProvider, workoutProvider, userProvider, _) {
          final dateKeys = <String>{};
          for (final n in nutritionProvider.nutrition) {
            dateKeys.add('${n.date.year}-${n.date.month.toString().padLeft(2, '0')}-${n.date.day.toString().padLeft(2, '0')}');
          }

          if (dateKeys.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('No meals logged yet.', style: TextStyle(color: AppTheme.textSecondary(context))),
              ),
            );
          }

          final sortedKeys = dateKeys.toList()..sort((a, b) => b.compareTo(a));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedKeys.length,
            itemBuilder: (context, index) {
              final key = sortedKeys[index];
              final parts = key.split('-');
              final date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));

              final dayMeals = nutritionProvider.nutrition
                  .where((n) => n.date.year == date.year && n.date.month == date.month && n.date.day == date.day)
                  .toList();
              final consumed = dayMeals.fold(0, (sum, n) => sum + n.getTotalCalories());
              final burned = _estimateCaloriesBurnedForDate(workoutProvider.workouts, date, userProvider.currentUser?.weight);

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    backgroundColor: AppTheme.card(context),
                    collapsedBackgroundColor: AppTheme.card(context),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: Text(_formatDateHeader(date), style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary(context))),
                    subtitle: Text('$consumed kcal consumed', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(context))),
                    children: [
                      Row(
                        children: [
                          Expanded(child: _summaryTile(context, 'Consumed', consumed, AppTheme.warning)),
                          const SizedBox(width: 10),
                          Expanded(child: _summaryTile(context, 'Burned (est.)', burned, AppTheme.success)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...dayMeals.map((m) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text('${m.foodName} (${m.mealType})',
                                      style: TextStyle(fontSize: 13, color: AppTheme.textPrimary(context)), overflow: TextOverflow.ellipsis),
                                ),
                                Text('${m.getTotalCalories()} kcal', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(context))),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _summaryTile(BuildContext context, String label, int value, Color accent) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: accent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: AppTheme.textSecondary(context))),
          const SizedBox(height: 4),
          Text('$value kcal', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: accent)),
        ],
      ),
    );
  }
}