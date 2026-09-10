class DetectedFoodItemModel {
  final String name;
  final double confidence;
  final String servingDescription;
  final int calories;
  final double protein;
  final double carbs;
  final double fats;

  DetectedFoodItemModel({
    required this.name,
    required this.confidence,
    required this.servingDescription,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
  });

  factory DetectedFoodItemModel.fromJson(Map<String, dynamic> json) {
    final rawName = json['name'] as String?;
    return DetectedFoodItemModel(
      name: (rawName != null && rawName.trim().isNotEmpty) ? rawName.trim() : 'Unknown item',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.3,
      servingDescription: json['servingDescription'] as String? ?? '',
      calories: ((json['calories'] as num?) ?? 0).round(),
      protein: (json['protein'] as num?)?.toDouble() ?? 0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0,
      fats: (json['fats'] as num?)?.toDouble() ?? 0,
    );
  }
}