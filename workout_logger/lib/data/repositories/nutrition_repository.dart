import '../models/nutrition_model.dart';
import '../../core/database/database_helper.dart';

class NutritionRepository {
  Future<int> createNutrition(NutritionModel nutrition) async {
    return await DatabaseHelper.insertNutrition(nutrition.toMap());
  }

  Future<List<NutritionModel>> getNutrition(int userId) async {
    final data = await DatabaseHelper.getNutrition(userId);
    return data.map((item) => NutritionModel.fromMap(item)).toList();
  }

  Future<void> updateNutrition(NutritionModel nutrition) async {
    final db = await DatabaseHelper.database;
    await db.update(
      'nutrition',
      nutrition.toMap(),
      where: 'id = ?',
      whereArgs: [nutrition.id],
    );
  }

  Future<void> deleteNutrition(int id) async {
    final db = await DatabaseHelper.database;
    await db.delete('nutrition', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getTodayCalories(int userId) async {
    final nutrition = await getNutrition(userId);
    final today = DateTime.now();
    int totalCalories = 0;
    for (var item in nutrition) {
      if (item.date.year == today.year &&
          item.date.month == today.month &&
          item.date.day == today.day) {
        totalCalories += item.getTotalCalories();
      }
    }
    return totalCalories;
  }

  Future<double> getTodayProtein(int userId) async {
    final nutrition = await getNutrition(userId);
    final today = DateTime.now();
    double totalProtein = 0.0;
    for (var item in nutrition) {
      if (item.date.year == today.year &&
          item.date.month == today.month &&
          item.date.day == today.day) {
        totalProtein += item.getTotalProtein();
      }
    }
    return totalProtein;
  }
}