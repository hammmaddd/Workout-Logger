import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/nutrition_model.dart';
import '../../data/models/saved_food_model.dart';
import '../../data/providers/nutrition_provider.dart';
import '../../data/providers/saved_food_provider.dart';
import '../../core/constants/food_database.dart';
import '../../data/models/food_database_item.dart';
import '../widgets/app_button.dart';
import '../widgets/app_textfield.dart';
import '../widgets/custom_card.dart';
import '../theme/app_theme.dart';

class _StagedMealEntry {
  final String foodName;
  final int calories;
  final double protein;
  final double carbs;
  final double fats;
  final double quantity;
  final String mealType;

  _StagedMealEntry({
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.quantity,
    required this.mealType,
  });

  int get totalCalories => (calories * quantity).round();
}

class MealSelectionScreen extends StatefulWidget {
  final String? initialMealType;
  const MealSelectionScreen({Key? key, this.initialMealType}) : super(key: key);

  @override
  State<MealSelectionScreen> createState() => _MealSelectionScreenState();
}

class _MealSelectionScreenState extends State<MealSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  final List<_StagedMealEntry> _cart = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FoodDatabaseItem> get _filteredFoods {
    final query = _searchController.text.trim().toLowerCase();
    return PakistaniFoodDatabase.foods.where((food) {
      final matchesCategory = _selectedCategory == 'All' || food.category == _selectedCategory;
      final matchesQuery = query.isEmpty || food.name.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  String _guessMealType() {
    if (widget.initialMealType != null) return widget.initialMealType!;
    final hour = DateTime.now().hour;
    if (hour < 11) return 'breakfast';
    if (hour < 15) return 'lunch';
    if (hour < 18) return 'snack';
    return 'dinner';
  }

  Future<bool> _confirmDiscard() async {
    if (_cart.isEmpty) return true;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.card(dialogContext),
        title: Text('Discard ${_cart.length} unsaved item${_cart.length == 1 ? '' : 's'}?'),
        content: const Text('These meals haven\'t been saved yet.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Keep editing')),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Discard', style: TextStyle(color: AppTheme.danger))),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _saveCart() async {
    final provider = context.read<NutritionProvider>();
    final count = _cart.length;
    for (final entry in _cart) {
      await provider.createNutrition(NutritionModel(
        userId: 1,
        foodName: entry.foodName,
        calories: entry.calories,
        protein: entry.protein,
        carbs: entry.carbs,
        fats: entry.fats,
        quantity: entry.quantity,
        mealType: entry.mealType,
        date: DateTime.now(),
      ));
    }
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$count meal${count == 1 ? '' : 's'} saved')),
    );
  }

