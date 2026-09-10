class WorkoutPlanSummaryModel {
  final int sessionId;
  final String name;
  final List<String> exerciseNames;
  final int durationMinutes;
  final DateTime lastPerformed;

  WorkoutPlanSummaryModel({
    required this.sessionId,
    required this.name,
    required this.exerciseNames,
    required this.durationMinutes,
    required this.lastPerformed,
  });

  int get exerciseCount => exerciseNames.length;
}