import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const String dbName = 'workout_logger.db';
  static const int dbVersion = 5;

  static Database? _database;

  static Future<Database> get database async {
    _database ??= await initDatabase();
    return _database!;
  }

  static Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), dbName);
    return await openDatabase(
      path,
      version: dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE,
        age INTEGER,
        gender TEXT,
        height REAL,
        weight REAL,
        targetWeight REAL,
        fitnessGoal TEXT,
        workoutDaysPerWeek TEXT,
        activityLevel TEXT,
        trainingExperience TEXT,
        preferredWorkoutTime TEXT,
        createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE workouts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        exerciseName TEXT NOT NULL,
        sets INTEGER NOT NULL,
        reps INTEGER NOT NULL,
        weight REAL DEFAULT 0,
        weightUnit TEXT DEFAULT 'kg',
        duration INTEGER,
        notes TEXT,
        difficulty TEXT DEFAULT 'medium',
        date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE nutrition (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        foodName TEXT NOT NULL,
        calories INTEGER NOT NULL,
        protein REAL NOT NULL,
        carbs REAL DEFAULT 0,
        fats REAL DEFAULT 0,
        quantity REAL DEFAULT 1,
        mealType TEXT DEFAULT 'snack',
        date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await _createWeightEntriesTable(db);
    await _createWaterEntriesTable(db);
    await _createSavedFoodsTable(db);
    await _createSessionTables(db);
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createWeightEntriesTable(db);
    }
    if (oldVersion < 3) {
      await _createWaterEntriesTable(db);
      await _createSavedFoodsTable(db);
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE users ADD COLUMN workoutDaysPerWeek TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN activityLevel TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN trainingExperience TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN preferredWorkoutTime TEXT');
    }
    if (oldVersion < 5) {
      await _createSessionTables(db);
    }
  }

  static Future<void> _createWeightEntriesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS weight_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        weight REAL NOT NULL,
        date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  static Future<void> _createWaterEntriesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS water_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        amountMl INTEGER NOT NULL,
        date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  static Future<void> _createSavedFoodsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS saved_foods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        name TEXT NOT NULL,
        servingLabel TEXT,
        calories INTEGER NOT NULL,
        protein REAL NOT NULL,
        carbs REAL DEFAULT 0,
        fats REAL DEFAULT 0
      )
    ''');
  }

  static Future<void> _createSessionTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS workout_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        name TEXT NOT NULL,
        startTime TIMESTAMP NOT NULL,
        endTime TIMESTAMP,
        status TEXT NOT NULL DEFAULT 'active'
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS session_exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sessionId INTEGER NOT NULL,
        exerciseName TEXT NOT NULL,
        orderIndex INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS session_sets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sessionExerciseId INTEGER NOT NULL,
        setNumber INTEGER NOT NULL,
        weight REAL NOT NULL DEFAULT 0,
        reps INTEGER NOT NULL DEFAULT 0,
        completed INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  static Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  static Future<Map<String, dynamic>?> getUser(int id) async {
    final db = await database;
    final result = await db.query('users', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  static Future<int> insertWorkout(Map<String, dynamic> workout) async {
    final db = await database;
    return await db.insert('workouts', workout);
  }

  static Future<List<Map<String, dynamic>>> getWorkouts(int userId) async {
    final db = await database;
    return await db.query('workouts', where: 'userId = ?', whereArgs: [userId], orderBy: 'date DESC');
  }

  static Future<Map<String, dynamic>?> getBestWorkoutForExercise(int userId, String exerciseName) async {
    final db = await database;
    final result = await db.query(
      'workouts',
      where: 'userId = ? AND exerciseName = ?',
      whereArgs: [userId, exerciseName],
      orderBy: 'weight DESC, reps DESC',
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  static Future<int> insertNutrition(Map<String, dynamic> nutrition) async {
    final db = await database;
    return await db.insert('nutrition', nutrition);
  }

  static Future<List<Map<String, dynamic>>> getNutrition(int userId) async {
    final db = await database;
    return await db.query('nutrition', where: 'userId = ?', whereArgs: [userId], orderBy: 'date DESC');
  }

  static Future<int> insertWeightEntry(Map<String, dynamic> entry) async {
    final db = await database;
    return await db.insert('weight_entries', entry);
  }

  static Future<List<Map<String, dynamic>>> getWeightEntries(int userId) async {
    final db = await database;
    return await db.query('weight_entries', where: 'userId = ?', whereArgs: [userId], orderBy: 'date ASC');
  }

  static Future<int> insertWaterEntry(Map<String, dynamic> entry) async {
    final db = await database;
    return await db.insert('water_entries', entry);
  }

  static Future<List<Map<String, dynamic>>> getWaterEntries(int userId) async {
    final db = await database;
    return await db.query('water_entries', where: 'userId = ?', whereArgs: [userId], orderBy: 'date DESC');
  }

  static Future<int> insertSavedFood(Map<String, dynamic> food) async {
    final db = await database;
    return await db.insert('saved_foods', food);
  }

  static Future<List<Map<String, dynamic>>> getSavedFoods(int userId) async {
    final db = await database;
    return await db.query('saved_foods', where: 'userId = ?', whereArgs: [userId], orderBy: 'name ASC');
  }

  static Future<void> deleteSavedFood(int id) async {
    final db = await database;
    await db.delete('saved_foods', where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> insertSession(Map<String, dynamic> session) async {
    final db = await database;
    return await db.insert('workout_sessions', session);
  }

  static Future<void> updateSession(int id, Map<String, dynamic> values) async {
    final db = await database;
    await db.update('workout_sessions', values, where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> insertSessionExercise(Map<String, dynamic> exercise) async {
    final db = await database;
    return await db.insert('session_exercises', exercise);
  }

  static Future<int> insertSessionSet(Map<String, dynamic> set) async {
    final db = await database;
    return await db.insert('session_sets', set);
  }

  static Future<void> updateSessionSet(int id, Map<String, dynamic> values) async {
    final db = await database;
    await db.update('session_sets', values, where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Map<String, dynamic>>> getSessionSets(int sessionExerciseId) async {
    final db = await database;
    return await db.query('session_sets', where: 'sessionExerciseId = ?', whereArgs: [sessionExerciseId], orderBy: 'setNumber ASC');
  }

  static Future<Map<String, dynamic>?> getPreviousSessionExercise(int userId, String exerciseName, int excludeSessionId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT se.id as sessionExerciseId, ws.startTime as startTime
      FROM session_exercises se
      JOIN workout_sessions ws ON se.sessionId = ws.id
      WHERE ws.userId = ? AND se.exerciseName = ? AND ws.id != ? AND ws.status = 'finished'
      ORDER BY ws.startTime DESC
      LIMIT 1
    ''', [userId, exerciseName, excludeSessionId]);
    return result.isNotEmpty ? result.first : null;
  }

  static Future<List<Map<String, dynamic>>> getFinishedSessions(int userId, {int limit = 30}) async {
    final db = await database;
    return await db.query(
      'workout_sessions',
      where: 'userId = ? AND status = ?',
      whereArgs: [userId, 'finished'],
      orderBy: 'startTime DESC',
      limit: limit,
    );
  }

  static Future<List<Map<String, dynamic>>> getSessionExerciseNames(int sessionId) async {
    final db = await database;
    return await db.query(
      'session_exercises',
      columns: ['exerciseName'],
      where: 'sessionId = ?',
      whereArgs: [sessionId],
      orderBy: 'orderIndex ASC',
    );
  }

  static Future<void> resetAllUserData(int userId) async {
    final db = await database;

    await db.delete('workouts', where: 'userId = ?', whereArgs: [userId]);
    await db.delete('nutrition', where: 'userId = ?', whereArgs: [userId]);
    await db.delete('weight_entries', where: 'userId = ?', whereArgs: [userId]);
    await db.delete('water_entries', where: 'userId = ?', whereArgs: [userId]);
    await db.delete('saved_foods', where: 'userId = ?', whereArgs: [userId]);

    final sessions = await db.query('workout_sessions', columns: ['id'], where: 'userId = ?', whereArgs: [userId]);
    for (final s in sessions) {
      final sessionId = s['id'];
      final exercises = await db.query('session_exercises', columns: ['id'], where: 'sessionId = ?', whereArgs: [sessionId]);
      for (final e in exercises) {
        await db.delete('session_sets', where: 'sessionExerciseId = ?', whereArgs: [e['id']]);
      }
      await db.delete('session_exercises', where: 'sessionId = ?', whereArgs: [sessionId]);
    }
    await db.delete('workout_sessions', where: 'userId = ?', whereArgs: [userId]);

    await db.delete('users', where: 'id = ?', whereArgs: [userId]);
    await db.delete('sqlite_sequence', where: 'name = ?', whereArgs: ['users']);
  }
}