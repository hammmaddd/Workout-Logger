import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/workout_model.dart';
import '../../data/models/workout_template_model.dart';
import '../../data/providers/workout_provider.dart';
import '../../data/providers/workout_session_provider.dart';
import '../widgets/app_button.dart';
import '../widgets/custom_card.dart';
import '../widgets/weekly_goal_widget.dart';
import '../widgets/challenge_carousel.dart';
import '../widgets/category_chips.dart';
import '../widgets/workout_routine_list.dart';
import '../theme/app_theme.dart';
import 'active_workout_session_screen.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({Key? key}) : super(key: key);

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  String _selectedCategory = 'Abs';

  Future<void> _startTemplate(BuildContext context, WorkoutTemplate template) async {
    Navigator.of(context).pop();
    await context.read<WorkoutSessionProvider>().startSessionFromTemplate(1, template);
    if (!context.mounted) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ActiveWorkoutSessionScreen()));
  }

  void _showTemplatePreview(BuildContext context, WorkoutTemplate template) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card(context),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(template.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary(sheetContext))),
              const SizedBox(height: 4),
              Text('${template.durationMinutes} mins · ${template.exerciseCount} Exercises',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(sheetContext))),
              const SizedBox(height: 16),
              Text('EXERCISES', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary(sheetContext))),
              const SizedBox(height: 8),
              ...template.exercises.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.name, style: TextStyle(fontSize: 13.5, color: AppTheme.textPrimary(sheetContext))),
                    Text('${e.sets} × ${e.reps}', style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary(sheetContext))),
                  ],
                ),
              )),
              const SizedBox(height: 20),
              AppButton(label: 'Start Workout', onPressed: () => _startTemplate(context, template)),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Workout', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary(context))),
          const SizedBox(height: 16),
          const WeeklyGoalWidget(),
          const SizedBox(height: 24),
          Text('Challenges', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary(context))),
          const SizedBox(height: 12),
          ChallengeCarousel(onStart: (template) => _showTemplatePreview(context, template)),
          const SizedBox(height: 24),
          Text('Body Focus', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary(context))),
          const SizedBox(height: 12),
          CategoryChips(selectedCategory: _selectedCategory, onCategorySelected: (c) => setState(() => _selectedCategory = c)),
          const SizedBox(height: 14),
          WorkoutRoutineList(category: _selectedCategory, onSelect: (template) => _showTemplatePreview(context, template)),
        ],
      ),
    );
  }
}