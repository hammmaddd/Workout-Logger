class SavedFoodModel {
  final int? id;
  final int userId;
  final String name;
  final String servingLabel;
  final int calories;
  final double protein;
  final double carbs;
  final double fats;

  SavedFoodModel({
    this.id,
    required this.userId,
    required this.name,
    required this.servingLabel,
    required this.calories,
    required this.protein,
    this.carbs = 0,
    this.fats = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'servingLabel': servingLabel,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
    };
  }

  factory SavedFoodModel.fromMap(Map<String, dynamic> map) {
    return SavedFoodModel(
      id: map['id'],
      userId: map['userId'],
      name: map['name'],
      servingLabel: map['servingLabel'] ?? '1 serving',
      calories: map['calories'],
      protein: map['protein'],
      carbs: map['carbs'] ?? 0.0,
      fats: map['fats'] ?? 0.0,
    );
  }
}