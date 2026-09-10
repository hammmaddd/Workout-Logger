import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPreferencesProvider extends ChangeNotifier {
  static const _prefPrefix = 'notif_';

  bool workoutReminder = true;
  bool restTimer = true;
  bool mealLogging = true;
  bool waterReminder = true;
  bool proteinGoalReminder = true;
  bool weeklyReport = true;
  bool streakReminder = true;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    workoutReminder = prefs.getBool('${_prefPrefix}workoutReminder') ?? true;
    restTimer = prefs.getBool('${_prefPrefix}restTimer') ?? true;
    mealLogging = prefs.getBool('${_prefPrefix}mealLogging') ?? true;
    waterReminder = prefs.getBool('${_prefPrefix}waterReminder') ?? true;
    proteinGoalReminder = prefs.getBool('${_prefPrefix}proteinGoalReminder') ?? true;
    weeklyReport = prefs.getBool('${_prefPrefix}weeklyReport') ?? true;
    streakReminder = prefs.getBool('${_prefPrefix}streakReminder') ?? true;
    notifyListeners();
  }

  Future<void> setValue(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefPrefix$key', value);

    switch (key) {
      case 'workoutReminder':
        workoutReminder = value;
        break;
      case 'restTimer':
        restTimer = value;
        break;
      case 'mealLogging':
        mealLogging = value;
        break;
      case 'waterReminder':
        waterReminder = value;
        break;
      case 'proteinGoalReminder':
        proteinGoalReminder = value;
        break;
      case 'weeklyReport':
        weeklyReport = value;
        break;
      case 'streakReminder':
        streakReminder = value;
        break;
    }
    notifyListeners();
  }
}