class NutritionModel {
  final int? id;
  final int userId;
  final String foodName;
  final int calories;
  final double protein;
  final double carbs;
  final double fats;
  final double quantity;
  final String mealType;
  final DateTime date;

  NutritionModel({
    this.id,
    required this.userId,
    required this.foodName,
    required this.calories,
    required this.protein,
    this.carbs = 0,
    this.fats = 0,
    this.quantity = 1,
    this.mealType = 'snack',
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'foodName': foodName,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'quantity': quantity,
      'mealType': mealType,
      'date': date.toIso8601String(),
    };
  }

  factory NutritionModel.fromMap(Map<String, dynamic> map) {
    return NutritionModel(
      id: map['id'],
      userId: map['userId'],
      foodName: map['foodName'],
      calories: map['calories'],
      protein: map['protein'],
      carbs: map['carbs'] ?? 0.0,
      fats: map['fats'] ?? 0.0,
      quantity: map['quantity'] ?? 1.0,
      mealType: map['mealType'] ?? 'snack',
      date: DateTime.parse(map['date']),
    );
  }

  int getTotalCalories() {
    return (calories * quantity).toInt();
  }

  double getTotalProtein() {
    return protein * quantity;
  }

  double getTotalCarbs() {
    return carbs * quantity;
  }

  double getTotalFats() {
    return fats * quantity;
  }
}