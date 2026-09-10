import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/user_provider.dart';
import '../widgets/custom_card.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _goalLabels = {
    'strength': 'Strength',
    'weight_loss': 'Fat Loss',
    'muscle_gain': 'Muscle Gain',
    'maintenance': 'Maintenance',
    'general_fitness': 'General Fitness',
    'endurance': 'Endurance',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: true, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Consumer<UserProvider>(
          builder: (context, userProvider, _) {
            final user = userProvider.currentUser;
            if (user == null) {
              return const Center(child: Text('No profile'));
            }

            final goalLabel = user.fitnessGoal != null
                ? (_goalLabels[user.fitnessGoal] ?? user.fitnessGoal!)
                : '—';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('BASICS', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary(context))),
                      const SizedBox(height: 12),
                      _row(context, 'Name', user.name),
                      _row(context, 'Age', user.age?.toString() ?? '—'),
                      _row(context, 'Gender', user.gender != null ? _capitalize(user.gender!) : '—'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('BODY METRICS', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary(context))),
                      const SizedBox(height: 12),
                      _row(context, 'Height', user.height != null ? '${user.height} cm' : '—'),
                      _row(context, 'Weight', user.weight != null ? '${user.weight} kg' : '—'),
                      _row(context, 'Target Weight', user.targetWeight != null ? '${user.targetWeight} kg' : '—'),
                      Divider(height: 24, color: AppTheme.divider(context)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('BMI: ${userProvider.bmi.toStringAsFixed(1)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.lime.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(userProvider.bmiCategory,
                                style: const TextStyle(fontSize: 11, color: AppTheme.lime, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TRAINING PROFILE', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary(context))),
                      const SizedBox(height: 12),
                      _row(context, 'Goal', goalLabel),
                      _row(context, 'Workout Days/Week', user.workoutDaysPerWeek ?? '—'),
                      _row(context, 'Activity Level', user.activityLevel ?? '—'),
                      _row(context, 'Experience', user.trainingExperience ?? '—'),
                      _row(context, 'Preferred Time', user.preferredWorkoutTime ?? '—'),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _capitalize(String s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  Widget _row(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: AppTheme.textSecondary(context))),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}