class DoseLog {
  final int? id;
  final int scheduleId;
  final int? actualTimestamp;
  final String status;
  final String? photoPath;

  DoseLog({this.id, required this.scheduleId, this.actualTimestamp, required this.status, this.photoPath});

  Map<String, dynamic> toMap() => {
    "id": id,
    "schedule_id": scheduleId,
    "actual_timestamp": actualTimestamp,
    "status": status,
    "photo_path": photoPath,
  };

  factory DoseLog.fromMap(Map<String, dynamic> map) => DoseLog(
    id: map["id"],
    scheduleId: map["schedule_id"],
    actualTimestamp: map["actual_timestamp"],
    status: map["status"],
    photoPath: map["photo_path"],
  );
}
