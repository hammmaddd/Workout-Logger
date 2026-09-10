import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/weekly_goal_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_button.dart';

class GoalSettingsBottomSheet extends StatefulWidget {
  const GoalSettingsBottomSheet({Key? key}) : super(key: key);

  @override
  State<GoalSettingsBottomSheet> createState() => _GoalSettingsBottomSheetState();
}

class _GoalSettingsBottomSheetState extends State<GoalSettingsBottomSheet> {
  late int _targetDays;
  late int _firstDayOfWeek;

  static const _weekdayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

  @override
  void initState() {
    super.initState();
    final provider = context.read<WeeklyGoalProvider>();
    _targetDays = provider.targetDays;
    _firstDayOfWeek = provider.firstDayOfWeek;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Set your weekly goal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary(context))),
          const SizedBox(height: 6),
          Text('We recommend training at least 3 days weekly for a better result.',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(context))),
          const SizedBox(height: 20),
          Text('Weekly training days', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textPrimary(context))),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(7, (i) {
              final day = i + 1;
              final selected = day == _targetDays;
              return GestureDetector(
                onTap: () => setState(() => _targetDays = day),
                child: Container(
                  width: 44, height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? AppTheme.lime : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: selected ? AppTheme.lime : AppTheme.divider(context)),
                  ),
                  child: Text('$day', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: selected ? Colors.black : AppTheme.textPrimary(context))),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          Text('First day of week', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textPrimary(context))),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: AppTheme.surfaceTint(context), borderRadius: BorderRadius.circular(10)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _firstDayOfWeek,
                isExpanded: true,
                dropdownColor: AppTheme.card(context),
                style: TextStyle(fontSize: 13, color: AppTheme.textPrimary(context)),
                items: List.generate(7, (i) => DropdownMenuItem(value: i, child: Text(_weekdayNames[i]))),
                onChanged: (value) => setState(() => _firstDayOfWeek = value ?? 0),
              ),
            ),
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Save',
            onPressed: () {
              context.read<WeeklyGoalProvider>().setGoal(targetDays: _targetDays, firstDayOfWeek: _firstDayOfWeek);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}