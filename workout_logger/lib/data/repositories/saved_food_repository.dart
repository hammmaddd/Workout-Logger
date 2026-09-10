import '../models/saved_food_model.dart';
import '../../core/database/database_helper.dart';

class SavedFoodRepository {
  Future<int> addFood(SavedFoodModel food) async {
    return await DatabaseHelper.insertSavedFood(food.toMap());
  }

  Future<List<SavedFoodModel>> getFoods(int userId) async {
    final data = await DatabaseHelper.getSavedFoods(userId);
    return data.map((item) => SavedFoodModel.fromMap(item)).toList();
  }

  Future<void> deleteFood(int id) async {
    await DatabaseHelper.deleteSavedFood(id);
  }
}