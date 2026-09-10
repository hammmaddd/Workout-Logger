class WorkoutSessionModel {
  final int? id;
  final int userId;
  final String name;
  final DateTime startTime;
  final DateTime? endTime;
  final String status;

  WorkoutSessionModel({
    this.id,
    required this.userId,
    required this.name,
    required this.startTime,
    this.endTime,
    this.status = 'active',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'status': status,
    };
  }

  factory WorkoutSessionModel.fromMap(Map<String, dynamic> map) {
    return WorkoutSessionModel(
      id: map['id'],
      userId: map['userId'],
      name: map['name'],
      startTime: DateTime.parse(map['startTime']),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      status: map['status'] ?? 'active',
    );
  }
}