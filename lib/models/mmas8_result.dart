// lib/models/mmas8_result.dart

class MMAS8Result {
  int? id;
  double score;
  String adherenceLevel;
  int dateTaken; // epoch (milisegundos)
  String? notes;

  MMAS8Result({
    this.id,
    required this.score,
    required this.adherenceLevel,
    required this.dateTaken,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'score': score,
      'adherence_level': adherenceLevel,
      'date_taken': dateTaken,
      'notes': notes,
    };
  }

  factory MMAS8Result.fromMap(Map<String, dynamic> map) {
    return MMAS8Result(
      id: map['id'],
      score: map['score'],
      adherenceLevel: map['adherence_level'],
      dateTaken: map['date_taken'],
      notes: map['notes'],
    );
  }
}
