class Schedule {
  final int? id;
  final int treatmentId;
  final int scheduledTimestamp;
  final String status;

  Schedule({this.id, required this.treatmentId, required this.scheduledTimestamp, this.status = "PENDING"});

  Map<String, dynamic> toMap() => {
    "id": id,
    "treatment_id": treatmentId,
    "scheduled_timestamp": scheduledTimestamp,
    "status": status,
  };

  factory Schedule.fromMap(Map<String, dynamic> map) => Schedule(
    id: map["id"],
    treatmentId: map["treatment_id"],
    scheduledTimestamp: map["scheduled_timestamp"],
    status: map["status"],
  );
}
