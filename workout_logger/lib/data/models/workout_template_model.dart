class WorkoutTemplateExercise {
  final String name;
  final int sets;
  final int reps;

  const WorkoutTemplateExercise({
    required this.name,
    required this.sets,
    required this.reps,
  });
}

class WorkoutTemplate {
  final String id;
  final String name;
  final String category;
  final int durationMinutes;
  final int difficulty; // 1-3
  final List<WorkoutTemplateExercise> exercises;
  final String? description;
  final List<String> tags;
  final bool isChallenge;

  const WorkoutTemplate({
    required this.id,
    required this.name,
    required this.category,
    required this.durationMinutes,
    required this.difficulty,
    required this.exercises,
    this.description,
    this.tags = const [],
    this.isChallenge = false,
  });

  int get exerciseCount => exercises.length;
}