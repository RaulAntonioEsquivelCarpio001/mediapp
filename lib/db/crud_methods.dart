// lib/db/crud_methods.dart
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import '../models/form.dart';
import '../models/medication.dart';
import '../models/treatment.dart';
import '../models/schedule.dart';
import '../models/dose_log.dart';
import '../models/mmas8_result.dart';

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
      final res = await db.rawQuery(
        'SELECT COUNT(*) as c FROM treatments WHERE medication_id = ? AND status = ?',
        [id, 'ACTIVE'],
      );

      final count = Sqflite.firstIntValue(res) ?? 0;

      if (count > 0) {
        await db.update(
          'medications',
          {'is_active': 0},
          where: 'id = ?',
          whereArgs: [id],
        );
        return 'deactivated';
      } else {
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

  Future<List<Map<String, dynamic>>> getTreatmentsWithMedicationName() async {
    final db = await _dbHelper.db;
    final result = await db.rawQuery('''
      SELECT t.id, t.medication_id, t.frequency_hours, t.scheduled_time,
             t.start_date, t.duration_days, t.notes, t.status,
             m.name AS medication_name
      FROM treatments t
      LEFT JOIN medications m ON t.medication_id = m.id
      ORDER BY t.start_date DESC;
    ''');
    return result;
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

  /// Borra todos los schedule asociados a un tratamiento.
  Future<int> deleteSchedulesByTreatment(int treatmentId) async {
    final db = await _dbHelper.db;
    return await db.delete(
      "schedule",
      where: "treatment_id = ?",
      whereArgs: [treatmentId],
    );
  }

  /// Genera y guarda en BD el schedule completo para un tratamiento.
  Future<void> generateScheduleForTreatment({
    required int treatmentId,
    required int startDateEpoch,
    required String scheduledTime,
    required int frequencyHours,
    required int durationDays,
  }) async {
    final db = await _dbHelper.db;

    final time = _parseTimeString(scheduledTime);
    if (time == null) {
      throw Exception("generateScheduleForTreatment: formato de hora inválido: $scheduledTime");
    }

    final startDate = DateTime.fromMillisecondsSinceEpoch(startDateEpoch);
    DateTime firstDose = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
      time["hour"]!,
      time["minute"]!,
    );

    final totalDoses = ((durationDays * 24) / frequencyHours).ceil();

    final batch = db.batch();

    for (int i = 0; i < totalDoses; i++) {
      final dt = firstDose.add(Duration(hours: i * frequencyHours));
      final epoch = dt.millisecondsSinceEpoch;

      batch.insert("schedule", {
        "treatment_id": treatmentId,
        "scheduled_timestamp": epoch,
        "status": "PENDING",
      });
    }

    await batch.commit(noResult: true);
  }

  /// Devuelve la lista de tomas del día (schedule entre inicio y fin del día),
  /// con info del medicamento y del treatment.
  Future<List<Map<String, dynamic>>> getScheduleForToday() async {
    final db = await _dbHelper.db;

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59).millisecondsSinceEpoch;

    final result = await db.rawQuery('''
      SELECT s.id as schedule_id,
             s.scheduled_timestamp,
             s.status,
             t.id as treatment_id,
             t.medication_id,
             m.name as med_name,
             m.dose as med_dose
      FROM schedule s
      JOIN treatments t ON t.id = s.treatment_id
      JOIN medications m ON m.id = t.medication_id
      WHERE s.scheduled_timestamp BETWEEN ? AND ?
      ORDER BY s.scheduled_timestamp ASC
    ''', [startOfDay, endOfDay]);

    return result;
  }

  Map<String, int>? _parseTimeString(String timeStr) {
    try {
      final s = timeStr.trim();
      final hasAmPm = s.toUpperCase().contains("AM") || s.toUpperCase().contains("PM");
      if (hasAmPm) {
        final cleaned = s.toUpperCase().replaceAll("AM", "").replaceAll("PM", "").trim();
        final parts = cleaned.split(":");
        int hour = int.tryParse(parts[0].trim()) ?? 0;
        int minute = parts.length > 1 ? int.tryParse(parts[1].trim()) ?? 0 : 0;
        if (s.toUpperCase().contains("PM") && hour != 12) hour += 12;
        if (s.toUpperCase().contains("AM") && hour == 12) hour = 0;
        return {"hour": hour, "minute": minute};
      } else {
        final parts = s.split(":");
        int hour = int.tryParse(parts[0].trim()) ?? 0;
        int minute = parts.length > 1 ? int.tryParse(parts[1].trim()) ?? 0 : 0;
        return {"hour": hour, "minute": minute};
      }
    } catch (e) {
      return null;
    }
  }

  // Helper público para obtener breve descripción del medicamento de un treatment
  Future<String> getMedicationBriefByTreatment(int treatmentId) async {
    final db = await _dbHelper.db;
    final res = await db.rawQuery('''
      SELECT m.name as med_name, m.dose as med_dose
      FROM treatments t
      JOIN medications m ON m.id = t.medication_id
      WHERE t.id = ?
      LIMIT 1
    ''', [treatmentId]);

    if (res.isNotEmpty) {
      final r = res.first;
      return "${r['med_name'] ?? 'Medicamento'} ${r['med_dose'] ?? ''}";
    }
    return "Medicamento";
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

  /// Registra una toma exitosa (TAKEN) y actualiza schedule.
  Future<void> registerDoseTaken({required int scheduleId, String? photoPath}) async {
    final db = await _dbHelper.db;
    final nowEpoch = DateTime.now().millisecondsSinceEpoch;

    await db.insert("dose_log", {
      "schedule_id": scheduleId,
      "actual_timestamp": nowEpoch,
      "status": "TAKEN",
      "photo_path": photoPath,
    });

    await db.update(
      "schedule",
      {"status": "TAKEN"},
      where: "id = ?",
      whereArgs: [scheduleId],
    );
  }

  /// Registra una toma omitida (MISSED) y actualiza schedule.
  Future<void> registerDoseMissed({required int scheduleId}) async {
    final db = await _dbHelper.db;
    final nowEpoch = DateTime.now().millisecondsSinceEpoch;

    await db.insert("dose_log", {
      "schedule_id": scheduleId,
      "actual_timestamp": nowEpoch,
      "status": "MISSED",
      "photo_path": null,
    });

    await db.update(
      "schedule",
      {"status": "MISSED"},
      where: "id = ?",
      whereArgs: [scheduleId],
    );
  }

  // ---------------- MMAS8 RESULTS ----------------
  Future<int> insertMMAS8Result(MMAS8Result result) async {
    final db = await _dbHelper.db;
    return await db.insert("mmas8_results", result.toMap());
  }

  Future<List<MMAS8Result>> getMMAS8Results() async {
    final db = await _dbHelper.db;
    final result = await db.query(
      "mmas8_results",
      orderBy: "date_taken DESC",
    );
    return result.map((e) => MMAS8Result.fromMap(e)).toList();
  }

  Future<int> deleteMMAS8Result(int id) async {
    final db = await _dbHelper.db;
    return await db.delete("mmas8_results", where: "id = ?", whereArgs: [id]);
  }
}
