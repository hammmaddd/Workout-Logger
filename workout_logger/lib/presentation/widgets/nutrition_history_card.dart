import 'package:flutter/material.dart';
import '../../data/models/nutrition_model.dart';
import '../theme/app_theme.dart';
import 'custom_card.dart';

class NutritionHistoryCard extends StatelessWidget {
  final String dateLabel;
  final List<NutritionModel> entries;

  const NutritionHistoryCard({
    Key? key,
    required this.dateLabel,
    required this.entries,
  }) : super(key: key);

  static const _mealOrder = ['breakfast', 'lunch', 'dinner', 'snack'];
  static const _mealLabels = {
    'breakfast': 'Breakfast',
    'lunch': 'Lunch',
    'dinner': 'Dinner',
    'snack': 'Snack',
  };

  @override
  Widget build(BuildContext context) {
    final totalCalories = entries.fold(0, (sum, n) => sum + n.getTotalCalories());

    final Map<String, List<NutritionModel>> grouped = {};
    for (final n in entries) {
      grouped.putIfAbsent(n.mealType, () => []).add(n);
    }

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(dateLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.lime)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.lime.withOpacity(0.12),
                  border: Border.all(color: AppTheme.lime.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$totalCalories kcal',
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppTheme.lime),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final mealType in _mealOrder)
            if (grouped[mealType] != null && grouped[mealType]!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _mealLabels[mealType]!.toUpperCase(),
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textSecondary(context), letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 6),
                    ...grouped[mealType]!.map((n) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  n.foodName,
                                  style: TextStyle(fontSize: 13.5, color: AppTheme.textPrimary(context)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '${n.getTotalCalories()} kcal',
                                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppTheme.textSecondary(context)),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}