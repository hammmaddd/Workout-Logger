import '../models/weight_entry_model.dart';
import '../../core/database/database_helper.dart';

class WeightEntryRepository {
  Future<int> addEntry(WeightEntryModel entry) async {
    return await DatabaseHelper.insertWeightEntry(entry.toMap());
  }

  Future<List<WeightEntryModel>> getEntries(int userId) async {
    final data = await DatabaseHelper.getWeightEntries(userId);
    return data.map((item) => WeightEntryModel.fromMap(item)).toList();
  }
}