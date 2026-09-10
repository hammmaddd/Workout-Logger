class WaterEntryModel {
  final int? id;
  final int userId;
  final int amountMl;
  final DateTime date;

  WaterEntryModel({
    this.id,
    required this.userId,
    required this.amountMl,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'amountMl': amountMl,
      'date': date.toIso8601String(),
    };
  }

  factory WaterEntryModel.fromMap(Map<String, dynamic> map) {
    return WaterEntryModel(
      id: map['id'],
      userId: map['userId'],
      amountMl: map['amountMl'],
      date: DateTime.parse(map['date']),
    );
  }
}