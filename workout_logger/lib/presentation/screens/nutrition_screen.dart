import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/nutrition_model.dart';
import '../../data/models/saved_food_model.dart';
import '../../data/providers/nutrition_provider.dart';
import '../../data/providers/user_provider.dart';
import '../../data/providers/water_entry_provider.dart';
import '../../data/providers/saved_food_provider.dart';
import '../../core/constants/food_database.dart';
import '../../data/models/food_database_item.dart';
import '../../core/utils/nutrition_goals_helper.dart';
import '../widgets/app_button.dart';
import '../widgets/app_textfield.dart';
import '../widgets/custom_card.dart';
import '../widgets/hydration_tracker_widget.dart';
import '../theme/app_theme.dart';
import 'meal_selection_screen.dart';
import 'meal_history_screen.dart';
import 'barcode_scanner_screen.dart';
import 'ai_meal_scan_screen.dart'; // new import

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({Key? key}) : super(key: key);

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  void _showMealTypePicker(BuildContext context, {required void Function(String mealType) onSelected}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card(context),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Which meal?', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary(sheetContext))),
                  ),
                ),
                _mealTypeTile(sheetContext, 'Breakfast', 'breakfast', onSelected),
                _mealTypeTile(sheetContext, 'Lunch', 'lunch', onSelected),
                _mealTypeTile(sheetContext, 'Dinner', 'dinner', onSelected),
                _mealTypeTile(sheetContext, 'Snack', 'snack', onSelected),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _mealTypeTile(BuildContext context, String label, String value, void Function(String) onSelected) {
    return ListTile(
      title: Text(label, style: TextStyle(color: AppTheme.textPrimary(context))),
      onTap: () {
        Navigator.of(context).pop();
        onSelected(value);
      },
    );
  }

  void _showScanMethodPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card(context),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Scan method', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary(sheetContext))),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.qr_code_scanner, color: AppTheme.lime),
                  title: Text('Barcode Scan', style: TextStyle(color: AppTheme.textPrimary(sheetContext))),
                  subtitle: Text('Accurate — packaged food only', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary(sheetContext))),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _showMealTypePicker(context, onSelected: (mealType) => _startFoodScan(context, mealType));
                  },
                ),
                // Replaced the old 'Photo Guess' tile with the new 'AI Photo Scan' tile
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined, color: AppTheme.cyan),
                  title: Text('AI Photo Scan', style: TextStyle(color: AppTheme.textPrimary(sheetContext))),
                  subtitle: Text('Detects food, ingredients & calories', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary(sheetContext))),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _showMealTypePicker(context, onSelected: (mealType) {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => AiMealScanScreen(initialMealType: mealType)),
                      );
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _startFoodScan(BuildContext context, String mealType) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );
    if (result == null || !context.mounted) return;
    _showScannedFoodConfirmSheet(context, result, mealType);
  }

  void _showScannedFoodConfirmSheet(BuildContext context, dynamic food, String initialMealType) {
    double quantity = 1;
    String mealType = initialMealType;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card(context),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final totalCal = (food.caloriesPer100g * quantity).round();
            final totalProtein = food.proteinPer100g * quantity;
            return Padding(
              padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.qr_code_scanner, color: AppTheme.lime, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(food.name,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary(context)),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Per 100g · ${food.caloriesPer100g} kcal · ${food.proteinPer100g.toStringAsFixed(1)}g protein',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(context))),
                  const SizedBox(height: 20),
                  Text('Portion (x100g)', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary(context))),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        onPressed: quantity > 0.5 ? () => setSheetState(() => quantity -= 0.5) : null,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text(quantity.toStringAsFixed(1), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary(context))),
                      IconButton(
                        onPressed: () => setSheetState(() => quantity += 0.5),
                        icon: const Icon(Icons.add_circle_outline, color: AppTheme.lime),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Meal', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary(context))),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: mealType,
                    isExpanded: true,
                    items: ['breakfast', 'lunch', 'dinner', 'snack']
                        .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                    onChanged: (value) => setSheetState(() => mealType = value!),
                  ),
                  const SizedBox(height: 16),
                  CustomCard(
                    backgroundColor: AppTheme.surfaceTint(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text('$totalCal kcal', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary(context))),
                        Text('${totalProtein.toStringAsFixed(1)}g protein', style: TextStyle(color: AppTheme.textPrimary(context))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    label: 'Add to log',
                    onPressed: () {
                      final nutrition = NutritionModel(
                        userId: 1,
                        foodName: food.name,
                        calories: food.caloriesPer100g,
                        protein: food.proteinPer100g,
                        carbs: food.carbsPer100g,
                        fats: food.fatsPer100g,
                        quantity: quantity,
                        mealType: mealType,
                        date: DateTime.now(),
                      );
                      context.read<NutritionProvider>().createNutrition(nutrition);
                      Navigator.of(sheetContext).pop();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${food.name} added to $mealType')));
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nutrition', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary(context))),
          const SizedBox(height: 2),
          Text('Pakistani Food Database Enabled', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary(context))),
          const SizedBox(height: 16),
          _buildMacroCard(context),
          const SizedBox(height: 16),
          TextField(
            readOnly: true,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MealSelectionScreen())),
            decoration: const InputDecoration(
              hintText: 'Search paratha, biryani, chicken karahi...',
              prefixIcon: Icon(Icons.search, size: 20),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _actionCard(
                  context,
                  icon: Icons.add,
                  title: 'Add Meal',
                  subtitle: 'Search or browse foods',
                  onTap: () => _showMealTypePicker(context, onSelected: (mealType) {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => MealSelectionScreen(initialMealType: mealType)));
                  }),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _actionCard(
                  context,
                  icon: Icons.qr_code_scanner,
                  title: 'Food Scan',
                  subtitle: 'Barcode or photo guess',
                  onTap: () => _showScanMethodPicker(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _historyBanner(context),
          const SizedBox(height: 12),
          const HydrationTrackerWidget(),
          const SizedBox(height: 24),
          _buildLoggedMeals(context),
        ],
      ),
    );
  }

  Widget _actionCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return CustomCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppTheme.lime.withOpacity(0.12), shape: BoxShape.circle),
            child: Icon(icon, color: AppTheme.lime, size: 20),
          ),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary(context))),
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(fontSize: 11, color: AppTheme.textSecondary(context))),
        ],
      ),
    );
  }

  Widget _historyBanner(BuildContext context) {
    return CustomCard(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MealHistoryScreen())),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppTheme.cyan.withOpacity(0.12), shape: BoxShape.circle),
            child: const Icon(Icons.history, color: AppTheme.cyan, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Recent Meal History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary(context))),
                const SizedBox(height: 2),
                Text('Daily consumed vs. burned', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary(context))),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppTheme.textSecondary(context)),
        ],
      ),
    );
  }

  Widget _buildMacroCard(BuildContext context) {
    return Consumer2<NutritionProvider, UserProvider>(
      builder: (context, nutritionProvider, userProvider, _) {
        final today = DateTime.now();
        final todayMeals = nutritionProvider.nutrition
            .where((n) => n.date.year == today.year && n.date.month == today.month && n.date.day == today.day)
            .toList();

        final goals = NutritionGoalsHelper.computeGoals(userProvider.currentUser);

        int totalCalories = 0;
        double totalCarbs = 0, totalProtein = 0, totalFats = 0;
        for (final m in todayMeals) {
          totalCalories += m.getTotalCalories();
          totalProtein += m.getTotalProtein();
          totalCarbs += m.getTotalCarbs();
          totalFats += m.getTotalFats();
        }

        final carbsCal = totalCarbs * 4;
        final proteinCal = totalProtein * 4;
        final fatsCal = totalFats * 9;
        final totalMacroCal = carbsCal + proteinCal + fatsCal;

        final carbsPct = totalMacroCal > 0 ? (carbsCal / totalMacroCal * 100).round() : 0;
        final proteinPct = totalMacroCal > 0 ? (proteinCal / totalMacroCal * 100).round() : 0;
        final fatsPct = totalMacroCal > 0 ? (fatsCal / totalMacroCal * 100).round() : 0;

        return CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('DAILY MACROS STATUS', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary(context))),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary(context)),
                      children: [
                        TextSpan(text: '$totalCalories'),
                        TextSpan(text: ' / ${goals.calories} kcal',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: AppTheme.textSecondary(context))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (totalMacroCal > 0)
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    height: 8,
                    child: Row(
                      children: [
                        Expanded(flex: carbsPct.clamp(1, 100), child: Container(color: AppTheme.cyan)),
                        Expanded(flex: proteinPct.clamp(1, 100), child: Container(color: AppTheme.success)),
                        Expanded(flex: fatsPct.clamp(1, 100), child: Container(color: AppTheme.warning)),
                      ],
                    ),
                  ),
                )
              else
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Container(height: 8, color: AppTheme.surfaceTint(context)),
                ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _macroLegend(context, 'Carbs', carbsPct, totalCarbs, AppTheme.cyan),
                  _macroLegend(context, 'Protein', proteinPct, totalProtein, AppTheme.success),
                  _macroLegend(context, 'Fats', fatsPct, totalFats, AppTheme.warning),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _macroLegend(BuildContext context, String label, int pct, double grams, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$label $pct%', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary(context))),
            Text('${grams.toStringAsFixed(0)}g', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  Widget _buildLoggedMeals(BuildContext context) {
    return Consumer<NutritionProvider>(
      builder: (context, nutritionProvider, _) {
        final today = DateTime.now();
        final todayMeals = nutritionProvider.nutrition
            .where((n) => n.date.year == today.year && n.date.month == today.month && n.date.day == today.day)
            .toList();

        const mealOrder = ['breakfast', 'lunch', 'dinner', 'snack'];
        const mealLabels = {
          'breakfast': 'Breakfast',
          'lunch': 'Lunch',
          'dinner': 'Dinner',
          'snack': 'Snacks',
        };

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('LOGGED MEALS', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(context))),
            const SizedBox(height: 10),
            ...mealOrder.map((type) {
              final meals = todayMeals.where((m) => m.mealType == type).toList();
              final total = meals.fold(0, (sum, m) => sum + m.getTotalCalories());

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(mealLabels[type]!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          if (meals.isNotEmpty)
                            Text('$total kcal', style: const TextStyle(color: AppTheme.warning, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (meals.isEmpty)
                        InkWell(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => MealSelectionScreen(initialMealType: type)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.add, size: 16, color: AppTheme.lime),
                              const SizedBox(width: 6),
                              Text('Log ${mealLabels[type]}', style: const TextStyle(color: AppTheme.lime, fontSize: 13)),
                            ],
                          ),
                        )
                      else
                        ...meals.map((m) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text('• ${m.foodName} (${m.getTotalCalories()} kcal)', style: const TextStyle(fontSize: 13)),
                            )),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}