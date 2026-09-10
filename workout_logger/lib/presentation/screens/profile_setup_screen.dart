import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/user_model.dart';
import '../../data/models/weight_entry_model.dart';
import '../../data/providers/user_provider.dart';
import '../../data/providers/weight_entry_provider.dart';
import '../widgets/app_button.dart';
import '../widgets/app_textfield.dart';
import 'home_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _targetWeightController;

  String _gender = 'male';
  String _fitnessGoal = 'general_fitness';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _ageController = TextEditingController();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
    _targetWeightController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  void _setupProfile() async {
    if (_nameController.text.trim().isEmpty ||
        _ageController.text.trim().isEmpty ||
        _heightController.text.trim().isEmpty ||
        _weightController.text.trim().isEmpty ||
        _targetWeightController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final age = int.tryParse(_ageController.text.trim());
    final height = double.tryParse(_heightController.text.trim());
    final weight = double.tryParse(_weightController.text.trim());
    final targetWeight = double.tryParse(_targetWeightController.text.trim());

    if (age == null || height == null || weight == null || targetWeight == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid numbers')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final user = UserModel(
      name: _nameController.text.trim(),
      age: age,
      gender: _gender,
      height: height,
      weight: weight,
      targetWeight: targetWeight,
      fitnessGoal: _fitnessGoal,
    );

    try {
      await context.read<UserProvider>().createUser(user);

      await context.read<WeightEntryProvider>().addEntry(
            WeightEntryModel(userId: 1, weight: weight, date: DateTime.now()),
          );

      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setup Profile'), centerTitle: true, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Create Your Profile', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Let us know your fitness goals', style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 24),
            AppTextField(label: 'Full Name', hint: 'e.g., John Doe', controller: _nameController),
            AppTextField(label: 'Age', hint: 'e.g., 25', controller: _ageController, keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            const Text('Gender', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: _gender,
              isExpanded: true,
              items: ['male', 'female', 'other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
              onChanged: (value) => setState(() => _gender = value!),
            ),
            const SizedBox(height: 16),
            AppTextField(label: 'Height (cm)', hint: 'e.g., 175', controller: _heightController, keyboardType: TextInputType.number),
            AppTextField(label: 'Current Weight (kg)', hint: 'e.g., 75', controller: _weightController, keyboardType: TextInputType.number),
            AppTextField(label: 'Target Weight (kg)', hint: 'e.g., 70', controller: _targetWeightController, keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            const Text('Fitness Goal', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: _fitnessGoal,
              isExpanded: true,
              items: ['weight_loss', 'muscle_gain', 'maintenance', 'general_fitness']
                  .map((goal) => DropdownMenuItem(value: goal, child: Text(goal)))
                  .toList(),
              onChanged: (value) => setState(() => _fitnessGoal = value!),
            ),
            const SizedBox(height: 32),
            AppButton(label: 'Create Profile', onPressed: _setupProfile, isLoading: _isLoading),
          ],
        ),
      ),
    );
  }
}