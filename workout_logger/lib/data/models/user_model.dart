class UserModel {
  final int? id;
  final String name;
  final String? email;
  final int? age;
  final String? gender;
  final double? height;
  final double? weight;
  final double? targetWeight;
  final String? fitnessGoal;
  final String? workoutDaysPerWeek;
  final String? activityLevel;
  final String? trainingExperience;
  final String? preferredWorkoutTime;
  final DateTime? createdAt;

  UserModel({
    this.id,
    required this.name,
    this.email,
    this.age,
    this.gender,
    this.height,
    this.weight,
    this.targetWeight,
    this.fitnessGoal,
    this.workoutDaysPerWeek,
    this.activityLevel,
    this.trainingExperience,
    this.preferredWorkoutTime,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'targetWeight': targetWeight,
      'fitnessGoal': fitnessGoal,
      'workoutDaysPerWeek': workoutDaysPerWeek,
      'activityLevel': activityLevel,
      'trainingExperience': trainingExperience,
      'preferredWorkoutTime': preferredWorkoutTime,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      age: map['age'],
      gender: map['gender'],
      height: map['height'],
      weight: map['weight'],
      targetWeight: map['targetWeight'],
      fitnessGoal: map['fitnessGoal'],
      workoutDaysPerWeek: map['workoutDaysPerWeek'],
      activityLevel: map['activityLevel'],
      trainingExperience: map['trainingExperience'],
      preferredWorkoutTime: map['preferredWorkoutTime'],
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
    );
  }

  double calculateBMI() {
    if (height == null || weight == null) return 0;
    double heightInMeters = height! / 100;
    return weight! / (heightInMeters * heightInMeters);
  }

  String getBMICategory() {
    double bmi = calculateBMI();
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal weight';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }
}