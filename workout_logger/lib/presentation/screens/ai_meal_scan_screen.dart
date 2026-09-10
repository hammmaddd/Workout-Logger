import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/services/backend_api_service.dart';
import '../../data/models/detected_food_item_model.dart';
import '../../data/models/nutrition_model.dart';
import '../../data/providers/auth_provider.dart' as app_auth;
import '../../data/providers/nutrition_provider.dart';
import '../widgets/app_button.dart';
import '../widgets/custom_card.dart';
import '../theme/app_theme.dart';

enum _ScanStage { capture, analyzing, results, noFood, error }

class _StagedItem {
  final String foodName;
  final int calories;
  final double protein;
  final double carbs;
  final double fats;
  final double quantity;
  final String mealType;

  _StagedItem({
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.quantity,
    required this.mealType,
  });

  int get totalCalories => (calories * quantity).round();
}

class AiMealScanScreen extends StatefulWidget {
  final String initialMealType;
  const AiMealScanScreen({Key? key, required this.initialMealType}) : super(key: key);

  @override
  State<AiMealScanScreen> createState() => _AiMealScanScreenState();
}

class _AiMealScanScreenState extends State<AiMealScanScreen> {
  final BackendApiService _backendApi = BackendApiService();
  final List<_StagedItem> _cart = [];

  _ScanStage _stage = _ScanStage.capture;
  File? _imageFile;
  List<DetectedFoodItemModel> _detectedItems = [];
  String? _errorMessage;
  double _progressValue = 0;

  Future<void> _pickAndAnalyze(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 80, maxWidth: 1200);
    if (picked == null) return;

    setState(() {
      _imageFile = File(picked.path);
      _stage = _ScanStage.analyzing;
      _progressValue = 0;
    });

    _animateProgress();

