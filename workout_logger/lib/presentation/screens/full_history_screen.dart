import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/workout_provider.dart';
import '../../data/providers/nutrition_provider.dart';
import '../../data/models/workout_model.dart';
import '../../data/models/nutrition_model.dart';
import '../widgets/custom_card.dart';
import '../widgets/workout_history_card.dart';
import '../widgets/nutrition_history_card.dart';
import '../theme/app_theme.dart';

enum _FullHistoryTab { workout, nutrition }

class FullHistoryScreen extends StatefulWidget {
  final int initialTabIndex; // 0 = workout, 1 = nutrition
  const FullHistoryScreen({Key? key, this.initialTabIndex = 0}) : super(key: key);

  @override
  State<FullHistoryScreen> createState() => _FullHistoryScreenState();
}

class _FullHistoryScreenState extends State<FullHistoryScreen> {
  late _FullHistoryTab _historyTab;

  @override
  void initState() {
    super.initState();
    _historyTab = widget.initialTabIndex == 1 ? _FullHistoryTab.nutrition : _FullHistoryTab.workout;
  }

  Widget _historyTabButton(String label, _FullHistoryTab tab) {
    final selected = _historyTab == tab;
    return GestureDetector(
      onTap: () => setState(() => _historyTab = tab),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: selected ? AppTheme.lime : AppTheme.card(context), borderRadius: BorderRadius.circular(24)),
        child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? Colors.black : AppTheme.textPrimary(context))),
      ),
    );
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

  Widget _buildFullWorkoutHistory(List<WorkoutModel> workouts) {
    if (workouts.isEmpty) {
      return CustomCard(child: Text('No workouts logged yet', style: TextStyle(color: AppTheme.textSecondary(context))));
    }

    final Map<String, List<WorkoutModel>> grouped = {};
    for (final w in workouts) {
      final key = '${w.date.year}-${w.date.month.toString().padLeft(2, '0')}-${w.date.day.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(key, () => []).add(w);
    }
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Column(
      children: sortedKeys.map((key) {
        final entries = grouped[key]!;
        final date = entries.first.date;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: WorkoutHistoryCard(dateLabel: _formatDateHeader(date), entries: entries),
        );
      }).toList(),
    );
  }

  Widget _buildFullNutritionHistory(List<NutritionModel> nutrition) {
    if (nutrition.isEmpty) {
      return CustomCard(child: Text('No meals logged yet', style: TextStyle(color: AppTheme.textSecondary(context))));
    }

    final Map<String, List<NutritionModel>> grouped = {};
    for (final n in nutrition) {
      final key = '${n.date.year}-${n.date.month.toString().padLeft(2, '0')}-${n.date.day.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(key, () => []).add(n);
    }
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Column(
      children: sortedKeys.map((key) {
        final entries = grouped[key]!;
        final date = entries.first.date;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: NutritionHistoryCard(dateLabel: _formatDateHeader(date), entries: entries),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Full History'), centerTitle: true, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Everything you\'ve logged — no limit.', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(context))),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _historyTabButton('Workout', _FullHistoryTab.workout)),
                const SizedBox(width: 10),
                Expanded(child: _historyTabButton('Nutrition', _FullHistoryTab.nutrition)),
              ],
            ),
            const SizedBox(height: 14),
            if (_historyTab == _FullHistoryTab.workout)
              Consumer<WorkoutProvider>(builder: (context, workoutProvider, _) => _buildFullWorkoutHistory(workoutProvider.workouts))
            else
              Consumer<NutritionProvider>(builder: (context, nutritionProvider, _) => _buildFullNutritionHistory(nutritionProvider.nutrition)),
          ],
        ),
      ),
    );
  }
}