import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/onboarding_wizard_screen.dart';
import 'presentation/screens/auth_screen.dart';
import 'data/providers/user_provider.dart';
import 'data/providers/workout_provider.dart';
import 'data/providers/nutrition_provider.dart';
import 'data/providers/weight_entry_provider.dart';
import 'data/providers/water_entry_provider.dart';
import 'data/providers/saved_food_provider.dart';
import 'data/providers/workout_session_provider.dart';
import 'data/providers/theme_provider.dart';
import 'data/providers/notification_preferences_provider.dart';
import 'data/providers/weekly_goal_provider.dart';
import 'data/providers/auth_provider.dart' as app_auth;
import 'core/services/backend_api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BackendApiService.loadSavedUrl();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => app_auth.AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
        ChangeNotifierProvider(create: (_) => NutritionProvider()),
        ChangeNotifierProvider(create: (_) => WeightEntryProvider()),
        ChangeNotifierProvider(create: (_) => WaterEntryProvider()),
        ChangeNotifierProvider(create: (_) => SavedFoodProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutSessionProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadSavedTheme()),
        ChangeNotifierProvider(create: (_) => NotificationPreferencesProvider()..load()),
        ChangeNotifierProvider(create: (_) => WeeklyGoalProvider()..load()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Workout Logger',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const AuthGate(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<app_auth.AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isCheckingSession) {
          return const Scaffold(backgroundColor: AppTheme.darkBg, body: Center(child: CircularProgressIndicator(color: AppTheme.lime)));
        }
        if (!auth.isSignedIn) {
          return const AuthScreen();
        }
        return const AppStartup();
      },
    );
  }
}

class AppStartup extends StatefulWidget {
  const AppStartup({Key? key}) : super(key: key);

  @override
  State<AppStartup> createState() => _AppStartupState();
}

class _AppStartupState extends State<AppStartup> {
  bool _checked = false;
  bool _hasUser = false;

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  Future<void> _checkUser() async {
    final userProvider = context.read<UserProvider>();
    await userProvider.getUser(1);
    setState(() {
      _hasUser = userProvider.currentUser != null;
      _checked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_checked) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return _hasUser ? const HomeScreen() : const OnboardingWizardScreen();
  }
}