import 'package:flutter/material.dart';
import '../../data/models/workout_model.dart';
import '../theme/app_theme.dart';
import 'custom_card.dart';

class WorkoutHistoryCard extends StatelessWidget {
  final String dateLabel;
  final List<WorkoutModel> entries;

  const WorkoutHistoryCard({
    Key? key,
    required this.dateLabel,
    required this.entries,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dateLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.lime)),
          const SizedBox(height: 10),
          for (int i = 0; i < entries.length; i++) ...[
            _exerciseRow(context, entries[i]),
            if (i != entries.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Divider(height: 1, thickness: 1, color: AppTheme.divider(context)),
              ),
          ],
        ],
      ),
    );
  }

  Widget _exerciseRow(BuildContext context, WorkoutModel w) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            w.exerciseName,
            style: TextStyle(fontSize: 13.5, color: AppTheme.textPrimary(context)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '${w.sets}×${w.reps} @ ${w.weight}${w.weightUnit}',
          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppTheme.textSecondary(context)),
        ),
      ],
    );
  }
}