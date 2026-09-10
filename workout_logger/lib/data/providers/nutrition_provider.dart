import 'package:flutter/material.dart';
import '../models/nutrition_model.dart';
import '../repositories/nutrition_repository.dart';

class NutritionProvider extends ChangeNotifier {
  final NutritionRepository _repository = NutritionRepository();
  
  List<NutritionModel> _nutrition = [];
  bool _isLoading = false;

  List<NutritionModel> get nutrition => _nutrition;
  bool get isLoading => _isLoading;

  Future<void> createNutrition(NutritionModel nutrition) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.createNutrition(nutrition);
      await loadNutrition(nutrition.userId);
    } catch (e) {
      print('Error creating nutrition: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadNutrition(int userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _nutrition = await _repository.getNutrition(userId);
    } catch (e) {
      print('Error loading nutrition: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteNutrition(int id, int userId) async {
    try {
      await _repository.deleteNutrition(id);
      await loadNutrition(userId);
    } catch (e) {
      print('Error deleting nutrition: $e');
    }
  }

  Future<int> getTodayCalories(int userId) async {
    return await _repository.getTodayCalories(userId);
  }

  Future<double> getTodayProtein(int userId) async {
    return await _repository.getTodayProtein(userId);
  }
}