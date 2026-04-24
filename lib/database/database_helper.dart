import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/symptom_log.dart';
import '../models/alert_log.dart';

class DatabaseHelper {
  // Singleton pattern
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static DatabaseHelper get instance => _instance;
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  // ─── Table Names ───────────────────────────────────────────
  static const String tableSymptoms = 'symptoms';
  static const String tableAlerts = 'alerts';

  // ─── Symptoms Table Columns ────────────────────────────────
  static const String colId = 'id';
  static const String colSymptomType = 'symptomType';
  static const String colSeverity = 'severity';
  static const String colNotes = 'notes';
  static const String colDateTime = 'dateTime';
  static const String colLatitude = 'latitude';
  static const String colLongitude = 'longitude';
  static const String colLocationName = 'locationName';
  static const String colTemperature = 'temperature';
  static const String colHumidity = 'humidity';
  static const String colWindSpeed = 'windSpeed';
  static const String colWeatherCondition = 'weatherCondition';

  // ─── Alerts Table Columns ──────────────────────────────────
  static const String colAlertId = 'id';
  static const String colAlertDateTime = 'dateTime';
  static const String colAlertTitle = 'title';
  static const String colAlertMessage = 'message';
  static const String colRiskScore = 'riskScore';
  static const String colRiskLevel = 'riskLevel';
  static const String colTriggers = 'triggers';
  static const String colIsRead = 'isRead';

