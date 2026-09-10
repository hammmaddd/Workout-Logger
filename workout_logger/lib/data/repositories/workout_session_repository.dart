import '../models/workout_session_model.dart';
import '../models/session_set_model.dart';
import '../models/workout_plan_summary_model.dart';
import '../../core/database/database_helper.dart';

class WorkoutSessionRepository {
  Future<int> createSession(WorkoutSessionModel session) async {
    return await DatabaseHelper.insertSession(session.toMap());
  }

  Future<void> finishSession(int sessionId, DateTime endTime, {String status = 'finished'}) async {
    await DatabaseHelper.updateSession(sessionId, {
      'endTime': endTime.toIso8601String(),
      'status': status,
    });
  }

  Future<int> addExercise(int sessionId, String exerciseName, int orderIndex) async {
    return await DatabaseHelper.insertSessionExercise({
      'sessionId': sessionId,
      'exerciseName': exerciseName,
      'orderIndex': orderIndex,
    });
  }

  Future<int> addSet(SessionSetModel set) async {
    return await DatabaseHelper.insertSessionSet(set.toMap());
  }

  Future<void> updateSet(SessionSetModel set) async {
    await DatabaseHelper.updateSessionSet(set.id!, {
      'weight': set.weight,
      'reps': set.reps,
      'completed': set.completed ? 1 : 0,
    });
  }

  Future<List<SessionSetModel>> getSets(int sessionExerciseId) async {
    final data = await DatabaseHelper.getSessionSets(sessionExerciseId);
    return data.map((m) => SessionSetModel.fromMap(m)).toList();
  }

  Future<List<SessionSetModel>> getPreviousSets(int userId, String exerciseName, int excludeSessionId) async {
    final ref = await DatabaseHelper.getPreviousSessionExercise(userId, exerciseName, excludeSessionId);
    if (ref == null) return [];
    final sessionExerciseId = ref['sessionExerciseId'] as int;
    return await getSets(sessionExerciseId);
  }

  Future<Map<String, dynamic>?> getBestHistorical(int userId, String exerciseName) async {
    return await DatabaseHelper.getBestWorkoutForExercise(userId, exerciseName);
  }

  Future<List<WorkoutPlanSummaryModel>> getRecentPlans(int userId, {int limit = 6}) async {
    final sessions = await DatabaseHelper.getFinishedSessions(userId, limit: 30);
    final seenNames = <String>{};
    final plans = <WorkoutPlanSummaryModel>[];

    for (final s in sessions) {
      final name = s['name'] as String;
      if (seenNames.contains(name)) continue;
      seenNames.add(name);

      final sessionId = s['id'] as int;
      final startTime = DateTime.parse(s['startTime'] as String);
      final endTimeRaw = s['endTime'] as String?;
      final endTime = endTimeRaw != null ? DateTime.parse(endTimeRaw) : startTime;
      var durationMinutes = endTime.difference(startTime).inMinutes;
      if (durationMinutes < 1) durationMinutes = 1;

      final exerciseRows = await DatabaseHelper.getSessionExerciseNames(sessionId);
      final exerciseNames = exerciseRows.map((r) => r['exerciseName'] as String).toList();

      if (exerciseNames.isEmpty) continue;

      plans.add(WorkoutPlanSummaryModel(
        sessionId: sessionId,
        name: name,
        exerciseNames: exerciseNames,
        durationMinutes: durationMinutes,
        lastPerformed: startTime,
      ));

      if (plans.length >= limit) break;
    }

    return plans;
  }
}