import '../../data/models/food_database_item.dart';

class PakistaniFoodDatabase {
  static const List<String> categories = [
    'All',
    'Desi Bread',
    'Daal/Lentils',
    'Curry',
    'Rice',
    'Protein',
    'Drinks',
    'Snacks',
  ];

  static const List<FoodDatabaseItem> foods = [
    FoodDatabaseItem(name: 'Roti', category: 'Desi Bread', servingLabel: '1 piece', calories: 120, protein: 3.5, carbs: 24, fats: 0.8),
    FoodDatabaseItem(name: 'Plain Paratha', category: 'Desi Bread', servingLabel: '1 piece', calories: 290, protein: 5, carbs: 32, fats: 15),
    FoodDatabaseItem(name: 'Naan', category: 'Desi Bread', servingLabel: '1 piece', calories: 260, protein: 8, carbs: 48, fats: 4),

    FoodDatabaseItem(name: 'Daal Chana', category: 'Daal/Lentils', servingLabel: '1 bowl', calories: 240, protein: 12, carbs: 35, fats: 6),
    FoodDatabaseItem(name: 'Daal Masoor', category: 'Daal/Lentils', servingLabel: '1 bowl', calories: 200, protein: 13, carbs: 30, fats: 3),
    FoodDatabaseItem(name: 'Daal Mash', category: 'Daal/Lentils', servingLabel: '1 bowl', calories: 220, protein: 11, carbs: 28, fats: 7),
    FoodDatabaseItem(name: 'Chana Masala', category: 'Daal/Lentils', servingLabel: '1 bowl', calories: 260, protein: 11, carbs: 40, fats: 6),

    FoodDatabaseItem(name: 'Chicken Karahi', category: 'Curry', servingLabel: '200g', calories: 420, protein: 32, carbs: 8, fats: 28),
    FoodDatabaseItem(name: 'Chicken Breast Roasted', category: 'Curry', servingLabel: '200g', calories: 330, protein: 62, carbs: 0, fats: 7),
    FoodDatabaseItem(name: 'Beef Curry', category: 'Curry', servingLabel: '200g', calories: 380, protein: 30, carbs: 10, fats: 24),
    FoodDatabaseItem(name: 'Fish Curry', category: 'Curry', servingLabel: '200g', calories: 280, protein: 34, carbs: 6, fats: 12),

    FoodDatabaseItem(name: 'Boiled White Rice', category: 'Rice', servingLabel: '1.5 plate', calories: 250, protein: 5, carbs: 55, fats: 0.5),
    FoodDatabaseItem(name: 'Chicken Biryani', category: 'Rice', servingLabel: '1 plate', calories: 450, protein: 18, carbs: 60, fats: 15),
    FoodDatabaseItem(name: 'Vegetable Pulao', category: 'Rice', servingLabel: '1 plate', calories: 380, protein: 12, carbs: 55, fats: 12),

    FoodDatabaseItem(name: '2 Eggs Boiled', category: 'Protein', servingLabel: '2 eggs', calories: 156, protein: 12, carbs: 1, fats: 11),
    FoodDatabaseItem(name: 'Milk Whole', category: 'Protein', servingLabel: '1 glass', calories: 120, protein: 8, carbs: 12, fats: 5),
    FoodDatabaseItem(name: 'Yogurt', category: 'Protein', servingLabel: '1 cup', calories: 150, protein: 8, carbs: 11, fats: 8),
    FoodDatabaseItem(name: 'Oats', category: 'Protein', servingLabel: '1 bowl', calories: 150, protein: 5, carbs: 27, fats: 3),
    FoodDatabaseItem(name: 'Potatoes Boiled', category: 'Protein', servingLabel: '100g', calories: 87, protein: 2, carbs: 20, fats: 0.1),

    FoodDatabaseItem(name: 'Tea with Milk', category: 'Drinks', servingLabel: '1 cup', calories: 60, protein: 2, carbs: 8, fats: 2),
    FoodDatabaseItem(name: 'Black Coffee', category: 'Drinks', servingLabel: '1 cup', calories: 5, protein: 0.3, carbs: 1, fats: 0),
    FoodDatabaseItem(name: 'Mango Shake', category: 'Drinks', servingLabel: '1 glass', calories: 210, protein: 5, carbs: 38, fats: 5),

    FoodDatabaseItem(name: 'Mixed Nuts', category: 'Snacks', servingLabel: '30g', calories: 170, protein: 6, carbs: 6, fats: 15),
    FoodDatabaseItem(name: 'Peanut Butter', category: 'Snacks', servingLabel: '1 tbsp', calories: 95, protein: 4, carbs: 3, fats: 8),
    FoodDatabaseItem(name: 'Banana', category: 'Snacks', servingLabel: '1 medium', calories: 105, protein: 1.3, carbs: 27, fats: 0.3),
    FoodDatabaseItem(name: 'Apple', category: 'Snacks', servingLabel: '1 medium', calories: 95, protein: 0.5, carbs: 25, fats: 0.3),
    FoodDatabaseItem(name: 'Mixed Vegetables', category: 'Snacks', servingLabel: '1 bowl', calories: 90, protein: 3, carbs: 15, fats: 2),
  ];
}