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
    final result = await db.query("medications");
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

  // ---------------- TREATMENTS ----------------
  // Insertar tratamiento
Future<int> insertTreatment(Treatment t) async {
  final db = await _dbHelper.db;
  return await db.insert("treatments", t.toMap());
}

// Obtener todos los tratamientos
Future<List<Treatment>> getTreatments() async {
  final db = await _dbHelper.db;
  final result = await db.query("treatments");
  return result.map((e) => Treatment.fromMap(e)).toList();
}

// Obtener solo los tratamientos activos
Future<List<Treatment>> getActiveTreatments() async {
  final db = await _dbHelper.db;
  final result = await db.query("treatments", where: "status = ?", whereArgs: ["ACTIVE"]);
  return result.map((e) => Treatment.fromMap(e)).toList();
}

// Actualizar tratamiento (incluye status)
Future<int> updateTreatment(Treatment t) async {
  final db = await _dbHelper.db;
  return await db.update(
    "treatments",
    t.toMap(),
    where: "id = ?",
    whereArgs: [t.id],
  );
}

// Cambiar estado de un tratamiento a ABANDONED
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
    final result = await db.query("schedule", where: "treatment_id = ?", whereArgs: [treatmentId]);
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
    final result = await db.query("dose_log", where: "schedule_id = ?", whereArgs: [scheduleId]);
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
