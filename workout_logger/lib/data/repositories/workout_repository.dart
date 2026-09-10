import '../models/workout_model.dart';
import '../../core/database/database_helper.dart';

class WorkoutRepository {
  Future<int> createWorkout(WorkoutModel workout) async {
    return await DatabaseHelper.insertWorkout(workout.toMap());
  }

  Future<List<WorkoutModel>> getWorkouts(int userId) async {
    final data = await DatabaseHelper.getWorkouts(userId);
    return data.map((item) => WorkoutModel.fromMap(item)).toList();
  }

  Future<void> updateWorkout(WorkoutModel workout) async {
    final db = await DatabaseHelper.database;
    await db.update(
      'workouts',
      workout.toMap(),
      where: 'id = ?',
      whereArgs: [workout.id],
    );
  }

  Future<void> deleteWorkout(int id) async {
    final db = await DatabaseHelper.database;
    await db.delete('workouts', where: 'id = ?', whereArgs: [id]);
  }

  Future<double> getTotalVolume(int userId) async {
    final workouts = await getWorkouts(userId);
    double totalVolume = 0.0;
    for (var workout in workouts) {
      totalVolume += workout.calculateVolume();
    }
    return totalVolume;
  }

  Future<int> getTotalSets(int userId) async {
    final workouts = await getWorkouts(userId);
    int totalSets = 0;
    for (var workout in workouts) {
      totalSets += workout.sets;
    }
    return totalSets;
  }
}