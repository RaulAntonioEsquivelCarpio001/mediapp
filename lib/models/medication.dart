class Medication {
  final int? id;
  final String name;
  final String dose;
  final int formId;
  final String? photoPath;

  Medication({this.id, required this.name, required this.dose, required this.formId, this.photoPath});

  Map<String, dynamic> toMap() => {
    "id": id,
    "name": name,
    "dose": dose,
    "form_id": formId,
    "photo_path": photoPath,
  };

  factory Medication.fromMap(Map<String, dynamic> map) => Medication(
    id: map["id"],
    name: map["name"],
    dose: map["dose"],
    formId: map["form_id"],
    photoPath: map["photo_path"],
  );
}
