class Treatment {
  final int? id;
  final int medicationId;
  final int? frequencyHours;
  final String? scheduledTime;
  final int startDate; // epoch
  final int durationDays;
  final String? notes;
  final String status; // ACTIVE, COMPLETED, ABANDONED

  Treatment({
    this.id,
    required this.medicationId,
    this.frequencyHours,
    this.scheduledTime,
    required this.startDate,
    required this.durationDays,
    this.notes,
    this.status = "ACTIVE", // por defecto
  });

  Map<String, dynamic> toMap() => {
        "id": id,
        "medication_id": medicationId,
        "frequency_hours": frequencyHours,
        "scheduled_time": scheduledTime,
        "start_date": startDate,
        "duration_days": durationDays,
        "notes": notes,
        "status": status,
      };

  factory Treatment.fromMap(Map<String, dynamic> map) => Treatment(
        id: map["id"],
        medicationId: map["medication_id"],
        frequencyHours: map["frequency_hours"],
        scheduledTime: map["scheduled_time"],
        startDate: map["start_date"],
        durationDays: map["duration_days"],
        notes: map["notes"],
        status: map["status"] ?? "ACTIVE",
      );
}
