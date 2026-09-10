import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/models/weight_entry_model.dart';
import '../../data/providers/workout_provider.dart';
import '../../data/providers/weight_entry_provider.dart';
import '../../data/providers/user_provider.dart';
import '../../core/utils/chart_data_helper.dart';
import '../widgets/custom_card.dart';
import '../theme/app_theme.dart';
import 'full_history_screen.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  ChartRange _range = ChartRange.thirtyDays;
  String _selectedExercise = 'All exercises';

  static const Map<ChartRange, String> _rangeLabels = {
    ChartRange.sevenDays: '7D',
    ChartRange.thirtyDays: '30D',
    ChartRange.threeMonths: '3M',
    ChartRange.sixMonths: '6M',
    ChartRange.oneYear: '1Y',
  };

  void _showLogWeightDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.card(dialogContext),
        title: const Text('Log today\'s weight'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g., 78.5', suffixText: 'kg'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final weight = double.tryParse(controller.text.trim());
              if (weight == null) return;
              dialogContext.read<WeightEntryProvider>().addEntry(
                    WeightEntryModel(userId: 1, weight: weight, date: DateTime.now()),
                  );
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Save', style: TextStyle(color: AppTheme.lime)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Analytics & Progress', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: () => _showLogWeightDialog(context),
                icon: const Icon(Icons.add, size: 18, color: AppTheme.lime),
                label: const Text('Log weight', style: TextStyle(color: AppTheme.lime)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: ChartRange.values.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final range = ChartRange.values[index];
                final selected = range == _range;
                return ChoiceChip(
                  label: Text(_rangeLabels[range]!,
                      style: TextStyle(fontSize: 12, color: selected ? Colors.black : AppTheme.textPrimary(context))),
                  selected: selected,
                  selectedColor: AppTheme.lime,
                  backgroundColor: AppTheme.card(context),
                  onSelected: (_) => setState(() => _range = range),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Consumer<WorkoutProvider>(
            builder: (context, workoutProvider, _) => _buildPerformanceChart(context, workoutProvider),
          ),
          const SizedBox(height: 16),
          Consumer2<WeightEntryProvider, UserProvider>(
            builder: (context, weightProvider, userProvider, _) {
              final start = weightProvider.startWeight;
              final current = weightProvider.currentWeight;
              final target = userProvider.currentUser?.targetWeight;
              final delta = (start != null && current != null) ? (current - start) : null;

              bool? isGoodDirection;
              if (delta != null && target != null && start != null) {
                final goalIsGain = target > start;
                isGoodDirection = goalIsGain ? delta >= 0 : delta <= 0;
              }

              return CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('WEIGHT GOAL TRACKER', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(context))),
                        if (delta != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: (isGoodDirection ?? true ? AppTheme.success : AppTheme.warning).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${delta > 0 ? '+' : ''}${delta.toStringAsFixed(1)} kg',
                              style: TextStyle(fontSize: 11, color: isGoodDirection ?? true ? AppTheme.success : AppTheme.warning),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _statColumn(context, 'Start', start != null ? '${start.toStringAsFixed(1)} kg' : '—'),
                        _statColumn(context, 'Current', current != null ? '${current.toStringAsFixed(1)} kg' : '—', highlight: true),
                        _statColumn(context, 'Target', target != null ? '${target.toStringAsFixed(1)} kg' : '—'),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Consumer<WorkoutProvider>(
            builder: (context, workoutProvider, _) {
              final rangeStart = ChartDataHelper.startDateForRange(_range);
              final filtered = workoutProvider.workouts.where((w) => !w.date.isBefore(rangeStart)).toList();

              double totalVolume = 0;
              int totalDuration = 0;
              int durationCount = 0;
              for (final w in filtered) {
                totalVolume += w.calculateVolume();
                if (w.duration != null) {
                  totalDuration += w.duration!;
                  durationCount++;
                }
              }
              final avgTime = durationCount > 0 ? (totalDuration / durationCount).round() : 0;

              return Row(
                children: [
                  Expanded(child: _statCard(context, 'TOTAL VOL', '${totalVolume.toStringAsFixed(0)} kg')),
                  const SizedBox(width: 10),
                  Expanded(child: _statCard(context, 'SESSIONS', '${filtered.length}')),
                  const SizedBox(width: 10),
                  Expanded(child: _statCard(context, 'AVG TIME', '$avgTime min')),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Consumer<WeightEntryProvider>(
            builder: (context, weightProvider, _) {
              return Column(
                children: [
                  _buildWeightChart(context, weightProvider),
                  if (weightProvider.entries.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    CustomCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Weight history', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          ...weightProvider.entries.reversed.take(5).map(
                                (e) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('${e.date.day}/${e.date.month}/${e.date.year}'),
                                      Text('${e.weight.toStringAsFixed(1)} kg'),
                                    ],
                                  ),
                                ),
                              ),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 28),
          CustomCard(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FullHistoryScreen())),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppTheme.cyan.withOpacity(0.12), shape: BoxShape.circle),
                  child: const Icon(Icons.history, color: AppTheme.cyan, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Full History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary(context))),
                      const SizedBox(height: 2),
                      Text('Every logged workout & meal, no limit', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary(context))),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: AppTheme.textSecondary(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceChart(BuildContext context, WorkoutProvider workoutProvider) {
    final distinctExercises = workoutProvider.workouts.map((w) => w.exerciseName).toSet().toList()..sort();
    final exerciseOptions = ['All exercises', ...distinctExercises];
    final currentSelection = exerciseOptions.contains(_selectedExercise) ? _selectedExercise : 'All exercises';

    final filteredWorkouts = currentSelection == 'All exercises'
        ? workoutProvider.workouts
        : workoutProvider.workouts.where((w) => w.exerciseName == currentSelection).toList();

    final points = ChartDataHelper.buildSeries(filteredWorkouts, _range);
    final hasData = points.any((p) => p.volume > 0 || p.oneRM > 0);

    final maxVolume = points.fold<double>(0, (max, p) => p.volume > max ? p.volume : max);
    final maxOneRM = points.fold<double>(0, (max, p) => p.oneRM > max ? p.oneRM : max);
    final gridLineColor = AppTheme.isDark(context) ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05);

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

  Widget _buildWeightChart(BuildContext context, WeightEntryProvider weightProvider) {
    final entries = weightProvider.entries;
    if (entries.length < 2) {
      return const CustomCard(child: Text('Log a few more weigh-ins to see your trend here.'));
    }

    final weights = entries.map((e) => e.weight).toList();
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);
    double padding = (maxWeight - minWeight) * 0.2;
    if (padding < 1) padding = 1;
    final chartMin = (minWeight - padding).clamp(0, double.infinity).toDouble();
    final chartMax = maxWeight + padding;
    final gridLineColor = AppTheme.isDark(context) ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05);

    final spots = List.generate(entries.length, (i) => FlSpot(i.toDouble(), entries[i].weight));

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Weight Trend', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                minY: chartMin,
                maxY: chartMax,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
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
                      interval: entries.length > 6 ? (entries.length / 5).ceilToDouble() : 1,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= entries.length) return const SizedBox.shrink();
                        final d = entries[idx].date;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text('${d.day}/${d.month}', style: TextStyle(fontSize: 9, color: AppTheme.textSecondary(context))),
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
                        if (idx < 0 || idx >= entries.length) return null;
                        final e = entries[idx];
                        return LineTooltipItem(
                          '${e.weight.toStringAsFixed(1)} kg',
                          const TextStyle(color: AppTheme.cyan, fontSize: 11, fontWeight: FontWeight.bold),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppTheme.cyan,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(show: true, color: AppTheme.cyan.withOpacity(0.08)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(BuildContext context, String label, String value) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: AppTheme.textSecondary(context))),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _statColumn(BuildContext context, String label, String value, {bool highlight = false}) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(context))),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: highlight ? AppTheme.lime : AppTheme.textPrimary(context)),
        ),
      ],
    );
  }
}