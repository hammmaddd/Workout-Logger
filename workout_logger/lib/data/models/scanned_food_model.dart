class ScannedFoodModel {
  final String name;
  final String barcode;
  final int caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatsPer100g;

  ScannedFoodModel({
    required this.name,
    required this.barcode,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatsPer100g,
  });
}