  // ─── Database Getter ───────────────────────────────────────
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // ─── Initialize Database ───────────────────────────────────
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'yakats.db');

    return await openDatabase(
      path,
      version: 2, // bumped to 2 so alerts table is created on upgrade
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // ─── Create Tables ─────────────────────────────────────────
  Future<void> _onCreate(Database db, int version) async {
    // Symptoms table
    await db.execute('''
      CREATE TABLE $tableSymptoms (
        $colId               INTEGER PRIMARY KEY AUTOINCREMENT,
        $colSymptomType      TEXT    NOT NULL,
        $colSeverity         INTEGER NOT NULL,
        $colNotes            TEXT,
        $colDateTime         TEXT    NOT NULL,
        $colLatitude         REAL,
        $colLongitude        REAL,
        $colLocationName     TEXT,
        $colTemperature      REAL,
        $colHumidity         REAL,
        $colWindSpeed        REAL,
        $colWeatherCondition TEXT
      )
    ''');

    // Alerts table
    await db.execute('''
      CREATE TABLE $tableAlerts (
        $colAlertId       INTEGER PRIMARY KEY AUTOINCREMENT,
        $colAlertDateTime TEXT    NOT NULL,
        $colAlertTitle    TEXT    NOT NULL,
        $colAlertMessage  TEXT    NOT NULL,
        $colRiskScore     REAL    NOT NULL,
        $colRiskLevel     TEXT    NOT NULL,
        $colTriggers      TEXT    NOT NULL,
        $colIsRead        INTEGER DEFAULT 0
      )
    ''');

    print('🟢 [DB] Tables created successfully');
  }

  // ─── Upgrade Handler ───────────────────────────────────────
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add alerts table if upgrading from version 1
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tableAlerts (
          $colAlertId       INTEGER PRIMARY KEY AUTOINCREMENT,
          $colAlertDateTime TEXT    NOT NULL,
          $colAlertTitle    TEXT    NOT NULL,
          $colAlertMessage  TEXT    NOT NULL,
          $colRiskScore     REAL    NOT NULL,
          $colRiskLevel     TEXT    NOT NULL,
          $colTriggers      TEXT    NOT NULL,
          $colIsRead        INTEGER DEFAULT 0
        )
      ''');
      print('🟢 [DB] Upgraded to version 2 - alerts table added');
    }
  }

  // ════════════════════════════════════════════════════════════
  //  SYMPTOM METHODS
  // ════════════════════════════════════════════════════════════

  // Insert a symptom log
  Future<int> insertSymptom(SymptomLog symptom) async {
    final db = await database;
    final id = await db.insert(
      tableSymptoms,
      symptom.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('🟢 [DB] Symptom inserted with id: $id');
    return id;
  }

  // Get all symptoms (newest first)
  Future<List<SymptomLog>> getAllSymptoms() async {
    final db = await database;
    final maps = await db.query(tableSymptoms, orderBy: '$colDateTime DESC');
    return maps.map((map) => SymptomLog.fromMap(map)).toList();
  }

  // Get symptoms by date range
  Future<List<SymptomLog>> getSymptomsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final maps = await db.query(
      tableSymptoms,
      where: '$colDateTime BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: '$colDateTime DESC',
    );
    return maps.map((map) => SymptomLog.fromMap(map)).toList();
  }

  // Get recent symptoms (last N days)
  Future<List<SymptomLog>> getRecentSymptoms(int days) async {
    final start = DateTime.now().subtract(Duration(days: days));
    final db = await database;
    final maps = await db.query(
      tableSymptoms,
      where: '$colDateTime >= ?',
      whereArgs: [start.toIso8601String()],
      orderBy: '$colDateTime DESC',
    );
    return maps.map((map) => SymptomLog.fromMap(map)).toList();
  }

  // Get symptom count
  Future<int> getSymptomCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableSymptoms',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Update a symptom
  Future<int> updateSymptom(SymptomLog symptom) async {
    final db = await database;
    return await db.update(
      tableSymptoms,
      symptom.toMap(),
      where: '$colId = ?',
      whereArgs: [symptom.id],
    );
  }

  // Delete a symptom
  Future<int> deleteSymptom(int id) async {
    final db = await database;
    return await db.delete(tableSymptoms, where: '$colId = ?', whereArgs: [id]);
  }

  // Delete all symptoms
  Future<int> deleteAllSymptoms() async {
    final db = await database;
    return await db.delete(tableSymptoms);
  }

  // ════════════════════════════════════════════════════════════
  //  ALERT METHODS
  // ════════════════════════════════════════════════════════════

  // Insert an alert
  Future<int> insertAlert(AlertLog alert) async {
    final db = await database;
    final id = await db.insert(
      tableAlerts,
      alert.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('🟢 [DB] Alert inserted with id: $id');
    return id;
  }

  // Get all alerts (newest first)
  Future<List<AlertLog>> getAllAlerts() async {
    final db = await database;
    final maps = await db.query(tableAlerts, orderBy: '$colAlertDateTime DESC');
    return maps.map((map) => AlertLog.fromMap(map)).toList();
  }

  // Get unread alerts
  Future<List<AlertLog>> getUnreadAlerts() async {
    final db = await database;
    final maps = await db.query(
      tableAlerts,
      where: '$colIsRead = ?',
      whereArgs: [0],
      orderBy: '$colAlertDateTime DESC',
    );
    return maps.map((map) => AlertLog.fromMap(map)).toList();
  }

  // Mark single alert as read
  Future<int> markAlertAsRead(int id) async {
    final db = await database;
    return await db.update(
      tableAlerts,
      {colIsRead: 1},
      where: '$colAlertId = ?',
      whereArgs: [id],
    );
  }

  // Mark all alerts as read
  Future<int> markAllAlertsAsRead() async {
    final db = await database;
    return await db.update(tableAlerts, {colIsRead: 1});
  }

  // Delete single alert
  Future<int> deleteAlert(int id) async {
    final db = await database;
    return await db.delete(
      tableAlerts,
      where: '$colAlertId = ?',
      whereArgs: [id],
    );
  }

  // Delete all alerts
  Future<int> deleteAllAlerts() async {
    final db = await database;
    return await db.delete(tableAlerts);
  }

  // ════════════════════════════════════════════════════════════
  //  UTILITY
  // ════════════════════════════════════════════════════════════

  // Close database
  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }

  // Delete entire database (for testing/reset)
  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'yakats.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
    print('🟢 [DB] Database deleted');
  }
}
