import 'package:flutter/material.dart';
import '../../core/constants/workout_template_catalog.dart';
import '../theme/app_theme.dart';

class CategoryChips extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const CategoryChips({Key? key, required this.selectedCategory, required this.onCategorySelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: WorkoutTemplateCatalog.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = WorkoutTemplateCatalog.categories[index];
          final selected = category == selectedCategory;
          return ChoiceChip(
            label: Text(category, style: TextStyle(fontSize: 13, color: selected ? Colors.black : AppTheme.textPrimary(context))),
            selected: selected,
            selectedColor: AppTheme.lime,
            backgroundColor: AppTheme.card(context),
            onSelected: (_) => onCategorySelected(category),
          );
        },
      ),
    );
  }
}