import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/workout_model.dart';
import '../../data/providers/workout_provider.dart';
import '../theme/app_theme.dart';
import 'app_button.dart';
import 'app_textfield.dart';

class QuickLogBottomSheet extends StatefulWidget {
  const QuickLogBottomSheet({Key? key}) : super(key: key);

  @override
  State<QuickLogBottomSheet> createState() => _QuickLogBottomSheetState();
}

class _QuickLogBottomSheetState extends State<QuickLogBottomSheet> {
  late TextEditingController _exerciseController;
  late TextEditingController _setsController;
  late TextEditingController _repsController;
  late TextEditingController _weightController;
  late TextEditingController _durationController;
  late TextEditingController _notesController;

  String _difficulty = 'medium';
  String _weightUnit = 'kg';

  @override
  void initState() {
    super.initState();
    _exerciseController = TextEditingController();
    _setsController = TextEditingController();
    _repsController = TextEditingController();
    _weightController = TextEditingController();
    _durationController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _exerciseController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addWorkout() {
    if (_exerciseController.text.isEmpty || _setsController.text.isEmpty || _repsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields')));
      return;
    }

    final workout = WorkoutModel(
      userId: 1,
      exerciseName: _exerciseController.text,
      sets: int.parse(_setsController.text),
      reps: int.parse(_repsController.text),
      weight: double.tryParse(_weightController.text) ?? 0,
      weightUnit: _weightUnit,
      duration: int.tryParse(_durationController.text),
      notes: _notesController.text,
      difficulty: _difficulty,
      date: DateTime.now(),
    );

    context.read<WorkoutProvider>().createWorkout(workout);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Workout added!')));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quick Log', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary(context))),
            const SizedBox(height: 4),
            Text('Log a completed exercise without the live session.', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(context))),
            const SizedBox(height: 16),
            AppTextField(label: 'Exercise Name', hint: 'e.g., Bench Press', controller: _exerciseController),
            AppTextField(label: 'Sets', hint: 'e.g., 4', controller: _setsController, keyboardType: TextInputType.number),
            AppTextField(label: 'Reps', hint: 'e.g., 10', controller: _repsController, keyboardType: TextInputType.number),
            AppTextField(label: 'Weight', hint: 'e.g., 50', controller: _weightController, keyboardType: TextInputType.number),
            Row(children: [Expanded(child: DropdownButton<String>(value: _weightUnit, isExpanded: true, items: ['kg', 'lbs'].map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(), onChanged: (v) => setState(() => _weightUnit = v!)))]),
            const SizedBox(height: 16),
            AppTextField(label: 'Duration (minutes)', hint: 'e.g., 45', controller: _durationController, keyboardType: TextInputType.number),
            Row(children: [Expanded(child: DropdownButton<String>(value: _difficulty, isExpanded: true, items: ['easy', 'medium', 'hard'].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(), onChanged: (v) => setState(() => _difficulty = v!)))]),
            const SizedBox(height: 16),
            AppTextField(label: 'Notes', hint: 'Add any notes', controller: _notesController, maxLines: 3),
            AppButton(label: 'Add Workout', onPressed: _addWorkout),
          ],
        ),
      ),
    );
  }
}