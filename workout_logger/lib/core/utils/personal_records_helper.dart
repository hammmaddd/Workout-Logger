import '../../data/models/workout_model.dart';

class ExercisePR {
  final String exerciseName;
  final double heaviestWeight;
  final int maxReps;
  final double bestOneRM;
  final double bestVolume;
  final bool isRecentPR;
  final String weightUnit;

  ExercisePR({
    required this.exerciseName,
    required this.heaviestWeight,
    required this.maxReps,
    required this.bestOneRM,
    required this.bestVolume,
    required this.isRecentPR,
    required this.weightUnit,
  });
}

class PersonalRecordsHelper {
  static List<ExercisePR> compute(List<WorkoutModel> workouts) {
    final Map<String, List<WorkoutModel>> byExercise = {};
    for (final w in workouts) {
      byExercise.putIfAbsent(w.exerciseName, () => []).add(w);
    }

    final result = <ExercisePR>[];

    byExercise.forEach((name, entries) {
      final sorted = [...entries]..sort((a, b) => a.date.compareTo(b.date));

      double heaviestWeight = 0;
      int maxReps = 0;
      double bestOneRM = 0;
      double bestVolume = 0;

      for (final e in sorted) {
        if (e.weight > heaviestWeight) heaviestWeight = e.weight;
        if (e.reps > maxReps) maxReps = e.reps;
        final oneRM = e.weight * (1 + e.reps / 30);
        if (oneRM > bestOneRM) bestOneRM = oneRM;
        final vol = e.calculateVolume();
        if (vol > bestVolume) bestVolume = vol;
      }

      final latest = sorted.last;
      final isRecentPR = heaviestWeight > 0 && latest.weight >= heaviestWeight;

      result.add(ExercisePR(
        exerciseName: name,
        heaviestWeight: heaviestWeight,
        maxReps: maxReps,
        bestOneRM: bestOneRM,
        bestVolume: bestVolume,
        isRecentPR: isRecentPR,
        weightUnit: latest.weightUnit,
      ));
    });

    result.sort((a, b) {
      final aLatest = byExercise[a.exerciseName]!.last.date;
      final bLatest = byExercise[b.exerciseName]!.last.date;
      return bLatest.compareTo(aLatest);
    });

    return result;
  }
}