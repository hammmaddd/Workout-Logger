import 'session_set_model.dart';

class SessionExerciseModel {
  final int? id;
  final int sessionId;
  final String exerciseName;
  final int orderIndex;
  final List<SessionSetModel> sets;
  final List<SessionSetModel> previousSets;
  final double? bestWeight;
  final int? bestReps;

  SessionExerciseModel({
    this.id,
    required this.sessionId,
    required this.exerciseName,
    required this.orderIndex,
    List<SessionSetModel>? sets,
    List<SessionSetModel>? previousSets,
    this.bestWeight,
    this.bestReps,
  })  : sets = sets ?? [],
        previousSets = previousSets ?? [];

  int get completedCount => sets.where((s) => s.completed).length;
}