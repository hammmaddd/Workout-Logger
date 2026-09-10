import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository _repository = UserRepository();

  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  Future<void> createUser(UserModel user) async {
    _isLoading = true;
    notifyListeners();
    try {
      final id = await _repository.createUser(user);
      _currentUser = UserModel(
        id: id,
        name: user.name,
        email: user.email,
        age: user.age,
        gender: user.gender,
        height: user.height,
        weight: user.weight,
        targetWeight: user.targetWeight,
        fitnessGoal: user.fitnessGoal,
        createdAt: user.createdAt,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> getUser(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentUser = await _repository.getUser(id);
    } catch (e) {
      _currentUser = null;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateUser(UserModel user) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.updateUser(user);
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  double get bmi => _currentUser?.calculateBMI() ?? 0;
  String get bmiCategory => _currentUser?.getBMICategory() ?? 'N/A';
}