import 'package:flutter/material.dart';
import '../../core/constants/workout_template_catalog.dart';
import '../../data/models/workout_template_model.dart';
import '../theme/app_theme.dart';

class ChallengeCarousel extends StatelessWidget {
  final void Function(WorkoutTemplate template) onStart;

  const ChallengeCarousel({Key? key, required this.onStart}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: WorkoutTemplateCatalog.challenges.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final template = WorkoutTemplateCatalog.challenges[index];
          return _ChallengeCard(template: template, onStart: () => onStart(template));
        },
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  final WorkoutTemplate template;
  final VoidCallback onStart;

  const _ChallengeCard({required this.template, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.lime,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
            child: Text('${template.durationMinutes} MIN · ${template.exerciseCount} EXERCISES',
                style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.black)),
          ),
          const SizedBox(height: 12),
          Text(template.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black), maxLines: 2),
          const SizedBox(height: 8),
          if (template.description != null)
            Text(template.description!, style: TextStyle(fontSize: 11.5, color: Colors.black.withOpacity(0.7)), maxLines: 2, overflow: TextOverflow.ellipsis),
          const Spacer(),
          Wrap(
            spacing: 6,
            children: template.tags.map((t) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Text(t, style: const TextStyle(fontSize: 9.5, color: Colors.black)),
            )).toList(),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onStart,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 11),
              alignment: Alignment.center,
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(24)),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Start Workout', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.lime)),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward, size: 14, color: AppTheme.lime),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}