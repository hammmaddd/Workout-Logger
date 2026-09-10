class SessionSetModel {
  final int? id;
  final int sessionExerciseId;
  final int setNumber;
  final double weight;
  final int reps;
  final bool completed;

  SessionSetModel({
    this.id,
    required this.sessionExerciseId,
    required this.setNumber,
    required this.weight,
    required this.reps,
    this.completed = false,
  });

  SessionSetModel copyWith({double? weight, int? reps, bool? completed}) {
    return SessionSetModel(
      id: id,
      sessionExerciseId: sessionExerciseId,
      setNumber: setNumber,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      completed: completed ?? this.completed,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sessionExerciseId': sessionExerciseId,
      'setNumber': setNumber,
      'weight': weight,
      'reps': reps,
      'completed': completed ? 1 : 0,
    };
  }

  factory SessionSetModel.fromMap(Map<String, dynamic> map) {
    return SessionSetModel(
      id: map['id'],
      sessionExerciseId: map['sessionExerciseId'],
      setNumber: map['setNumber'],
      weight: map['weight'],
      reps: map['reps'],
      completed: map['completed'] == 1,
    );
  }
}