import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/user_provider.dart';
import '../../data/providers/workout_provider.dart';
import '../../data/providers/nutrition_provider.dart';
import '../../data/providers/weight_entry_provider.dart';
import '../../data/providers/water_entry_provider.dart';
import '../../data/providers/saved_food_provider.dart';
import '../../data/providers/workout_session_provider.dart';
import '../../data/providers/notification_preferences_provider.dart';
import '../../data/models/workout_model.dart';
import '../../data/models/nutrition_model.dart';
import '../../data/models/weight_entry_model.dart';
import '../../data/models/user_model.dart';
import '../../core/utils/nutrition_goals_helper.dart';
import '../../core/utils/activity_metrics_helper.dart';
import '../widgets/custom_card.dart';
import '../widgets/app_drawer.dart';
import '../widgets/quick_action_card_widget.dart';
import '../widgets/activity_metrics_container.dart';
import '../widgets/workout_history_card.dart';
import '../widgets/nutrition_history_card.dart';
import '../widgets/hydration_tracker_widget.dart';
import '../widgets/quick_log_bottom_sheet.dart';
import '../theme/app_theme.dart';
import 'workout_screen.dart';
import 'nutrition_screen.dart';
import 'progress_screen.dart';
import 'coach_glow_screen.dart';
import 'active_workout_session_screen.dart';
import 'meal_selection_screen.dart';
import 'full_history_screen.dart';