    try {
      final idToken = await context.read<app_auth.AuthProvider>().user?.getIdToken();
      if (idToken == null) throw Exception('Not signed in');

      final bytes = await _imageFile!.readAsBytes();
      final base64Image = base64Encode(bytes);

      final items = await _backendApi.analyzeFoodPhoto(idToken: idToken, imageBase64: base64Image);

      if (!mounted) return;
      setState(() {
        _detectedItems = items;
        _stage = items.isEmpty ? _ScanStage.noFood : _ScanStage.results;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _stage = _ScanStage.error;
      });
    }
  }

  // Cosmetic only — the real backend call is a single request/response,
  // not a multi-stage stream. This just avoids a static, dead-feeling spinner
  // while we wait, capped below 100% until the real result actually arrives.
  Future<void> _animateProgress() async {
    while (mounted && _stage == _ScanStage.analyzing && _progressValue < 0.92) {
      await Future.delayed(const Duration(milliseconds: 220));
      if (!mounted || _stage != _ScanStage.analyzing) return;
      setState(() => _progressValue += 0.05);
    }
  }

  void _reset() {
    setState(() {
      _stage = _ScanStage.capture;
      _imageFile = null;
      _detectedItems = [];
      _errorMessage = null;
    });
  }

  void _openEditSheet(DetectedFoodItemModel item) {
    double quantity = 1;
    final caloriesController = TextEditingController(text: item.calories.toString());
    final proteinController = TextEditingController(text: item.protein.toStringAsFixed(1));
    final carbsController = TextEditingController(text: item.carbs.toStringAsFixed(1));
    final fatsController = TextEditingController(text: item.fats.toStringAsFixed(1));
    String mealType = widget.initialMealType;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card(context),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary(context))),
                    const SizedBox(height: 4),
                    Text(
                      '${item.servingDescription.isNotEmpty ? item.servingDescription : 'AI estimate'} · ${(item.confidence * 100).round()}% confidence',
                      style: TextStyle(fontSize: 11, color: AppTheme.textSecondary(context)),
                    ),
                    const SizedBox(height: 16),
                    _editableRow(context, 'Calories', caloriesController),
                    _editableRow(context, 'Protein (g)', proteinController),
                    _editableRow(context, 'Carbs (g)', carbsController),
                    _editableRow(context, 'Fats (g)', fatsController),
                    const SizedBox(height: 8),
                    Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary(context))),
                    Row(
                      children: [
                        IconButton(
                          onPressed: quantity > 0.5 ? () => setSheetState(() => quantity -= 0.5) : null,
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Text(quantity.toStringAsFixed(1), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary(context))),
                        IconButton(
                          onPressed: () => setSheetState(() => quantity += 0.5),
                          icon: const Icon(Icons.add_circle_outline, color: AppTheme.lime),
                        ),
                      ],
                    ),
                    Text('Meal', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary(context))),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: mealType,
                      isExpanded: true,
                      items: ['breakfast', 'lunch', 'dinner', 'snack']
                          .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                          .toList(),
                      onChanged: (value) => setSheetState(() => mealType = value!),
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      label: 'Add to List',
                      onPressed: () {
                        setState(() {
                          _cart.add(_StagedItem(
                            foodName: item.name,
                            calories: int.tryParse(caloriesController.text.trim()) ?? item.calories,
                            protein: double.tryParse(proteinController.text.trim()) ?? item.protein,
                            carbs: double.tryParse(carbsController.text.trim()) ?? item.carbs,
                            fats: double.tryParse(fatsController.text.trim()) ?? item.fats,
                            quantity: quantity,
                            mealType: mealType,
                          ));
                        });
                        Navigator.of(sheetContext).pop();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _editableRow(BuildContext context, String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Future<void> _saveCart() async {
    final provider = context.read<NutritionProvider>();
    final count = _cart.length;
    for (final entry in _cart) {
      await provider.createNutrition(NutritionModel(
        userId: 1,
        foodName: entry.foodName,
        calories: entry.calories,
        protein: entry.protein,
        carbs: entry.carbs,
        fats: entry.fats,
        quantity: entry.quantity,
        mealType: entry.mealType,
        date: DateTime.now(),
      ));
    }
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$count meal${count == 1 ? '' : 's'} added')),
    );
  }

  Color _confidenceColor(double confidence) {
    if (confidence >= 0.7) return AppTheme.success;
    if (confidence >= 0.4) return AppTheme.warning;
    return AppTheme.danger;
  }

  String _confidenceLabel(double confidence) {
    if (confidence >= 0.7) return 'High confidence';
    if (confidence >= 0.4) return 'Medium confidence';
    return 'Low confidence';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Photo Scan'), centerTitle: true, elevation: 0),
      body: _buildStage(context),
      bottomNavigationBar: _stage == _ScanStage.results && _cart.isNotEmpty
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AppButton(
                  label: 'Add to Daily Intake (${_cart.fold(0, (sum, e) => sum + e.totalCalories)} cal)',
                  onPressed: _saveCart,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildStage(BuildContext context) {
    switch (_stage) {
      case _ScanStage.capture:
        return _buildCaptureStage(context);
      case _ScanStage.analyzing:
        return _buildAnalyzingStage(context);
      case _ScanStage.results:
        return _buildResultsStage(context);
      case _ScanStage.noFood:
        return _buildNoFoodStage(context);
      case _ScanStage.error:
        return _buildErrorStage(context);
    }
  }

  Widget _buildCaptureStage(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(color: AppTheme.lime.withOpacity(0.12), shape: BoxShape.circle),
              child: const Icon(Icons.restaurant_menu, color: AppTheme.lime, size: 40),
            ),
            const SizedBox(height: 20),
            Text('Scan your meal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary(context))),
            const SizedBox(height: 6),
            Text(
              'AI estimates food, ingredients, and calories from a photo. Always reviewable before saving.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(context)),
            ),
            const SizedBox(height: 28),
            AppButton(label: 'Take Photo', onPressed: () => _pickAndAnalyze(ImageSource.camera)),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => _pickAndAnalyze(ImageSource.gallery),
              icon: const Icon(Icons.photo_library_outlined, size: 16),
              label: const Text('Choose from Gallery'),
              style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyzingStage(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: AppTheme.lime.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
              child: const Text('AI ANALYSIS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.lime, letterSpacing: 1)),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CircularProgressIndicator(
                      value: _progressValue,
                      strokeWidth: 10,
                      strokeCap: StrokeCap.round,
                      backgroundColor: AppTheme.surfaceTint(context),
                      valueColor: const AlwaysStoppedAnimation(AppTheme.lime),
                    ),
                  ),
                  Icon(Icons.restaurant_menu, color: AppTheme.cyan, size: 34),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('${(_progressValue * 100).round()}%', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: AppTheme.textPrimary(context))),
            const SizedBox(height: 6),
            Text('Analyzing your meal...', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary(context))),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppTheme.surfaceTint(context), borderRadius: BorderRadius.circular(12)),
              child: Text(
                'Every result is estimated and editable before it\'s saved to your log.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: AppTheme.textSecondary(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsStage(BuildContext context) {
    final cartCalories = _cart.fold(0, (sum, e) => sum + e.totalCalories);
    final cartProtein = _cart.fold(0.0, (sum, e) => sum + (e.protein * e.quantity));
    final cartCarbs = _cart.fold(0.0, (sum, e) => sum + (e.carbs * e.quantity));
    final cartFats = _cart.fold(0.0, (sum, e) => sum + (e.fats * e.quantity));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_imageFile != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(_imageFile!, height: 180, width: double.infinity, fit: BoxFit.cover),
            ),
          const SizedBox(height: 16),
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ADDED SO FAR', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary(context))),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _macroTile(context, 'Calories', '$cartCalories', AppTheme.warning),
                    _macroTile(context, 'Protein', '${cartProtein.toStringAsFixed(0)}g', AppTheme.success),
                    _macroTile(context, 'Carbs', '${cartCarbs.toStringAsFixed(0)}g', AppTheme.cyan),
                    _macroTile(context, 'Fats', '${cartFats.toStringAsFixed(0)}g', AppTheme.danger),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Detected Food Items', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary(context))),
          const SizedBox(height: 12),
          ..._detectedItems.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: CustomCard(
                  onTap: () => _openEditSheet(item),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _confidenceColor(item.confidence).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _confidenceLabel(item.confidence),
                              style: TextStyle(fontSize: 9.5, color: _confidenceColor(item.confidence), fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(Icons.edit_outlined, size: 16, color: AppTheme.textSecondary(context)),
                        ],
                      ),
                      if (item.servingDescription.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(item.servingDescription, style: TextStyle(fontSize: 11, color: AppTheme.textSecondary(context))),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: _miniMacro(context, '${item.calories}', 'cal')),
                          Expanded(child: _miniMacro(context, '${item.protein.toStringAsFixed(0)}g', 'protein')),
                          Expanded(child: _miniMacro(context, '${item.carbs.toStringAsFixed(0)}g', 'carbs')),
                          Expanded(child: _miniMacro(context, '${item.fats.toStringAsFixed(0)}g', 'fat')),
                        ],
                      ),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _macroTile(BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 9.5, color: AppTheme.textSecondary(context))),
      ],
    );
  }

  Widget _miniMacro(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary(context))),
        Text(label, style: TextStyle(fontSize: 9, color: AppTheme.textSecondary(context))),
      ],
    );
  }

  Widget _buildNoFoodStage(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 48, color: AppTheme.textSecondary(context)),
            const SizedBox(height: 16),
            Text('No food detected', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary(context))),
            const SizedBox(height: 6),
            Text(
              'Try a clearer photo, better lighting, or add this meal manually instead.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(context)),
            ),
            const SizedBox(height: 20),
            AppButton(label: 'Try Again', onPressed: _reset),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorStage(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppTheme.danger),
            const SizedBox(height: 16),
            Text('Something went wrong', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary(context))),
            const SizedBox(height: 6),
            Text(
              _errorMessage ?? 'Please try again.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(context)),
            ),
            const SizedBox(height: 20),
            AppButton(label: 'Try Again', onPressed: _reset),
          ],
        ),
      ),
    );
  }
}