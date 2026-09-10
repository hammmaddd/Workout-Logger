import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/models/workout_model.dart';
import '../../core/utils/chart_data_helper.dart';
import '../theme/app_theme.dart';
import 'custom_card.dart';

class PerformanceMatrixWidget extends StatefulWidget {
  final List<WorkoutModel> workouts;
  final ChartRange range;

  const PerformanceMatrixWidget({super.key, required this.workouts, required this.range});

  @override
  State<PerformanceMatrixWidget> createState() => _PerformanceMatrixWidgetState();
}

class _PerformanceMatrixWidgetState extends State<PerformanceMatrixWidget> {
  String _selectedExercise = 'All exercises';

  @override
  Widget build(BuildContext context) {
    final distinctExercises = widget.workouts.map((w) => w.exerciseName).toSet().toList()..sort();
    final exerciseOptions = ['All exercises', ...distinctExercises];
    final currentSelection = exerciseOptions.contains(_selectedExercise) ? _selectedExercise : 'All exercises';

    final filteredWorkouts = currentSelection == 'All exercises'
        ? widget.workouts
        : widget.workouts.where((w) => w.exerciseName == currentSelection).toList();

    final points = ChartDataHelper.buildSeries(filteredWorkouts, widget.range);
    final hasData = points.any((p) => p.volume > 0 || p.oneRM > 0);

    final maxVolume = points.fold<double>(0, (max, p) => p.volume > max ? p.volume : max);
    final maxOneRM = points.fold<double>(0, (max, p) => p.oneRM > max ? p.oneRM : max);
    final gridLineColor = AppTheme.isDark(context) ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05);

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Performance Matrix', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Row(
                children: [
                  _legendDot(context, AppTheme.lime, 'Volume'),
                  const SizedBox(width: 12),
                  _legendDot(context, AppTheme.cyan, '1RM Est'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (distinctExercises.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceTint(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: currentSelection,
                  isExpanded: true,
                  dropdownColor: AppTheme.card(context),
                  icon: Icon(Icons.keyboard_arrow_down, size: 18, color: AppTheme.textSecondary(context)),
                  style: TextStyle(fontSize: 13, color: AppTheme.textPrimary(context)),
                  items: exerciseOptions
                      .map((name) => DropdownMenuItem(value: name, child: Text(name, overflow: TextOverflow.ellipsis)))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedExercise = value ?? 'All exercises'),
                ),
              ),
            ),
          const SizedBox(height: 16),
          if (!hasData)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: Text('No workouts in this period yet', style: TextStyle(color: AppTheme.textSecondary(context), fontSize: 13)),
              ),
            )
          else
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 1.15,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 0.25,
                    getDrawingHorizontalLine: (value) => FlLine(color: gridLineColor, strokeWidth: 1),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        interval: points.length > 8 ? (points.length / 6).ceilToDouble() : 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= points.length) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(points[index].label, style: TextStyle(fontSize: 10, color: AppTheme.textSecondary(context))),
                          );
                        },
                      ),
                    ),
                  ),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (spots) {
                        return spots.map((spot) {
                          final idx = spot.x.toInt();
                          if (idx < 0 || idx >= points.length) return null;
                          final p = points[idx];
                          final isVolume = spot.barIndex == 0;
                          final text = isVolume ? '${p.volume.toStringAsFixed(0)} kg vol' : '${p.oneRM.toStringAsFixed(1)} kg 1RM';
                          return LineTooltipItem(
                            text,
                            TextStyle(
                              color: isVolume ? AppTheme.lime : AppTheme.cyan,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        points.length,
                        (i) => FlSpot(i.toDouble(), maxVolume > 0 ? points[i].volume / maxVolume : 0),
                      ),
                      isCurved: true,
                      color: AppTheme.lime,
                      barWidth: 2.5,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(show: false),
                    ),
                    LineChartBarData(
                      spots: List.generate(
                        points.length,
                        (i) => FlSpot(i.toDouble(), maxOneRM > 0 ? points[i].oneRM / maxOneRM : 0),
                      ),
                      isCurved: true,
                      color: AppTheme.cyan,
                      barWidth: 2.5,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _legendDot(BuildContext context, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(fontSize: 11, color: AppTheme.textSecondary(context))),
      ],
    );
  }
}