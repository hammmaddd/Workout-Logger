import 'package:flutter/material.dart';
import '../models/saved_food_model.dart';
import '../repositories/saved_food_repository.dart';

class SavedFoodProvider extends ChangeNotifier {
  final SavedFoodRepository _repository = SavedFoodRepository();

  List<SavedFoodModel> _foods = [];
  bool _isLoading = false;

  List<SavedFoodModel> get foods => _foods;
  bool get isLoading => _isLoading;

  Future<void> addFood(SavedFoodModel food) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.addFood(food);
      await loadFoods(food.userId);
    } catch (e) {
      // ignore
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadFoods(int userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _foods = await _repository.getFoods(userId);
    } catch (e) {
      _foods = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteFood(int id, int userId) async {
    try {
      await _repository.deleteFood(id);
      await loadFoods(userId);
    } catch (e) {
      // ignore
    }
  }
}