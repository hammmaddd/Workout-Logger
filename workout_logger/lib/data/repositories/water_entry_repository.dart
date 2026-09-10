import '../models/water_entry_model.dart';
import '../../core/database/database_helper.dart';

class WaterEntryRepository {
  Future<int> addEntry(WaterEntryModel entry) async {
    return await DatabaseHelper.insertWaterEntry(entry.toMap());
  }

  Future<List<WaterEntryModel>> getEntries(int userId) async {
    final data = await DatabaseHelper.getWaterEntries(userId);
    return data.map((item) => WaterEntryModel.fromMap(item)).toList();
  }
}