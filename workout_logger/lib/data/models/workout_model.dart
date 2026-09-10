class WorkoutModel {
  final int? id;
  final int userId;
  final String exerciseName;
  final int sets;
  final int reps;
  final double weight;
  final String weightUnit;
  final int? duration;
  final String? notes;
  final String difficulty;
  final DateTime date;

  WorkoutModel({
    this.id,
    required this.userId,
    required this.exerciseName,
    required this.sets,
    required this.reps,
    this.weight = 0,
    this.weightUnit = 'kg',
    this.duration,
    this.notes,
    this.difficulty = 'medium',
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'exerciseName': exerciseName,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'weightUnit': weightUnit,
      'duration': duration,
      'notes': notes,
      'difficulty': difficulty,
      'date': date.toIso8601String(),
    };
  }

  factory WorkoutModel.fromMap(Map<String, dynamic> map) {
    return WorkoutModel(
      id: map['id'],
      userId: map['userId'],
      exerciseName: map['exerciseName'],
      sets: map['sets'],
      reps: map['reps'],
      weight: map['weight'] ?? 0.0,
      weightUnit: map['weightUnit'] ?? 'kg',
      duration: map['duration'],
      notes: map['notes'],
      difficulty: map['difficulty'] ?? 'medium',
      date: DateTime.parse(map['date']),
    );
  }

  double calculateVolume() {
    return sets * reps * weight;
  }
}