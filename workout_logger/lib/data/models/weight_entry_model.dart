class WeightEntryModel {
  final int? id;
  final int userId;
  final double weight;
  final DateTime date;

  WeightEntryModel({
    this.id,
    required this.userId,
    required this.weight,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'weight': weight,
      'date': date.toIso8601String(),
    };
  }

  factory WeightEntryModel.fromMap(Map<String, dynamic> map) {
    return WeightEntryModel(
      id: map['id'],
      userId: map['userId'],
      weight: map['weight'],
      date: DateTime.parse(map['date']),
    );
  }
}