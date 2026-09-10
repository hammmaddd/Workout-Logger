import 'package:flutter/material.dart';
import '../models/water_entry_model.dart';
import '../repositories/water_entry_repository.dart';

class WaterEntryProvider extends ChangeNotifier {
  final WaterEntryRepository _repository = WaterEntryRepository();

  List<WaterEntryModel> _entries = [];
  bool _isLoading = false;

  List<WaterEntryModel> get entries => _entries;
  bool get isLoading => _isLoading;

  int get todayTotalMl {
    final today = DateTime.now();
    int total = 0;
    for (final e in _entries) {
      if (e.date.year == today.year && e.date.month == today.month && e.date.day == today.day) {
        total += e.amountMl;
      }
    }
    return total;
  }

  Future<void> addWater(int userId, int ml) async {
    await addEntry(WaterEntryModel(userId: userId, amountMl: ml, date: DateTime.now()));
  }

  Future<void> addEntry(WaterEntryModel entry) async {
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