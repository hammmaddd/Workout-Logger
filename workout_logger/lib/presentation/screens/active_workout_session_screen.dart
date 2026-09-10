import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../data/models/session_set_model.dart';
import '../../data/providers/workout_session_provider.dart';
import '../../data/providers/workout_provider.dart';
import '../theme/app_theme.dart';

class ActiveWorkoutSessionScreen extends StatefulWidget {
  const ActiveWorkoutSessionScreen({Key? key}) : super(key: key);

  @override
  State<ActiveWorkoutSessionScreen> createState() => _ActiveWorkoutSessionScreenState();
}

class _ActiveWorkoutSessionScreenState extends State<ActiveWorkoutSessionScreen> {
  Timer? _elapsedTimer;
  final ValueNotifier<Duration> _elapsedNotifier = ValueNotifier(Duration.zero);

  Timer? _restTimer;
  final ValueNotifier<int> _restNotifier = ValueNotifier(0);
  static const int _defaultRestSeconds = 90;

  @override
  void initState() {
    super.initState();
    final startTime = context.read<WorkoutSessionProvider>().session?.startTime ?? DateTime.now();
    _elapsedNotifier.value = DateTime.now().difference(startTime);
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsedNotifier.value = DateTime.now().difference(startTime);
    });
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    _restTimer?.cancel();
    _elapsedNotifier.dispose();
    _restNotifier.dispose();
    super.dispose();
  }

  void _startRestTimer() {
    _restTimer?.cancel();
    _restNotifier.value = _defaultRestSeconds;
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restNotifier.value <= 1) {
        timer.cancel();
        _restNotifier.value = 0;
        HapticFeedback.mediumImpact();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rest complete — back to it!'), duration: Duration(seconds: 2)),
          );
        }
      } else {
        _restNotifier.value -= 1;
      }
    });
  }

  void _extendRest() => _restNotifier.value += 30;

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _formatRest(int seconds) => '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';

  void _showAddExerciseSheet() {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card(context),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Exercise', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(controller: controller, autofocus: true, decoration: const InputDecoration(hintText: 'e.g., Incline Dumbbell Press')),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final name = controller.text.trim();
                    if (name.isEmpty) return;
                    Navigator.of(sheetContext).pop();
                    await context.read<WorkoutSessionProvider>().addExercise(name, defaultSets: 3);
                  },
                  child: const Text('Add'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmFinish() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.card(dialogContext),
        title: const Text('Finish workout?'),
        content: const Text('Completed sets will be saved to your history.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Finish', style: TextStyle(color: AppTheme.lime))),
        ],
      ),
    );
    if (confirmed != true) return;

    final sessionProvider = context.read<WorkoutSessionProvider>();
    final userId = sessionProvider.session?.userId ?? 1;
    await sessionProvider.finishSession();
    if (!mounted) return;
    await context.read<WorkoutProvider>().loadWorkouts(userId);
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Workout saved!')));
  }

  Future<void> _confirmCancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.card(dialogContext),
        title: const Text('Discard workout?'),
        content: const Text('This session and its logged sets won\'t be saved.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Keep going')),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Discard', style: TextStyle(color: AppTheme.danger))),
        ],
      ),
    );
    if (confirmed != true) return;

    await context.read<WorkoutSessionProvider>().cancelSession();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _confirmCancel();
        return false;
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(onPressed: _confirmCancel, child: const Text('Cancel', style: TextStyle(color: AppTheme.danger))),
                    Consumer<WorkoutSessionProvider>(
                      builder: (context, sessionProvider, _) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: AppTheme.success.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                        child: Text('ACTIVE: ${sessionProvider.session?.name.toUpperCase() ?? ''}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.success)),
                      ),
                    ),
                    TextButton(onPressed: _confirmFinish, child: const Text('Finish', style: TextStyle(color: AppTheme.lime, fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ValueListenableBuilder<Duration>(
                        valueListenable: _elapsedNotifier,
                        builder: (context, elapsed, _) => _timerCard(context, 'ELAPSED TIME', _formatDuration(elapsed), AppTheme.textPrimary(context), null),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ValueListenableBuilder<int>(
                        valueListenable: _restNotifier,
                        builder: (context, restSeconds, _) => _timerCard(
                          context,
                          'REST TIMER',
                          restSeconds > 0 ? _formatRest(restSeconds) : '--:--',
                          AppTheme.warning,
                          restSeconds > 0
                              ? GestureDetector(
                                  onTap: _extendRest,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(color: AppTheme.warning.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                                    child: const Text('+30s', style: TextStyle(fontSize: 10, color: AppTheme.warning)),
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Consumer<WorkoutSessionProvider>(
                  builder: (context, sessionProvider, _) {
                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (sessionProvider.exercises.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: Text('Tap "Add Exercise" below to start logging.', style: TextStyle(color: AppTheme.textSecondary(context), fontSize: 13)),
                            ),
                          ),
                        ...List.generate(sessionProvider.exercises.length, (index) {
                          return Padding(padding: const EdgeInsets.only(bottom: 14), child: _exerciseCard(context, sessionProvider, index));
                        }),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _showAddExerciseSheet,
                            icon: const Icon(Icons.add, color: Colors.black),
                            label: const Text('Add Exercise'),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _timerCard(BuildContext context, String label, String value, Color valueColor, Widget? trailing) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppTheme.card(context), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(fontSize: 10, color: AppTheme.textSecondary(context))),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: valueColor)),
        ],
      ),
    );
  }

  Widget _exerciseCard(BuildContext context, WorkoutSessionProvider sessionProvider, int exerciseIndex) {
    final exercise = sessionProvider.exercises[exerciseIndex];
    final allDone = exercise.sets.isNotEmpty && exercise.completedCount == exercise.sets.length;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: allDone ? AppTheme.lime.withOpacity(0.4) : Colors.transparent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(exercise.exerciseName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    if (exercise.bestWeight != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          exercise.bestWeight! > 0
                              ? 'Best: ${exercise.bestWeight!.toStringAsFixed(1)}kg x ${exercise.bestReps} reps'
                              : 'Best: ${exercise.bestReps} reps',
                          style: TextStyle(fontSize: 11, color: AppTheme.textSecondary(context)),
                        ),
                      ),
                  ],
                ),
              ),
              Text('${exercise.completedCount} of ${exercise.sets.length} sets', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary(context))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(width: 28, child: Text('SET', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary(context)))),
              Expanded(flex: 3, child: Text('PREVIOUS', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary(context)))),
              Expanded(flex: 2, child: Text('KG', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary(context)))),
              Expanded(flex: 2, child: Text('REPS', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary(context)))),
              SizedBox(width: 32, child: Text('OK', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary(context)))),
            ],
          ),
          const SizedBox(height: 8),
          ...List.generate(exercise.sets.length, (setIndex) {
            final set = exercise.sets[setIndex];
            final prev = setIndex < exercise.previousSets.length ? exercise.previousSets[setIndex] : null;
            final isActive = !set.completed && exercise.sets.take(setIndex).every((s) => s.completed);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: _SetRow(
                key: ValueKey('set_${set.id}'),
                set: set,
                previous: prev,
                exerciseIndex: exerciseIndex,
                setIndex: setIndex,
                isActive: isActive,
                onCompleted: _startRestTimer,
              ),
            );
          }),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => sessionProvider.addSet(exerciseIndex, duplicateLast: true),
                  icon: const Icon(Icons.copy, size: 14),
                  label: const Text('Duplicate Last', style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => sessionProvider.addSet(exerciseIndex),
                  icon: const Icon(Icons.add, size: 14, color: AppTheme.lime),
                  label: const Text('Add New Set', style: TextStyle(fontSize: 12, color: AppTheme.lime)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SetRow extends StatefulWidget {
  final SessionSetModel set;
  final SessionSetModel? previous;
  final int exerciseIndex;
  final int setIndex;
  final bool isActive;
  final VoidCallback onCompleted;

  const _SetRow({
    Key? key,
    required this.set,
    required this.previous,
    required this.exerciseIndex,
    required this.setIndex,
    required this.isActive,
    required this.onCompleted,
  }) : super(key: key);

  @override
  State<_SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<_SetRow> {
  late TextEditingController _weightController;
  late TextEditingController _repsController;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(text: widget.set.weight == 0 ? '' : _trimZero(widget.set.weight));
    _repsController = TextEditingController(text: widget.set.reps == 0 ? '' : widget.set.reps.toString());
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  String _trimZero(double value) => value == value.roundToDouble() ? value.toInt().toString() : value.toString();

  @override
  Widget build(BuildContext context) {
    final provider = context.read<WorkoutSessionProvider>();
    final set = widget.set;
    final prev = widget.previous;
    final activeBorder = OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.lime, width: 1.5));

    return Row(
      children: [
        SizedBox(width: 28, child: Text('${set.setNumber}', style: const TextStyle(fontSize: 13))),
        Expanded(
          flex: 3,
          child: Text(
            prev != null
                ? (prev.weight > 0 ? '${_trimZero(prev.weight)}kg x ${prev.reps}' : '${prev.reps} reps')
                : '—',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(context)),
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.only(right: 6),
            child: TextField(
              controller: _weightController,
              enabled: !set.completed,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                isDense: true,
                hintText: '0',
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                focusedBorder: widget.isActive ? activeBorder : null,
                enabledBorder: widget.isActive ? activeBorder : null,
              ),
              onSubmitted: (v) => provider.updateSetValues(widget.exerciseIndex, widget.setIndex, weight: double.tryParse(v) ?? set.weight),
              onEditingComplete: () => provider.updateSetValues(widget.exerciseIndex, widget.setIndex, weight: double.tryParse(_weightController.text) ?? set.weight),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: TextField(
            controller: _repsController,
            enabled: !set.completed,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              focusedBorder: widget.isActive ? activeBorder : null,
              enabledBorder: widget.isActive ? activeBorder : null,
            ),
            onSubmitted: (v) => provider.updateSetValues(widget.exerciseIndex, widget.setIndex, reps: int.tryParse(v) ?? set.reps),
            onEditingComplete: () => provider.updateSetValues(widget.exerciseIndex, widget.setIndex, reps: int.tryParse(_repsController.text) ?? set.reps),
          ),
        ),
        SizedBox(
          width: 32,
          child: GestureDetector(
            onTap: () async {
              final w = double.tryParse(_weightController.text) ?? 0;
              final r = int.tryParse(_repsController.text) ?? 0;
              if (!set.completed && r == 0) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter reps first')));
                return;
              }
              final nowCompleted = await provider.completeSet(widget.exerciseIndex, widget.setIndex, weight: w, reps: r);
              if (nowCompleted) {
                HapticFeedback.lightImpact();
                widget.onCompleted();
              }
            },
            child: Icon(
              set.completed ? Icons.check_circle : Icons.radio_button_unchecked,
              color: set.completed ? AppTheme.success : AppTheme.textSecondary(context),
              size: 22,
            ),
          ),
        ),
      ],
    );
  }
}