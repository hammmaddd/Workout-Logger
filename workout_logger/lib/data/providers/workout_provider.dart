import 'package:flutter/material.dart';
import '../models/workout_model.dart';
import '../repositories/workout_repository.dart';

class WorkoutProvider extends ChangeNotifier {
  final WorkoutRepository _repository = WorkoutRepository();
  
  List<WorkoutModel> _workouts = [];
  bool _isLoading = false;

  List<WorkoutModel> get workouts => _workouts;
  bool get isLoading => _isLoading;

  Future<void> createWorkout(WorkoutModel workout) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.createWorkout(workout);
      await loadWorkouts(workout.userId);
    } catch (e) {
      print('Error creating workout: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadWorkouts(int userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _workouts = await _repository.getWorkouts(userId);
    } catch (e) {
      print('Error loading workouts: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteWorkout(int id, int userId) async {
    try {
      await _repository.deleteWorkout(id);
      await loadWorkouts(userId);
    } catch (e) {
      print('Error deleting workout: $e');
    }
  }

  Future<double> getTotalVolume(int userId) async {
    return await _repository.getTotalVolume(userId);
  }

  Future<int> getTotalSets(int userId) async {
    return await _repository.getTotalSets(userId);
  }
}