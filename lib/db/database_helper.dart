import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Singleton
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "mediapp.db");

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    // Tabla forms
    await db.execute('''
      CREATE TABLE forms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      );
    ''');

    // Tabla medications
    await db.execute('''
      CREATE TABLE medications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        dose TEXT NOT NULL,
        form_id INTEGER NOT NULL,
        photo_path TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (form_id) REFERENCES forms(id)
      );
    ''');

    // Tabla treatments
    await db.execute('''
      CREATE TABLE treatments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        medication_id INTEGER NOT NULL,
        frequency_hours INTEGER,
        scheduled_time TEXT,
        start_date INTEGER NOT NULL,
        duration_days INTEGER NOT NULL,
        notes TEXT,
        status TEXT NOT NULL DEFAULT 'ACTIVE',
        FOREIGN KEY (medication_id) REFERENCES medications(id)
      );
    ''');

    // Tabla schedule
    await db.execute('''
      CREATE TABLE schedule (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        treatment_id INTEGER NOT NULL,
        scheduled_timestamp INTEGER NOT NULL,
        status TEXT NOT NULL DEFAULT 'PENDING',
        FOREIGN KEY (treatment_id) REFERENCES treatments(id)
      );
    ''');

    // Tabla dose_log
    await db.execute('''
      CREATE TABLE dose_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        schedule_id INTEGER NOT NULL,
        actual_timestamp INTEGER,
        status TEXT NOT NULL,
        photo_path TEXT,
        FOREIGN KEY (schedule_id) REFERENCES schedule(id)
      );
    ''');

    // Insertar formas básicas
    await db.insert("forms", {"name": "Pastilla"});
    await db.insert("forms", {"name": "Crema"});
    await db.insert("forms", {"name": "Jarabe"});
    await db.insert("forms", {"name": "Inyectable"});
  }
}