  void _showQuickAddSheet({
    required String name,
    required int calories,
    required double protein,
    required double carbs,
    required double fats,
    required String servingLabel,
  }) {
    double quantity = 1;
    String mealType = _guessMealType();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card(context),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final totalCal = (calories * quantity).round();
            final totalProtein = protein * quantity;
            return Padding(
              padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary(context))),
                  const SizedBox(height: 4),
                  Text('$servingLabel · $calories kcal · ${protein.toStringAsFixed(1)}g protein',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(context))),
                  const SizedBox(height: 20),
                  Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary(context))),
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
                    label: 'Add to Meal List',
                    onPressed: () {
                      setState(() {
                        _cart.add(_StagedMealEntry(
                          foodName: name,
                          calories: calories,
                          protein: protein,
                          carbs: carbs,
                          fats: fats,
                          quantity: quantity,
                          mealType: mealType,
                        ));
                      });
                      Navigator.of(sheetContext).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$name added — tap Save to confirm'), duration: const Duration(seconds: 1)),
                      );
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

  void _showCustomFoodSheet() {
    final nameController = TextEditingController();
    final caloriesController = TextEditingController();
    final proteinController = TextEditingController();
    final carbsController = TextEditingController();
    final fatsController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    String mealType = _guessMealType();
    bool saveAsFavorite = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card(context),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Custom Dish', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary(context))),
                    const SizedBox(height: 16),
                    AppTextField(label: 'Food Name', hint: 'e.g., Homemade Karahi', controller: nameController),
                    DropdownButton<String>(
                      value: mealType,
                      isExpanded: true,
                      items: ['breakfast', 'lunch', 'dinner', 'snack']
                          .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                          .toList(),
                      onChanged: (value) => setSheetState(() => mealType = value!),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(label: 'Calories', hint: 'e.g., 350', controller: caloriesController, keyboardType: TextInputType.number),
                    AppTextField(label: 'Protein (g)', hint: 'e.g., 20', controller: proteinController, keyboardType: TextInputType.number),
                    AppTextField(label: 'Carbs (g)', hint: 'e.g., 30', controller: carbsController, keyboardType: TextInputType.number),
                    AppTextField(label: 'Fats (g)', hint: 'e.g., 10', controller: fatsController, keyboardType: TextInputType.number),
                    AppTextField(label: 'Quantity', hint: 'e.g., 1', controller: quantityController, keyboardType: TextInputType.number),
                    Row(
                      children: [
                        Checkbox(
                          value: saveAsFavorite,
                          activeColor: AppTheme.lime,
                          onChanged: (value) => setSheetState(() => saveAsFavorite = value ?? false),
                        ),
                        const Text('Save to Favorites'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    AppButton(
                      label: 'Add to Meal List',
                      onPressed: () {
                        if (nameController.text.trim().isEmpty ||
                            caloriesController.text.trim().isEmpty ||
                            proteinController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please fill name, calories and protein')),
                          );
                          return;
                        }

                        final calories = int.tryParse(caloriesController.text.trim()) ?? 0;
                        final protein = double.tryParse(proteinController.text.trim()) ?? 0;
                        final carbs = double.tryParse(carbsController.text.trim()) ?? 0;
                        final fats = double.tryParse(fatsController.text.trim()) ?? 0;
                        final quantity = double.tryParse(quantityController.text.trim()) ?? 1;
                        final dishName = nameController.text.trim();

                        setState(() {
                          _cart.add(_StagedMealEntry(
                            foodName: dishName,
                            calories: calories,
                            protein: protein,
                            carbs: carbs,
                            fats: fats,
                            quantity: quantity,
                            mealType: mealType,
                          ));
                        });

                        if (saveAsFavorite) {
                          context.read<SavedFoodProvider>().addFood(
                                SavedFoodModel(
                                  userId: 1,
                                  name: dishName,
                                  servingLabel: '1 serving',
                                  calories: calories,
                                  protein: protein,
                                  carbs: carbs,
                                  fats: fats,
                                ),
                              );
                        }

                        Navigator.of(sheetContext).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$dishName added — tap Save to confirm'), duration: const Duration(seconds: 1)),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showFavoritesSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card(context),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Consumer<SavedFoodProvider>(
            builder: (context, savedFoodProvider, _) {
              final foods = savedFoodProvider.foods;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Favorites', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary(context))),
                  const SizedBox(height: 16),
                  if (foods.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text('No favorites yet. Save a custom dish to see it here.',
                          style: TextStyle(color: AppTheme.textSecondary(context))),
                    )
                  else
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: foods.length,
                        itemBuilder: (context, index) {
                          final food = foods[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(food.name),
                            subtitle: Text('${food.calories} kcal · ${food.protein.toStringAsFixed(1)}g protein'),
                            trailing: IconButton(
                              icon: Icon(Icons.delete_outline, size: 20, color: AppTheme.textSecondary(context)),
                              onPressed: () => context.read<SavedFoodProvider>().deleteFood(food.id!, 1),
                            ),
                            onTap: () {
                              Navigator.of(sheetContext).pop();
                              _showQuickAddSheet(
                                name: food.name,
                                calories: food.calories,
                                protein: food.protein,
                                carbs: food.carbs,
                                fats: food.fats,
                                servingLabel: food.servingLabel,
                              );
                            },
                          );
                        },
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = _filteredFoods;
    final cartCalories = _cart.fold(0, (sum, e) => sum + e.totalCalories);

    return WillPopScope(
      onWillPop: _confirmDiscard,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(title: const Text('Add Meal'), centerTitle: true, elevation: 0),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      autofocus: true,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'Search paratha, biryani, chicken karahi...',
                        prefixIcon: Icon(Icons.search, size: 20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _showCustomFoodSheet,
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Custom Dish', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _showFavoritesSheet,
                            icon: const Icon(Icons.star_border, size: 16),
                            label: const Text('Favorites', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: PakistaniFoodDatabase.categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final category = PakistaniFoodDatabase.categories[index];
                          final selected = category == _selectedCategory;
                          return ChoiceChip(
                            label: Text(category, style: TextStyle(fontSize: 12, color: selected ? Colors.black : AppTheme.textPrimary(context))),
                            selected: selected,
                            selectedColor: AppTheme.lime,
                            backgroundColor: AppTheme.card(context),
                            onSelected: (_) => setState(() => _selectedCategory = category),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: results.isEmpty
                    ? Center(child: Text('No foods found. Try a custom dish instead.', style: TextStyle(color: AppTheme.textSecondary(context))))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final food = results[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: CustomCard(
                              onTap: () => _showQuickAddSheet(
                                name: food.name,
                                calories: food.calories,
                                protein: food.protein,
                                carbs: food.carbs,
                                fats: food.fats,
                                servingLabel: food.servingLabel,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(food.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 3),
                                        Text('${food.servingLabel} · ${food.calories} kcal',
                                            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(context))),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.add_circle_outline, color: AppTheme.lime),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              if (_cart.isNotEmpty)
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: BoxDecoration(
                    color: AppTheme.card(context),
                    border: Border(top: BorderSide(color: AppTheme.divider(context))),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 130),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _cart.length,
                          itemBuilder: (context, index) {
                            final entry = _cart[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${entry.foodName} (${entry.mealType})',
                                      style: TextStyle(fontSize: 12.5, color: AppTheme.textPrimary(context)),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text('${entry.totalCalories} kcal', style: TextStyle(fontSize: 11.5, color: AppTheme.textSecondary(context))),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () => setState(() => _cart.removeAt(index)),
                                    child: Icon(Icons.close, size: 16, color: AppTheme.textSecondary(context)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          label: 'Save ${_cart.length} Meal${_cart.length == 1 ? '' : 's'} · $cartCalories kcal',
                          onPressed: _saveCart,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}