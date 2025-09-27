class FormModel {
  final int? id;
  final String name;

  FormModel({this.id, required this.name});

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
      };

  factory FormModel.fromMap(Map<String, dynamic> map) {
    return FormModel(
      id: map["id"],
      name: map["name"],
    );
  }
}