enum _HistoryTab { workout, nutrition }

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  _HistoryTab _historyTab = _HistoryTab.workout;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final userProvider = context.read<UserProvider>();
    await userProvider.getUser(1);

    if (userProvider.currentUser != null) {
      context.read<WorkoutProvider>().loadWorkouts(1);
      context.read<NutritionProvider>().loadNutrition(1);
      context.read<WeightEntryProvider>().loadEntries(1);
      context.read<WaterEntryProvider>().loadEntries(1);
      context.read<SavedFoodProvider>().loadFoods(1);
      context.read<WorkoutSessionProvider>().loadRecentPlans(1);
    }
  }

  void _showStartSessionDialog(BuildContext context) {
    final controller = TextEditingController(text: 'Workout Session');
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.card(dialogContext),
        title: const Text('Name this workout'),
        content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(hintText: 'e.g., Chest Day')),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim().isEmpty ? 'Workout Session' : controller.text.trim();
              Navigator.of(dialogContext).pop();
              await context.read<WorkoutSessionProvider>().startSession(1, name);
              if (!context.mounted) return;
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ActiveWorkoutSessionScreen()));
            },
            child: const Text('Start', style: TextStyle(color: AppTheme.lime)),
          ),
        ],
      ),
    );
  }

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

  void _showHomeMealTypePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card(context),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        Widget tile(String label, String value) {
          return ListTile(
            title: Text(label, style: TextStyle(color: AppTheme.textPrimary(sheetContext))),
            onTap: () {
              Navigator.of(sheetContext).pop();
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => MealSelectionScreen(initialMealType: value)));
            },
          );
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Which meal?', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary(sheetContext))),
                  ),
                ),
                tile('Breakfast', 'breakfast'),
                tile('Lunch', 'lunch'),
                tile('Dinner', 'dinner'),
                tile('Snack', 'snack'),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showHydrationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card(context),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return const Padding(
          padding: EdgeInsets.all(20),
          child: HydrationTrackerWidget(),
        );
      },
    );
  }

  Widget _quickActionTile(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.lime),
      title: Text(label, style: TextStyle(fontSize: 14, color: AppTheme.textPrimary(context))),
      onTap: onTap,
    );
  }

  void _showNotificationPreferencesSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card(context),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Consumer<NotificationPreferencesProvider>(
            builder: (context, prefs, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary(context))),
                  const SizedBox(height: 4),
                  Text('Preferences only for now — reminders aren\'t scheduled yet.',
                      style: TextStyle(fontSize: 11, color: AppTheme.textSecondary(context))),
                  const SizedBox(height: 8),
                  _prefSwitch(context, 'Workout reminder', prefs.workoutReminder, (v) => prefs.setValue('workoutReminder', v)),
                  _prefSwitch(context, 'Rest timer alerts', prefs.restTimer, (v) => prefs.setValue('restTimer', v)),
                  _prefSwitch(context, 'Meal logging reminder', prefs.mealLogging, (v) => prefs.setValue('mealLogging', v)),
                  _prefSwitch(context, 'Water reminder', prefs.waterReminder, (v) => prefs.setValue('waterReminder', v)),
                  _prefSwitch(context, 'Protein goal reminder', prefs.proteinGoalReminder, (v) => prefs.setValue('proteinGoalReminder', v)),
                  _prefSwitch(context, 'Weekly report', prefs.weeklyReport, (v) => prefs.setValue('weeklyReport', v)),
                  _prefSwitch(context, 'Streak reminder', prefs.streakReminder, (v) => prefs.setValue('streakReminder', v)),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _prefSwitch(BuildContext context, String label, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: TextStyle(fontSize: 13, color: AppTheme.textPrimary(context))),
      value: value,
      activeColor: AppTheme.lime,
      onChanged: onChanged,
    );
  }

  void _showWorkoutFabSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card(context),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _quickActionTile(sheetContext, Icons.play_arrow, 'Start Live Session', () {
                  Navigator.of(sheetContext).pop();
                  _showStartSessionDialog(context);
                }),
                _quickActionTile(sheetContext, Icons.edit_note, 'Quick Log', () {
                  Navigator.of(sheetContext).pop();
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: AppTheme.card(context),
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                    builder: (_) => const QuickLogBottomSheet(),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      body: SafeArea(child: _buildBody()),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              backgroundColor: AppTheme.lime,
              onPressed: () => _showWorkoutFabSheet(context),
              child: const Icon(Icons.add, color: Colors.black),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center_rounded), label: 'Workout'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_rounded), label: 'Nutrition'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart_rounded), label: 'Progress'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_rounded), label: 'Coach Glow'),
        ],
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return const WorkoutScreen();
      case 2:
        return const NutritionScreen();
      case 3:
        return const ProgressScreen();
      case 4:
        return const CoachGlowScreen();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildHeader(BuildContext context, UserModel? user) {
    final firstName = user != null && user.name.isNotEmpty ? user.name.split(' ').first : 'there';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _scaffoldKey.currentState?.openDrawer(),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: AppTheme.lime.withOpacity(0.15),
            child: Text(
              user != null && user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
              style: const TextStyle(color: AppTheme.lime, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi $firstName 👋',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary(context)),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text('Ready to crush your goals today?', style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary(context))),
            ],
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => _showNotificationPreferencesSheet(context),
          icon: Icon(Icons.notifications_outlined, color: AppTheme.textPrimary(context)),
        ),
      ],
    );
  }

  Widget _buildQuickStartRow(BuildContext context) {
    final items = <Widget>[
      QuickActionCardWidget(
        icon: Icons.play_arrow,
        title: 'Start Workout',
        subtitle: 'Live session or quick log',
        onTap: () => _showWorkoutFabSheet(context),
      ),
      QuickActionCardWidget(
        icon: Icons.restaurant_menu,
        title: 'Add Today\'s Meal',
        subtitle: 'Log breakfast, lunch & more',
        onTap: () => _showHomeMealTypePicker(context),
      ),
      QuickActionCardWidget(
         icon: Icons.auto_awesome,
         title: 'Coach Glow',
         subtitle: 'Ask about nutrition & fitness',
         onTap: () => setState(() => _selectedIndex = 4),
      ),
      QuickActionCardWidget(
        icon: Icons.water_drop,
        title: 'Daily Hydration',
        subtitle: 'Track your water intake',
        accentColor: AppTheme.cyan,
        onTap: () => _showHydrationSheet(context),
      ),
      QuickActionCardWidget(
        icon: Icons.monitor_weight_outlined,
        title: 'Log Weight',
        subtitle: 'Track your progress',
        onTap: () => _showLogWeightDialog(context),
      ),
    ];

    return SizedBox(
      height: 250,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) => items[index],
      ),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Consumer<UserProvider>(
            builder: (context, userProvider, _) => _buildHeader(context, userProvider.currentUser),
          ),
          const SizedBox(height: 24),
          Text('Quick Start', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary(context))),
          const SizedBox(height: 10),
          _buildQuickStartRow(context),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('My Activity', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary(context))),
              GestureDetector(
                onTap: () => setState(() => _selectedIndex = 3),
                child: const Text('View All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.lime)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Consumer2<WorkoutProvider, UserProvider>(
            builder: (context, workoutProvider, userProvider, _) {
              final weekStart = ActivityMetricsHelper.startDateForRange(ActivityRange.week);
              final workoutsThisWeek = workoutProvider.workouts.where((w) => !w.date.isBefore(weekStart)).length;
              final metrics = ActivityMetricsHelper.compute(workoutProvider.workouts, ActivityRange.week, userProvider.currentUser?.weight);

              return ActivityMetricsContainer(
                workoutsThisWeek: workoutsThisWeek,
                caloriesThisWeek: metrics.estimatedCaloriesBurned,
                activeMinutesThisWeek: metrics.activeMinutes,
              );
            },
          ),
          const SizedBox(height: 28),
          Text('Today\'s Nutrition', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary(context))),
          const SizedBox(height: 12),
          Center(
            child: Consumer2<NutritionProvider, UserProvider>(
              builder: (context, nutritionProvider, userProvider, _) {
                final today = DateTime.now();
                final todayNutrition = nutritionProvider.nutrition
                    .where((n) => n.date.year == today.year && n.date.month == today.month && n.date.day == today.day)
                    .toList();

                final goals = NutritionGoalsHelper.computeGoals(userProvider.currentUser);
                int consumedCalories = 0;
                for (final n in todayNutrition) {
                  consumedCalories += n.getTotalCalories();
                }

                return _buildNutritionRing(context, consumedCalories, goals.calories);
              },
            ),
          ),
          const SizedBox(height: 28),
          Text('Protein Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary(context))),
          const SizedBox(height: 16),
          Consumer2<NutritionProvider, UserProvider>(
            builder: (context, nutritionProvider, userProvider, _) {
              final today = DateTime.now();
              final todayNutrition = nutritionProvider.nutrition
                  .where((n) => n.date.year == today.year && n.date.month == today.month && n.date.day == today.day)
                  .toList();

              final goals = NutritionGoalsHelper.computeGoals(userProvider.currentUser);
              double consumedProtein = 0;
              for (final n in todayNutrition) {
                consumedProtein += n.getTotalProtein();
              }

              return _buildProteinRing(context, consumedProtein, goals.protein);
            },
          ),
          const SizedBox(height: 24),
          Text('Today\'s Workout', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary(context))),
          const SizedBox(height: 12),
          Consumer<WorkoutProvider>(
            builder: (context, workoutProvider, _) {
              final today = DateTime.now();
              final todayWorkouts = workoutProvider.workouts
                  .where((w) => w.date.year == today.year && w.date.month == today.month && w.date.day == today.day)
                  .toList();
              return _buildTodayWorkoutSummary(context, todayWorkouts);
            },
          ),
          const SizedBox(height: 28),
          Text('History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary(context))),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _historyTabButton(context, 'Workout', _HistoryTab.workout)),
              const SizedBox(width: 10),
              Expanded(child: _historyTabButton(context, 'Nutrition', _HistoryTab.nutrition)),
            ],
          ),
          const SizedBox(height: 14),
          if (_historyTab == _HistoryTab.workout)
            Consumer<WorkoutProvider>(builder: (context, workoutProvider, _) => _buildWorkoutHistory(context, workoutProvider.workouts))
          else
            Consumer<NutritionProvider>(builder: (context, nutritionProvider, _) => _buildNutritionHistory(context, nutritionProvider.nutrition)),
        ],
      ),
    );
  }

  Widget _buildNutritionRing(BuildContext context, int consumed, int target) {
    final fraction = target > 0 ? (consumed / target).clamp(0.0, 1.0) : 0.0;
    final remaining = target - consumed;
    final trackColor = AppTheme.isDark(context) ? Colors.white.withOpacity(0.07) : Colors.black.withOpacity(0.06);

    return SizedBox(
      width: 156,
      height: 156,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(width: 156, height: 156, child: CircularProgressIndicator(value: 1, strokeWidth: 13, valueColor: AlwaysStoppedAnimation<Color>(trackColor))),
          SizedBox(
            width: 156,
            height: 156,
            child: CircularProgressIndicator(
              value: fraction,
              strokeWidth: 13,
              strokeCap: StrokeCap.round,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.chartLime(context)),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${remaining < 0 ? 0 : remaining}', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.textPrimary(context))),
              Text('kcal left', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary(context))),
              const SizedBox(height: 6),
              Text('$consumed / $target', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary(context))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProteinRing(BuildContext context, double consumed, double target) {
    final fraction = target > 0 ? (consumed / target).clamp(0.0, 1.0) : 0.0;
    final trackColor = AppTheme.isDark(context) ? Colors.white.withOpacity(0.07) : Colors.black.withOpacity(0.06);

    return Center(
      child: SizedBox(
        width: 176,
        height: 190,
        child: Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            SizedBox(
              width: 176,
              height: 176,
              child: CircularProgressIndicator(value: 1, strokeWidth: 14, valueColor: AlwaysStoppedAnimation<Color>(trackColor)),
            ),
            SizedBox(
              width: 176,
              height: 176,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: fraction),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                builder: (context, value, _) {
                  return CircularProgressIndicator(
                    value: value,
                    strokeWidth: 14,
                    strokeCap: StrokeCap.round,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.success),
                  );
                },
              ),
            ),
            Positioned(
              top: 48,
              child: SizedBox(
                width: 176,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Today', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(context))),
                    const SizedBox(height: 4),
                    Text('${consumed.toStringAsFixed(0)}g',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.textPrimary(context))),
                    Text('Protein', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary(context))),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 168,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.card(context),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.divider(context)),
                ),
                child: Text(
                  'Goal: ${target.toStringAsFixed(0)}g',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary(context)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayWorkoutSummary(BuildContext context, List<WorkoutModel> todayWorkouts) {
    if (todayWorkouts.isEmpty) {
      return CustomCard(child: Text('No workout logged today', style: TextStyle(color: AppTheme.textSecondary(context))));
    }
    final exerciseCount = todayWorkouts.map((w) => w.exerciseName).toSet().length;
    final totalSets = todayWorkouts.fold(0, (sum, w) => sum + w.sets);
    int maxDuration = 0;
    for (final w in todayWorkouts) {
      if ((w.duration ?? 0) > maxDuration) maxDuration = w.duration!;
    }

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TODAY\'S WORKOUT', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary(context))),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _miniStat(context, 'Exercises', '$exerciseCount'),
              _miniStat(context, 'Sets', '$totalSets'),
              _miniStat(context, 'Duration', maxDuration > 0 ? '$maxDuration min' : '—'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary(context))),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 10, color: AppTheme.textSecondary(context))),
      ],
    );
  }

  Widget _historyTabButton(BuildContext context, String label, _HistoryTab tab) {
    final selected = _historyTab == tab;
    return GestureDetector(
      onTap: () => setState(() => _historyTab = tab),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: selected ? AppTheme.lime : AppTheme.card(context), borderRadius: BorderRadius.circular(24)),
        child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? Colors.black : AppTheme.textPrimary(context))),
      ),
    );
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _viewFullHistoryLink() {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => FullHistoryScreen(initialTabIndex: _historyTab == _HistoryTab.workout ? 0 : 1)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('View Full History', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.lime)),
            SizedBox(width: 4),
            Icon(Icons.arrow_forward, size: 14, color: AppTheme.lime),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutHistory(BuildContext context, List<WorkoutModel> workouts) {
    if (workouts.isEmpty) {
      return CustomCard(child: Text('No workouts logged yet', style: TextStyle(color: AppTheme.textSecondary(context))));
    }

    final Map<String, List<WorkoutModel>> grouped = {};
    for (final w in workouts) {
      final key = '${w.date.year}-${w.date.month.toString().padLeft(2, '0')}-${w.date.day.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(key, () => []).add(w);
    }
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    final limitedKeys = sortedKeys.take(4).toList();

    return Column(
      children: [
        ...limitedKeys.map((key) {
          final entries = grouped[key]!;
          final date = entries.first.date;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: WorkoutHistoryCard(dateLabel: _formatDateHeader(date), entries: entries),
          );
        }),
        if (sortedKeys.length > 4) _viewFullHistoryLink(),
      ],
    );
  }

  Widget _buildNutritionHistory(BuildContext context, List<NutritionModel> nutrition) {
    if (nutrition.isEmpty) {
      return CustomCard(child: Text('No meals logged yet', style: TextStyle(color: AppTheme.textSecondary(context))));
    }

    final Map<String, List<NutritionModel>> grouped = {};
    for (final n in nutrition) {
      final key = '${n.date.year}-${n.date.month.toString().padLeft(2, '0')}-${n.date.day.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(key, () => []).add(n);
    }
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    final limitedKeys = sortedKeys.take(4).toList();

    return Column(
      children: [
        ...limitedKeys.map((key) {
          final entries = grouped[key]!;
          final date = entries.first.date;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: NutritionHistoryCard(dateLabel: _formatDateHeader(date), entries: entries),
          );
        }),
        if (sortedKeys.length > 4) _viewFullHistoryLink(),
      ],
    );
  }
}