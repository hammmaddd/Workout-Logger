import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/workout_provider.dart';
import '../../core/utils/personal_records_helper.dart';
import '../widgets/custom_card.dart';
import '../theme/app_theme.dart';

class PersonalRecordsScreen extends StatelessWidget {
  const PersonalRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personal Records'), centerTitle: true, elevation: 0),
      body: Consumer<WorkoutProvider>(
        builder: (context, workoutProvider, _) {
          final prs = PersonalRecordsHelper.compute(workoutProvider.workouts);

          if (prs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No personal records yet — log a workout to start tracking.',
                  style: TextStyle(color: AppTheme.textSecondary(context)),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: prs.length,
            itemBuilder: (context, index) {
              final pr = prs[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(pr.exerciseName,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                overflow: TextOverflow.ellipsis),
                          ),
                          if (pr.isRecentPR)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.success.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text('🎉 New PR', style: TextStyle(fontSize: 10, color: AppTheme.success)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _prStat(context, 'Weight', '${pr.heaviestWeight.toStringAsFixed(1)}${pr.weightUnit}')),
                          Expanded(child: _prStat(context, 'Reps', '${pr.maxReps}')),
                          Expanded(child: _prStat(context, '1RM', '${pr.bestOneRM.toStringAsFixed(1)}${pr.weightUnit}')),
                          Expanded(child: _prStat(context, 'Volume', '${pr.bestVolume.toStringAsFixed(0)}${pr.weightUnit}')),
                        ],
                      ),
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

  Widget _prStat(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: AppTheme.textSecondary(context))),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}