class Medication {
  final int? id;
  final String name;
  final String dose;
  final int formId;
  final String? photoPath;
  final int isActive;
  final String? formName; // 🔹 nombre de la forma (JOIN con forms)

  Medication({
    this.id,
    required this.name,
    required this.dose,
    required this.formId,
    this.photoPath,
    this.isActive = 1,
    this.formName,
  });

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "dose": dose,
        "form_id": formId,
        "photo_path": photoPath,
        "is_active": isActive,
      };

  factory Medication.fromMap(Map<String, dynamic> map) => Medication(
        id: map["id"],
        name: map["name"],
        dose: map["dose"],
        formId: map["form_id"],
        photoPath: map["photo_path"],
        isActive: map["is_active"] ?? 1,
        formName: map["form_name"], // ✅ vendrá si hacemos JOIN
      );
}
