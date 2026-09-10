import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/user_model.dart';
import '../../data/models/weight_entry_model.dart';
import '../../data/providers/user_provider.dart';
import '../../data/providers/weight_entry_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_button.dart';
import 'home_screen.dart';

class OnboardingWizardScreen extends StatefulWidget {
  const OnboardingWizardScreen({super.key});

  @override
  State<OnboardingWizardScreen> createState() => _OnboardingWizardScreenState();
}

class _OnboardingWizardScreenState extends State<OnboardingWizardScreen> {
  int _currentStep = 0;
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String? _gender;

  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  String? _fitnessGoal;
  String? _workoutDays;

  final _targetWeightController = TextEditingController();
  String? _activityLevel;
  String? _trainingExperience;

  String? _preferredTime;

  static const _genderOptions = ['male', 'female', 'other'];
  static const _genderLabels = {'male': 'Male', 'female': 'Female', 'other': 'Other'};

  static const _goalOptions = ['strength', 'weight_loss', 'muscle_gain', 'maintenance', 'general_fitness', 'endurance'];
  static const _goalLabels = {
    'strength': 'Strength',
    'weight_loss': 'Fat Loss',
    'muscle_gain': 'Muscle Gain',
    'maintenance': 'Maintenance',
    'general_fitness': 'General Fitness',
    'endurance': 'Endurance',
  };

  static const _workoutDaysOptions = ['2', '3', '4', '5+'];
  static const _activityOptions = ['Sedentary', 'Light', 'Moderate', 'Active', 'Very Active'];
  static const _experienceOptions = ['Beginner', 'Intermediate', 'Advanced'];
  static const _timeOptions = ['Morning', 'Afternoon', 'Evening', 'Night'];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  double? get _liveBMI {
    final h = double.tryParse(_heightController.text.trim());
    final w = double.tryParse(_weightController.text.trim());
    if (h == null || w == null || h <= 0 || w <= 0) return null;
    final hm = h / 100;
    return w / (hm * hm);
  }

  String _bmiCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Optimal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Color _bmiColor(double bmi) {
    if (bmi < 18.5) return AppTheme.cyan;
    if (bmi < 25) return AppTheme.success;
    if (bmi < 30) return AppTheme.warning;
    return AppTheme.danger;
  }

  void _goBack() {
    if (_currentStep > 0) setState(() => _currentStep -= 1);
  }

