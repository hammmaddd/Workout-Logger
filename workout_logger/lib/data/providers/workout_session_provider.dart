import 'package:flutter/material.dart';
import '../models/workout_session_model.dart';
import '../models/session_exercise_model.dart';
import '../models/session_set_model.dart';
import '../models/workout_model.dart';
import '../models/workout_plan_summary_model.dart';
import '../models/workout_template_model.dart';
import '../repositories/workout_session_repository.dart';
import '../repositories/workout_repository.dart';

class WorkoutSessionProvider extends ChangeNotifier {
  final WorkoutSessionRepository _repository = WorkoutSessionRepository();
  final WorkoutRepository _workoutRepository = WorkoutRepository();

  WorkoutSessionModel? _session;
  final List<SessionExerciseModel> _exercises = [];
  bool _isBusy = false;

  List<WorkoutPlanSummaryModel> _recentPlans = [];

  WorkoutSessionModel? get session => _session;
  List<SessionExerciseModel> get exercises => _exercises;
  bool get isBusy => _isBusy;
  List<WorkoutPlanSummaryModel> get recentPlans => _recentPlans;

  Future<void> loadRecentPlans(int userId) async {
    try {
      _recentPlans = await _repository.getRecentPlans(userId);
    } catch (e) {
      _recentPlans = [];
    }
    notifyListeners();
  }

  Future<void> startSession(int userId, String name) async {
    _isBusy = true;
    notifyListeners();

    final startTime = DateTime.now();
    final id = await _repository.createSession(
      WorkoutSessionModel(userId: userId, name: name, startTime: startTime, status: 'active'),
    );
    _session = WorkoutSessionModel(id: id, userId: userId, name: name, startTime: startTime, status: 'active');
    _exercises.clear();

    _isBusy = false;
    notifyListeners();
  }

  Future<void> startSessionFromPlan(int userId, WorkoutPlanSummaryModel plan) async {
    await startSession(userId, plan.name);
    for (final exerciseName in plan.exerciseNames) {
      await addExercise(exerciseName, defaultSets: 3);
    }
  }

  Future<void> startSessionFromTemplate(int userId, WorkoutTemplate template) async {
    await startSession(userId, template.name);
    for (final ex in template.exercises) {
      await addExercise(ex.name, defaultSets: ex.sets, suggestedReps: ex.reps);
    }
  }

  Future<void> addExercise(String exerciseName, {int defaultSets = 1, int? suggestedReps}) async {
    if (_session == null) return;
    _isBusy = true;
    notifyListeners();

    final orderIndex = _exercises.length;
    final exerciseId = await _repository.addExercise(_session!.id!, exerciseName, orderIndex);

    final previousSets = await _repository.getPreviousSets(_session!.userId, exerciseName, _session!.id!);
    final best = await _repository.getBestHistorical(_session!.userId, exerciseName);

    final exercise = SessionExerciseModel(
      id: exerciseId,
      sessionId: _session!.id!,
      exerciseName: exerciseName,
      orderIndex: orderIndex,
      previousSets: previousSets,
      bestWeight: best != null ? (best['weight'] as num).toDouble() : null,
      bestReps: best != null ? best['reps'] as int : null,
    );

    for (int i = 0; i < defaultSets; i++) {
      final prevSet = i < previousSets.length ? previousSets[i] : null;
      final seedReps = prevSet?.reps ?? suggestedReps ?? 0;
      final setId = await _repository.addSet(SessionSetModel(
        sessionExerciseId: exerciseId,
        setNumber: i + 1,
        weight: prevSet?.weight ?? 0,
        reps: seedReps,
        completed: false,
      ));
      exercise.sets.add(SessionSetModel(
        id: setId,
        sessionExerciseId: exerciseId,
        setNumber: i + 1,
        weight: prevSet?.weight ?? 0,
        reps: seedReps,
        completed: false,
      ));
    }

    _exercises.add(exercise);
    _isBusy = false;
    notifyListeners();
  }

  Future<void> addSet(int exerciseIndex, {bool duplicateLast = false}) async {
    final exercise = _exercises[exerciseIndex];
    final setNumber = exercise.sets.length + 1;

    double weight = 0;
    int reps = 0;
    if (duplicateLast && exercise.sets.isNotEmpty) {
      weight = exercise.sets.last.weight;
      reps = exercise.sets.last.reps;
    } else if (setNumber - 1 < exercise.previousSets.length) {
      weight = exercise.previousSets[setNumber - 1].weight;
      reps = exercise.previousSets[setNumber - 1].reps;
    }

    final id = await _repository.addSet(SessionSetModel(
      sessionExerciseId: exercise.id!,
      setNumber: setNumber,
      weight: weight,
      reps: reps,
      completed: false,
    ));
    exercise.sets.add(SessionSetModel(
      id: id,
      sessionExerciseId: exercise.id!,
      setNumber: setNumber,
      weight: weight,
      reps: reps,
      completed: false,
    ));
    notifyListeners();
  }

  Future<void> updateSetValues(int exerciseIndex, int setIndex, {double? weight, int? reps}) async {
    final exercise = _exercises[exerciseIndex];
    final updated = exercise.sets[setIndex].copyWith(weight: weight, reps: reps);
    exercise.sets[setIndex] = updated;
    await _repository.updateSet(updated);
    notifyListeners();
  }

  Future<bool> completeSet(int exerciseIndex, int setIndex, {required double weight, required int reps}) async {
    final exercise = _exercises[exerciseIndex];
    final current = exercise.sets[setIndex];
    final updated = current.copyWith(weight: weight, reps: reps, completed: !current.completed);
    exercise.sets[setIndex] = updated;
    await _repository.updateSet(updated);
    notifyListeners();
    return updated.completed;
  }

  Future<void> finishSession() async {
    if (_session == null) return;
    _isBusy = true;
    notifyListeners();

    final endTime = DateTime.now();
    final elapsedMinutes = endTime.difference(_session!.startTime).inMinutes;
    final userId = _session!.userId;

    for (final exercise in _exercises) {
      final completedSets = exercise.sets.where((s) => s.completed).toList();
      if (completedSets.isEmpty) continue;

      var heaviest = completedSets.first;
      for (final s in completedSets) {
        if (s.weight > heaviest.weight || (s.weight == heaviest.weight && s.reps > heaviest.reps)) {
          heaviest = s;
        }
      }

      await _workoutRepository.createWorkout(WorkoutModel(
        userId: userId,
        exerciseName: exercise.exerciseName,
        sets: completedSets.length,
        reps: heaviest.reps,
        weight: heaviest.weight,
        weightUnit: 'kg',
        duration: elapsedMinutes,
        difficulty: 'medium',
        date: _session!.startTime,
      ));
    }

    await _repository.finishSession(_session!.id!, endTime, status: 'finished');

    _session = null;
    _exercises.clear();
    _isBusy = false;
    notifyListeners();

    await loadRecentPlans(userId);
  }

  Future<void> cancelSession() async {
    if (_session == null) return;
    await _repository.finishSession(_session!.id!, DateTime.now(), status: 'cancelled');
    _session = null;
    _exercises.clear();
    notifyListeners();
  }
}