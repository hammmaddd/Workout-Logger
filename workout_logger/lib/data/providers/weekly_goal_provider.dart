import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeeklyGoalProvider extends ChangeNotifier {
  static const _targetKey = 'weekly_goal_target_days';
  static const _firstDayKey = 'weekly_goal_first_day';

  int targetDays = 7;
  int firstDayOfWeek = 0; // 0 = Sunday ... 6 = Saturday

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    targetDays = prefs.getInt(_targetKey) ?? 7;
    firstDayOfWeek = prefs.getInt(_firstDayKey) ?? 0;
    notifyListeners();
  }

  Future<void> setGoal({required int targetDays, required int firstDayOfWeek}) async {
    this.targetDays = targetDays;
    this.firstDayOfWeek = firstDayOfWeek;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_targetKey, targetDays);
    await prefs.setInt(_firstDayKey, firstDayOfWeek);
  }
}