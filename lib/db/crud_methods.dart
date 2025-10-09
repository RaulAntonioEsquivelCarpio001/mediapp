import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import '../models/form.dart';
import '../models/medication.dart';
import '../models/treatment.dart';
import '../models/schedule.dart';
import '../models/dose_log.dart';

class CrudMethods {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // ---------------- FORMS ----------------
  Future<int> insertForm(FormModel form) async {
    final db = await _dbHelper.db;
    return await db.insert("forms", form.toMap());
  }

  Future<List<FormModel>> getForms() async {
    final db = await _dbHelper.db;
    final result = await db.query("forms");
    return result.map((e) => FormModel.fromMap(e)).toList();
  }

  Future<int> updateForm(FormModel form) async {
    final db = await _dbHelper.db;
    return await db.update(
      "forms",
      form.toMap(),
      where: "id = ?",
      whereArgs: [form.id],
    );
  }

  Future<int> deleteForm(int id) async {
    final db = await _dbHelper.db;
    return await db.delete("forms", where: "id = ?", whereArgs: [id]);
  }

  // ---------------- MEDICATIONS ----------------
  Future<int> insertMedication(Medication med) async {
    final db = await _dbHelper.db;
    return await db.insert("medications", med.toMap());
  }

  Future<List<Medication>> getMedications() async {
    final db = await _dbHelper.db;
    final maps = await db.query(
      "medications",
      where: "is_active = ?",
      whereArgs: [1],
    );
    return List.generate(maps.length, (i) => Medication.fromMap(maps[i]));
  }

  // Devuelve Medication con formName (JOIN)
  Future<List<Medication>> getMedicationsWithFormName() async {
    final db = await _dbHelper.db;
    final result = await db.rawQuery('''
      SELECT m.id, m.name, m.dose, m.form_id, m.photo_path, m.is_active,
             f.name as form_name
      FROM medications m
      LEFT JOIN forms f ON m.form_id = f.id
      WHERE m.is_active = 1
      ORDER BY m.name COLLATE NOCASE
    ''');
    return result.map((e) => Medication.fromMap(e)).toList();
  }

  Future<int> updateMedication(Medication med) async {
    final db = await _dbHelper.db;
    return await db.update(
      "medications",
      med.toMap(),
      where: "id = ?",
      whereArgs: [med.id],
    );
  }

  Future<int> deleteMedication(int id) async {
    final db = await _dbHelper.db;
    return await db.delete("medications", where: "id = ?", whereArgs: [id]);
  }

  Future<String> deleteMedicationSafe(int id) async {
  final db = await _dbHelper.db;
  try {
    // Verificar si el medicamento está en tratamientos activos
    final res = await db.rawQuery(
      'SELECT COUNT(*) as c FROM treatments WHERE medication_id = ? AND status = ?',
      [id, 'ACTIVE'],
    );

    final count = Sqflite.firstIntValue(res) ?? 0;

    if (count > 0) {
      // Hay vínculo con tratamientos activos → desactivar
      await db.update(
        'medications',
        {'is_active': 0},
        where: 'id = ?',
        whereArgs: [id],
      );
      return 'deactivated';
    } else {
      // No hay vínculo → eliminar físicamente
      await db.delete('medications', where: 'id = ?', whereArgs: [id]);
      return 'deleted';
    }
  } catch (e) {
    throw Exception('deleteMedicationSafe error: $e');
  }
}


  // ---------------- TREATMENTS ----------------
  Future<int> insertTreatment(Treatment t) async {
    final db = await _dbHelper.db;
    return await db.insert("treatments", t.toMap());
  }

  Future<List<Treatment>> getTreatments() async {
    final db = await _dbHelper.db;
    final result = await db.query("treatments");
    return result.map((e) => Treatment.fromMap(e)).toList();
  }

  Future<List<Treatment>> getActiveTreatments() async {
    final db = await _dbHelper.db;
    final result =
        await db.query("treatments", where: "status = ?", whereArgs: ["ACTIVE"]);
    return result.map((e) => Treatment.fromMap(e)).toList();
  }

  Future<int> updateTreatment(Treatment t) async {
    final db = await _dbHelper.db;
    return await db.update(
      "treatments",
      t.toMap(),
      where: "id = ?",
      whereArgs: [t.id],
    );
  }

  Future<int> abandonTreatment(int id) async {
    final db = await _dbHelper.db;
    return await db.update(
      "treatments",
      {"status": "ABANDONED"},
      where: "id = ?",
      whereArgs: [id],
    );
  }

  // ---------------- SCHEDULE ----------------
  Future<int> insertSchedule(Schedule s) async {
    final db = await _dbHelper.db;
    return await db.insert("schedule", s.toMap());
  }

  Future<List<Schedule>> getSchedulesByTreatment(int treatmentId) async {
    final db = await _dbHelper.db;
    final result =
        await db.query("schedule", where: "treatment_id = ?", whereArgs: [treatmentId]);
    return result.map((e) => Schedule.fromMap(e)).toList();
  }

  Future<int> updateSchedule(Schedule s) async {
    final db = await _dbHelper.db;
    return await db.update(
      "schedule",
      s.toMap(),
      where: "id = ?",
      whereArgs: [s.id],
    );
  }

  Future<int> deleteSchedule(int id) async {
    final db = await _dbHelper.db;
    return await db.delete("schedule", where: "id = ?", whereArgs: [id]);
  }

  // ---------------- DOSE_LOG ----------------
  Future<int> insertDoseLog(DoseLog d) async {
    final db = await _dbHelper.db;
    return await db.insert("dose_log", d.toMap());
  }

  Future<List<DoseLog>> getDoseLogsBySchedule(int scheduleId) async {
    final db = await _dbHelper.db;
    final result =
        await db.query("dose_log", where: "schedule_id = ?", whereArgs: [scheduleId]);
    return result.map((e) => DoseLog.fromMap(e)).toList();
  }

  Future<int> updateDoseLog(DoseLog d) async {
    final db = await _dbHelper.db;
    return await db.update(
      "dose_log",
      d.toMap(),
      where: "id = ?",
      whereArgs: [d.id],
    );
  }

  Future<int> deleteDoseLog(int id) async {
    final db = await _dbHelper.db;
    return await db.delete("dose_log", where: "id = ?", whereArgs: [id]);
  }
}
