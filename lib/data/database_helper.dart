import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/chat_message.dart';
import '../models/journal_entry.dart';
import '../models/mood_entry.dart';
import '../models/routine.dart';
import '../models/risk_history.dart';
import '../models/prediction.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('mental_health.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 7, // 1. BUMP VERSION TO 7
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // 2. UPDATED USERS TABLE SCHEMA FOR NEW INSTALLS
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT,
        profile_picture TEXT,   
        condition TEXT,         
        created_at TEXT NOT NULL
      )
    ''');

    await _createMessagesTable(db);
    await _createJournalsTable(db);
    await _createMoodTable(db);
    await _createRoutinesTable(db);
    await _createRiskHistoryTable(db);
    await _createPredictionsTable(db);
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createMessagesTable(db);
    }
    if (oldVersion < 3) {
      await _createJournalsTable(db);
      await _createMoodTable(db);
    }
    if (oldVersion < 4) {
      await _createRoutinesTable(db);
    }
    if (oldVersion < 5) {
      final columns = await db.rawQuery('PRAGMA table_info(mood_entries)');
      final columnNames = columns.map((c) => c['name'] as String).toList();

      if (!columnNames.contains('sleep_hours')) {
        await db.execute(
          'ALTER TABLE mood_entries ADD COLUMN sleep_hours REAL DEFAULT 8.0',
        );
      }
      if (!columnNames.contains('stress_level')) {
        await db.execute(
          'ALTER TABLE mood_entries ADD COLUMN stress_level INTEGER DEFAULT 5',
        );
      }

      await _createRiskHistoryTable(db);
    }
    if (oldVersion < 6) {
      await _createPredictionsTable(db);
    }

    // 3. MIGRATION LOGIC FOR VERSION 7 (EXISTING USERS)
    if (oldVersion < 7) {
      final columns = await db.rawQuery('PRAGMA table_info(users)');
      final columnNames = columns.map((c) => c['name'] as String).toList();

      if (!columnNames.contains('profile_picture')) {
        await db.execute('ALTER TABLE users ADD COLUMN profile_picture TEXT');
      }
      if (!columnNames.contains('condition')) {
        await db.execute('ALTER TABLE users ADD COLUMN condition TEXT');
      }
    }
  }

  Future _createMessagesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        text TEXT NOT NULL,
        is_user_message INTEGER NOT NULL,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
  }

  Future _createJournalsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS journal_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        mood_emoji TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
  }

  Future _createMoodTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS mood_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        mood_score INTEGER NOT NULL,
        mood_emoji TEXT NOT NULL,
        note TEXT,
        sleep_hours REAL DEFAULT 8.0,
        stress_level INTEGER DEFAULT 5,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
  }

  Future _createRoutinesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS routines (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        type TEXT NOT NULL, 
        is_completed INTEGER NOT NULL,
        scheduled_time TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
  }

  Future _createRiskHistoryTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS risk_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        level TEXT NOT NULL,
        reason TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
  }

  Future _createPredictionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS predictions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        level TEXT NOT NULL,
        confidence REAL NOT NULL,
        summary TEXT NOT NULL,
        suggestions TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
  }

  // ── Chat Message Methods ──

  Future<int> insertMessage(ChatMessage message) async {
    final db = await database;
    return await db.insert('messages', message.toMap());
  }

  Future<List<ChatMessage>> getMessagesForUser(int userId) async {
    final db = await database;
    final maps = await db.query(
      'messages',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'timestamp ASC',
    );
    return maps.map((m) => ChatMessage.fromMap(m)).toList();
  }

  // ── Journal Methods ──

  Future<int> insertJournal(JournalEntry entry) async {
    final db = await database;
    return await db.insert('journal_entries', entry.toMap());
  }

  Future<List<JournalEntry>> getJournalsForUser(int userId) async {
    final db = await database;
    final maps = await db.query(
      'journal_entries',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => JournalEntry.fromMap(m)).toList();
  }

  Future<int> deleteJournal(int id) async {
    final db = await database;
    return await db.delete('journal_entries', where: 'id = ?', whereArgs: [id]);
  }

  // ── Mood Methods ──

  Future<int> insertMood(MoodEntry entry) async {
    final db = await database;
    return await db.insert('mood_entries', entry.toMap());
  }

  Future<List<MoodEntry>> getMoodsForUser(int userId) async {
    final db = await database;
    final maps = await db.query(
      'mood_entries',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => MoodEntry.fromMap(m)).toList();
  }

  Future<List<MoodEntry>> getMoodsForUserInRange(
    int userId,
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final maps = await db.query(
      'mood_entries',
      where: 'user_id = ? AND created_at >= ? AND created_at <= ?',
      whereArgs: [userId, start.toIso8601String(), end.toIso8601String()],
      orderBy: 'created_at ASC',
    );
    return maps.map((m) => MoodEntry.fromMap(m)).toList();
  }

  // ── Routine Methods ──

  Future<int> insertRoutine(Routine routine) async {
    final db = await database;
    return await db.insert('routines', routine.toMap());
  }

  Future<List<Routine>> getRoutinesForUser(int userId) async {
    final db = await database;
    final maps = await db.query(
      'routines',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at ASC',
    );
    return maps.map((m) => Routine.fromMap(m)).toList();
  }

  Future<int> updateRoutine(Routine routine) async {
    final db = await database;
    return await db.update(
      'routines',
      routine.toMap(),
      where: 'id = ?',
      whereArgs: [routine.id],
    );
  }

  Future<int> deleteRoutine(int id) async {
    final db = await database;
    return await db.delete('routines', where: 'id = ?', whereArgs: [id]);
  }

  // ── Risk History Methods ──

  Future<int> insertRiskHistory(RiskHistory history) async {
    final db = await database;
    return await db.insert('risk_history', history.toMap());
  }

  Future<List<RiskHistory>> getRiskHistoryForUser(int userId) async {
    final db = await database;
    final maps = await db.query(
      'risk_history',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => RiskHistory.fromMap(m)).toList();
  }

  // ── Prediction Methods ──

  Future<int> insertPrediction(DepressionPrediction prediction) async {
    final db = await database;
    return await db.insert('predictions', prediction.toMap());
  }

  Future<List<DepressionPrediction>> getPredictionsForUser(int userId) async {
    final db = await database;
    final maps = await db.query(
      'predictions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => DepressionPrediction.fromMap(m)).toList();
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
