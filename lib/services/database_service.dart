import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/symptom_log.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      print('🔵 [DB] Starting database initialization...');

      final databasesPath = await getDatabasesPath();
      print('🔵 [DB] Databases path: $databasesPath');

      final path = join(databasesPath, 'yakats.db');
      print('🔵 [DB] Database path: $path');

      final database = await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
        onOpen: (db) {
          print('🟢 [DB] Database opened successfully');
        },
      );

      print('🟢 [DB] Database initialized successfully');
      return database;
    } catch (e) {
      print('🔴 [DB] Error initializing database: $e');
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
      print('🔵 [DB] Creating tables...');

      await db.execute('''
        CREATE TABLE symptom_logs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          symptomType TEXT NOT NULL,
          severity INTEGER NOT NULL,
          notes TEXT,
          dateTime TEXT NOT NULL,
          latitude REAL,
          longitude REAL,
          locationName TEXT,
          temperature REAL,
          humidity REAL,
          windSpeed REAL,
          weatherCondition TEXT,
          createdAt TEXT DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      print('🟢 [DB] Tables created successfully');
    } catch (e) {
      print('🔴 [DB] Error creating tables: $e');
      rethrow;
    }
  }

  Future<int> insertSymptomLog(SymptomLog log) async {
    try {
      print('🔵 [DB] Inserting symptom log...');
      print('🔵 [DB] Symptom: ${log.symptomType}, Severity: ${log.severity}');

      final db = await database;

      print('🔵 [DB] Database instance obtained');
      print('🔵 [DB] Converting to map...');

      final mapData = log.toMap();
      print('🔵 [DB] Map data: $mapData');

      print('🔵 [DB] Executing insert...');
      final result = await db.insert(
        'symptom_logs',
        mapData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      print('🟢 [DB] Symptom inserted successfully with ID: $result');
      return result;
    } catch (e) {
      print('🔴 [DB] Error inserting symptom: $e');
      print('🔴 [DB] Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<List<SymptomLog>> getAllSymptomLogs() async {
    try {
      print('🔵 [DB] Fetching all symptom logs...');

      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('symptom_logs');

      print('🟢 [DB] Retrieved ${maps.length} symptom logs');
      return List.generate(maps.length, (i) => SymptomLog.fromMap(maps[i]));
    } catch (e) {
      print('🔴 [DB] Error fetching symptom logs: $e');
      rethrow;
    }
  }

  Future<List<SymptomLog>> getSymptomLogsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      print('🔵 [DB] Fetching symptom logs between $startDate and $endDate');

      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'symptom_logs',
        where: 'dateTime BETWEEN ? AND ?',
        whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      );

      print('🟢 [DB] Retrieved ${maps.length} symptom logs for date range');
      return List.generate(maps.length, (i) => SymptomLog.fromMap(maps[i]));
    } catch (e) {
      print('🔴 [DB] Error fetching symptom logs by date: $e');
      rethrow;
    }
  }

  Future<int> deleteSymptomLog(int id) async {
    try {
      print('🔵 [DB] Deleting symptom log with ID: $id');

      final db = await database;
      final result = await db.delete(
        'symptom_logs',
        where: 'id = ?',
        whereArgs: [id],
      );

      print('🟢 [DB] Deleted $result row(s)');
      return result;
    } catch (e) {
      print('🔴 [DB] Error deleting symptom log: $e');
      rethrow;
    }
  }

  Future<int> updateSymptomLog(SymptomLog log) async {
    try {
      print('🔵 [DB] Updating symptom log with ID: ${log.id}');

      final db = await database;
      final result = await db.update(
        'symptom_logs',
        log.toMap(),
        where: 'id = ?',
        whereArgs: [log.id],
      );

      print('🟢 [DB] Updated $result row(s)');
      return result;
    } catch (e) {
      print('🔴 [DB] Error updating symptom log: $e');
      rethrow;
    }
  }

  Future<int> getSymptomLogCount() async {
    try {
      print('🔵 [DB] Counting symptom logs...');

      final db = await database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM symptom_logs',
      );
      final count = (result.first['count'] as int?) ?? 0;

      print('🟢 [DB] Total symptom logs: $count');
      return count;
    } catch (e) {
      print('🔴 [DB] Error counting symptom logs: $e');
      rethrow;
    }
  }
}
