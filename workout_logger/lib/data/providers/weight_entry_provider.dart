import 'package:flutter/material.dart';
import '../models/weight_entry_model.dart';
import '../repositories/weight_entry_repository.dart';

class WeightEntryProvider extends ChangeNotifier {
  final WeightEntryRepository _repository = WeightEntryRepository();

  List<WeightEntryModel> _entries = [];
  bool _isLoading = false;

  List<WeightEntryModel> get entries => _entries;
  bool get isLoading => _isLoading;

  double? get startWeight => _entries.isEmpty ? null : _entries.first.weight;
  double? get currentWeight => _entries.isEmpty ? null : _entries.last.weight;

  Future<void> addEntry(WeightEntryModel entry) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.addEntry(entry);
      await loadEntries(entry.userId);
    } catch (e) {
      // ignore
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadEntries(int userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _entries = await _repository.getEntries(userId);
    } catch (e) {
      _entries = [];
    }
    _isLoading = false;
    notifyListeners();
  }
}