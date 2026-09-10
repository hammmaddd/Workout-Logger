import '../models/user_model.dart';
import '../../core/database/database_helper.dart';

class UserRepository {
  Future<int> createUser(UserModel user) async {
    return await DatabaseHelper.insertUser(user.toMap());
  }

  Future<UserModel?> getUser(int id) async {
    final data = await DatabaseHelper.getUser(id);
    return data != null ? UserModel.fromMap(data) : null;
  }

  Future<void> updateUser(UserModel user) async {
    final db = await DatabaseHelper.database;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<void> deleteUser(int id) async {
    final db = await DatabaseHelper.database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }
}