import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/water_entry_provider.dart';
import '../../data/providers/user_provider.dart';
import '../../core/utils/nutrition_goals_helper.dart';
import '../theme/app_theme.dart';
import 'custom_card.dart';

class HydrationTrackerWidget extends StatelessWidget {
  const HydrationTrackerWidget({Key? key}) : super(key: key);

  String _statusMessage(double fraction) {
    if (fraction <= 0) return 'Let\'s get started 💧';
    if (fraction < 0.4) return 'Nice start — keep sipping';
    if (fraction < 0.8) return 'Halfway there! 🌊';
    if (fraction < 1) return 'Almost fully hydrated';
    return 'Fully hydrated! 🎉';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<WaterEntryProvider, UserProvider>(
      builder: (context, waterProvider, userProvider, _) {
        final goals = NutritionGoalsHelper.computeGoals(userProvider.currentUser);
        final target = goals.waterMl;
        final current = waterProvider.todayTotalMl;
        final fraction = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
        final trackColor = AppTheme.isDark(context) ? Colors.white.withOpacity(0.07) : Colors.black.withOpacity(0.06);

        return CustomCard(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('DAILY HYDRATION', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary(context))),
                  Text('Target: ${target}ml', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary(context))),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 148,
                height: 148,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 148,
                      height: 148,
                      child: CircularProgressIndicator(value: 1, strokeWidth: 12, valueColor: AlwaysStoppedAnimation<Color>(trackColor)),
                    ),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: fraction),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOut,
                      builder: (context, value, _) {
                        return SizedBox(
                          width: 148,
                          height: 148,
                          child: CircularProgressIndicator(
                            value: value,
                            strokeWidth: 12,
                            strokeCap: StrokeCap.round,
                            backgroundColor: Colors.transparent,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.cyan),
                          ),
                        );
                      },
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('💧', style: TextStyle(fontSize: 20)),
                        const SizedBox(height: 4),
                        Text('$current', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary(context))),
                        Text('ml today', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary(context))),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(_statusMessage(fraction), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.cyan)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _quickAddChip(context, '+150ml', () => context.read<WaterEntryProvider>().addWater(1, 150))),
                  const SizedBox(width: 8),
                  Expanded(child: _quickAddChip(context, '+250ml', () => context.read<WaterEntryProvider>().addWater(1, 250))),
                  const SizedBox(width: 8),
                  Expanded(child: _quickAddChip(context, '+500ml', () => context.read<WaterEntryProvider>().addWater(1, 500))),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _quickAddChip(BuildContext context, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.cyan.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.cyan.withOpacity(0.4)),
        ),
        alignment: Alignment.center,
        child: Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppTheme.cyan)),
      ),
    );
  }
}