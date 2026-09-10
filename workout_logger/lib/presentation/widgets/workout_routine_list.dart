import 'package:flutter/material.dart';
import '../../core/constants/workout_template_catalog.dart';
import '../../data/models/workout_template_model.dart';
import '../theme/app_theme.dart';
import 'custom_card.dart';

class WorkoutRoutineList extends StatelessWidget {
  final String category;
  final void Function(WorkoutTemplate template) onSelect;

  const WorkoutRoutineList({Key? key, required this.category, required this.onSelect}) : super(key: key);

  static const _categoryIcons = {
    'Abs': Icons.self_improvement,
    'Arm': Icons.fitness_center,
    'Chest': Icons.accessibility_new,
    'Leg': Icons.directions_run,
    'Shoulder': Icons.sports_gymnastics,
    'Full Body': Icons.whatshot,
  };

  @override
  Widget build(BuildContext context) {
    final templates = WorkoutTemplateCatalog.byCategory(category);

    if (templates.isEmpty) {
      return CustomCard(child: Text('No routines in this category yet.', style: TextStyle(color: AppTheme.textSecondary(context))));
    }

    return Column(
      children: templates.map((t) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: WorkoutRoutineCard(
          template: t,
          icon: _categoryIcons[t.category] ?? Icons.fitness_center,
          onTap: () => onSelect(t),
        ),
      )).toList(),
    );
  }
}

class WorkoutRoutineCard extends StatelessWidget {
  final WorkoutTemplate template;
  final IconData icon;
  final VoidCallback onTap;

  const WorkoutRoutineCard({Key? key, required this.template, required this.icon, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: AppTheme.lime.withOpacity(0.12), shape: BoxShape.circle),
            child: Icon(icon, color: AppTheme.lime, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(template.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary(context))),
                const SizedBox(height: 3),
                Text('${template.durationMinutes} mins · ${template.exerciseCount} Exercises',
                    style: TextStyle(fontSize: 11.5, color: AppTheme.textSecondary(context))),
                const SizedBox(height: 5),
                Row(
                  children: List.generate(3, (i) => Padding(
                    padding: const EdgeInsets.only(right: 3),
                    child: Icon(Icons.bolt, size: 14, color: i < template.difficulty ? AppTheme.lime : AppTheme.textSecondary(context).withOpacity(0.3)),
                  )),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppTheme.textSecondary(context)),
        ],
      ),
    );
  }
}