import '../../data/models/user_model.dart';

class NutritionGoals {
  final int calories;
  final double protein;
  final double carbs;
  final double fats;
  final int waterMl;

  NutritionGoals({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.waterMl,
  });
}

class NutritionGoalsHelper {
  static NutritionGoals computeGoals(UserModel? user) {
    if (user == null || user.weight == null || user.height == null || user.age == null) {
      return NutritionGoals(calories: 2200, protein: 120, carbs: 250, fats: 70, waterMl: 2500);
    }

    final w = user.weight!;
    final h = user.height!;
    final a = user.age!;

    double bmr;
    if (user.gender == 'male') {
      bmr = 10 * w + 6.25 * h - 5 * a + 5;
    } else if (user.gender == 'female') {
      bmr = 10 * w + 6.25 * h - 5 * a - 161;
    } else {
      final male = 10 * w + 6.25 * h - 5 * a + 5;
      final female = 10 * w + 6.25 * h - 5 * a - 161;
      bmr = (male + female) / 2;
    }

    double tdee = bmr * 1.4;

    if (user.fitnessGoal == 'weight_loss') {
      tdee -= 500;
    } else if (user.fitnessGoal == 'muscle_gain') {
      tdee += 300;
    }

    if (tdee < 1200) tdee = 1200;

    final protein = w * 1.8;
    final fats = (tdee * 0.25) / 9;
    final proteinCal = protein * 4;
    final fatsCal = fats * 9;
    final carbsCal = tdee - proteinCal - fatsCal;
    final carbs = carbsCal > 0 ? carbsCal / 4 : 0.0;

    final waterMl = (w * 33).round();

    return NutritionGoals(
      calories: tdee.round(),
      protein: protein,
      carbs: carbs,
      fats: fats,
      waterMl: waterMl,
    );
  }
}