  void _handleNext() {
    if (_currentStep == 0) {
      if (_nameController.text.trim().isEmpty || _ageController.text.trim().isEmpty || _gender == null) {
        _showError('Please fill in your name, age, and gender');
        return;
      }
      if (int.tryParse(_ageController.text.trim()) == null) {
        _showError('Please enter a valid age');
        return;
      }
      setState(() => _currentStep = 1);
    } else if (_currentStep == 1) {
      final h = double.tryParse(_heightController.text.trim());
      final w = double.tryParse(_weightController.text.trim());
      if (h == null || w == null) {
        _showError('Please enter valid height and weight');
        return;
      }
      if (_fitnessGoal == null) {
        _showError('Please select a fitness goal');
        return;
      }
      if (_workoutDays == null) {
        _showError('Please select your weekly workout days');
        return;
      }
      setState(() => _currentStep = 2);
    } else if (_currentStep == 2) {
      final tw = double.tryParse(_targetWeightController.text.trim());
      if (tw == null) {
        _showError('Please enter a valid target weight');
        return;
      }
      if (_activityLevel == null) {
        _showError('Please select your activity level');
        return;
      }
      if (_trainingExperience == null) {
        _showError('Please select your training experience');
        return;
      }
      setState(() => _currentStep = 3);
    } else {
      if (_preferredTime == null) {
        _showError('Please select a preferred workout time');
        return;
      }
      _createProfile();
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _createProfile() async {
    setState(() => _isLoading = true);

    final user = UserModel(
      name: _nameController.text.trim(),
      age: int.parse(_ageController.text.trim()),
      gender: _gender,
      height: double.parse(_heightController.text.trim()),
      weight: double.parse(_weightController.text.trim()),
      targetWeight: double.parse(_targetWeightController.text.trim()),
      fitnessGoal: _fitnessGoal,
      workoutDaysPerWeek: _workoutDays,
      activityLevel: _activityLevel,
      trainingExperience: _trainingExperience,
      preferredWorkoutTime: _preferredTime,
    );

    try {
      await context.read<UserProvider>().createUser(user);
      await context.read<WeightEntryProvider>().addEntry(
            WeightEntryModel(userId: 1, weight: user.weight!, date: DateTime.now()),
          );
      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError('Failed to save profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            children: [
              Row(
                children: [
                  if (_currentStep > 0)
                    IconButton(
                      onPressed: _goBack,
                      icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppTheme.darkText),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    )
                  else
                    const SizedBox(height: 32),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('ONBOARDING',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.lime, letterSpacing: 1)),
                  Text('STEP ${_currentStep + 1} OF 4',
                      style: const TextStyle(fontSize: 11, color: AppTheme.darkTextSecondary)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: List.generate(4, (i) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                      decoration: BoxDecoration(
                        color: i <= _currentStep ? AppTheme.lime : Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 28),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildStepContent(),
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: _currentStep == 3 ? 'Create Profile' : 'Continue Setup',
                onPressed: _handleNext,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep0();
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2();
      default:
        return _buildStep3();
    }
  }

  Widget _buildStep0() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Let\'s get to know you', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
        const SizedBox(height: 6),
        const Text('Basic info to personalize your experience.',
            style: TextStyle(fontSize: 13, color: AppTheme.darkTextSecondary)),
        const SizedBox(height: 24),
        _fieldLabel('Full Name'),
        _plainField(_nameController, 'e.g., John Doe'),
        const SizedBox(height: 16),
        _fieldLabel('Age'),
        _plainField(_ageController, 'e.g., 25', keyboardType: TextInputType.number),
        const SizedBox(height: 20),
        _fieldLabel('Gender'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _genderOptions
              .map((g) => _choiceChip(_genderLabels[g]!, _gender == g, () => setState(() => _gender = g)))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildStep1() {
    final bmi = _liveBMI;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Body Metrics & Setup', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
        const SizedBox(height: 6),
        const Text('Let\'s calculate your BMI & optimize your weekly splits.',
            style: TextStyle(fontSize: 13, color: AppTheme.darkTextSecondary)),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('Height'),
                  _unitField(_heightController, 'cm', onChanged: () => setState(() {})),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('Weight'),
                  _unitField(_weightController, 'kg', onChanged: () => setState(() {})),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _fieldLabel('Fitness Goals'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _goalOptions
              .map((g) => _choiceChip(_goalLabels[g]!, _fitnessGoal == g, () => setState(() => _fitnessGoal = g)))
              .toList(),
        ),
        const SizedBox(height: 20),
        _fieldLabel('Weekly Workout Days'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _workoutDaysOptions
              .map((d) => _choiceChip(d, _workoutDays == d, () => setState(() => _workoutDays = d)))
              .toList(),
        ),
        const SizedBox(height: 20),
        _buildBMICard(bmi),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Your Training Profile', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
        const SizedBox(height: 6),
        const Text('Helps us tailor recommendations to your experience.',
            style: TextStyle(fontSize: 13, color: AppTheme.darkTextSecondary)),
        const SizedBox(height: 24),
        _fieldLabel('Target Weight'),
        _unitField(_targetWeightController, 'kg'),
        const SizedBox(height: 20),
        _fieldLabel('Activity Level'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _activityOptions
              .map((a) => _choiceChip(a, _activityLevel == a, () => setState(() => _activityLevel = a)))
              .toList(),
        ),
        const SizedBox(height: 20),
        _fieldLabel('Training Experience'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _experienceOptions
              .map((e) => _choiceChip(e, _trainingExperience == e, () => setState(() => _trainingExperience = e)))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Final Touches', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
        const SizedBox(height: 6),
        const Text('One last thing before we build your dashboard.',
            style: TextStyle(fontSize: 13, color: AppTheme.darkTextSecondary)),
        const SizedBox(height: 24),
        _fieldLabel('Preferred Workout Time'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _timeOptions
              .map((t) => _choiceChip(t, _preferredTime == t, () => setState(() => _preferredTime = t)))
              .toList(),
        ),
        const SizedBox(height: 24),
        _buildReviewCard(),
      ],
    );
  }

  Widget _buildReviewCard() {
    final rows = <MapEntry<String, String>>[
      MapEntry('Name', _nameController.text.trim()),
      MapEntry('Age', _ageController.text.trim()),
      MapEntry('Gender', _gender != null ? _genderLabels[_gender]! : '—'),
      MapEntry('Height', '${_heightController.text.trim()} cm'),
      MapEntry('Weight', '${_weightController.text.trim()} kg'),
      MapEntry('Target Weight', '${_targetWeightController.text.trim()} kg'),
      MapEntry('Goal', _fitnessGoal != null ? _goalLabels[_fitnessGoal]! : '—'),
      MapEntry('Workout Days', _workoutDays ?? '—'),
      MapEntry('Activity Level', _activityLevel ?? '—'),
      MapEntry('Experience', _trainingExperience ?? '—'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Review your profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.darkText)),
          const SizedBox(height: 12),
          ...rows.map((r) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(r.key, style: const TextStyle(fontSize: 12, color: AppTheme.darkTextSecondary)),
                    Text(r.value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.darkText)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildBMICard(double? bmi) {
    final category = bmi != null ? _bmiCategory(bmi) : null;
    final color = bmi != null ? _bmiColor(bmi) : AppTheme.darkTextSecondary;
    final clampedBmi = (bmi ?? 20).clamp(15, 35);
    final fraction = ((clampedBmi - 15) / 20).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Calculated BMI', style: TextStyle(fontSize: 12, color: AppTheme.darkTextSecondary)),
              if (category != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                  child: Text(category, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(bmi != null ? bmi.toStringAsFixed(1) : '—',
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
              const SizedBox(width: 6),
              const Text('kg/m²', style: TextStyle(fontSize: 12, color: AppTheme.darkTextSecondary)),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Row(
                  children: [
                    Expanded(flex: 4, child: Container(height: 8, color: AppTheme.cyan)),
                    Expanded(flex: 6, child: Container(height: 8, color: AppTheme.success)),
                    Expanded(flex: 5, child: Container(height: 8, color: AppTheme.warning)),
                    Expanded(flex: 5, child: Container(height: 8, color: AppTheme.danger)),
                  ],
                ),
              ),
              if (bmi != null)
                Positioned(
                  top: -3,
                  left: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment(fraction * 2 - 1, 0),
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: color, width: 3),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('18.5', style: TextStyle(fontSize: 10, color: AppTheme.darkTextSecondary)),
              Text('25.0', style: TextStyle(fontSize: 10, color: AppTheme.darkTextSecondary)),
              Text('30.0', style: TextStyle(fontSize: 10, color: AppTheme.darkTextSecondary)),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'General screening metric only. Does not measure muscle mass directly.',
            style: TextStyle(fontSize: 11, color: AppTheme.darkTextSecondary),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.darkText)),
    );
  }

  Widget _plainField(TextEditingController controller, String hint, {TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppTheme.darkText),
      decoration: InputDecoration(hintText: hint),
    );
  }

  Widget _unitField(TextEditingController controller, String unit, {VoidCallback? onChanged}) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (_) => onChanged?.call(),
      style: const TextStyle(color: AppTheme.darkText),
      decoration: InputDecoration(hintText: '0', suffixText: unit),
    );
  }

  Widget _choiceChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.lime : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: selected ? AppTheme.lime : Colors.white24),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.black : AppTheme.darkText,
          ),
        ),
      ),
    );
  }
}