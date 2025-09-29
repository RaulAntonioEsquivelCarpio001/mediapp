import 'package:flutter/material.dart';
import '../db/crud_methods.dart';
import '../models/form.dart';
import '../models/medication.dart';

class EditarMedicamentoScreen extends StatefulWidget {
  final Medication medicamento; // recibe el medicamento a editar

  const EditarMedicamentoScreen({super.key, required this.medicamento});

  @override
  State<EditarMedicamentoScreen> createState() =>
      _EditarMedicamentoScreenState();
}

class _EditarMedicamentoScreenState extends State<EditarMedicamentoScreen> {
  final CrudMethods crud = CrudMethods();

  int? selectedFormId; // ✅ solo guardamos el id
  final TextEditingController _formController = TextEditingController();
  late TextEditingController _nameController;
  late TextEditingController _doseController;

  List<FormModel> forms = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.medicamento.name);
    _doseController = TextEditingController(text: widget.medicamento.dose);
    _loadForms();
  }

  // 🔹 Cargar formas desde BD
  Future<void> _loadForms() async {
    final list = await crud.getForms();
    setState(() {
      forms = list;

      // buscar la forma actual del medicamento
      final currentForm = list.firstWhere(
        (f) => f.id == widget.medicamento.formId,
        orElse: () => FormModel(id: -1, name: "Desconocida"),
      );

      if (currentForm.id != -1) {
        selectedFormId = currentForm.id; // ✅ guardamos id
      }
    });
  }

  // 🔹 Insertar nueva forma
  Future<void> _addForm() async {
    if (_formController.text.isEmpty) return;
    final newForm = FormModel(name: _formController.text);
    final id = await crud.insertForm(newForm);
    setState(() {
      forms.add(FormModel(id: id, name: _formController.text));
      selectedFormId = id;
    });
    _formController.clear();
  }

  // 🔹 Actualizar medicamento en BD
  Future<void> _updateMedication() async {
    if (_nameController.text.isEmpty ||
        _doseController.text.isEmpty ||
        selectedFormId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos")),
      );
      return;
    }

    final updatedMed = Medication(
      id: widget.medicamento.id, // importante
      name: _nameController.text,
      dose: _doseController.text,
      formId: selectedFormId!, // ✅ usamos id
      photoPath: widget.medicamento.photoPath,
    );

    await crud.updateMedication(updatedMed);

    Navigator.pop(context); // volver a la lista
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar Medicamento")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Dropdown de formas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Forma:", style: TextStyle(fontSize: 16)),
                DropdownButton<int?>(
                  value: selectedFormId,
                  hint: const Text("Seleccionar forma"),
                  items: forms.map((form) {
                    return DropdownMenuItem<int>(
                      value: form.id,
                      child: Text(form.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedFormId = value;
                    });
                  },
                ),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Agregar nueva forma"),
                        content: TextField(
                          controller: _formController,
                          decoration: const InputDecoration(
                              hintText: "Nombre de la forma"),
                        ),
                        actions: [
                          IconButton(
                            icon:
                                const Icon(Icons.check, color: Colors.green),
                            onPressed: () async {
                              await _addForm();
                              Navigator.pop(context);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text("Agregar forma"),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Nombre
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Nombre del medicamento",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Dosis
            TextField(
              controller: _doseController,
              decoration: const InputDecoration(
                labelText: "Dosis",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Foto
            GestureDetector(
              onTap: () {
                // TODO: Implementar cámara/galería
              },
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(widget.medicamento.photoPath == null
                      ? "📷 Tomar/Seleccionar foto del medicamento"
                      : "📷 Foto ya guardada (se puede reemplazar)"),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Botones ✔ y ✖
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.check,
                      color: Colors.green, size: 32),
                  onPressed: _updateMedication,
                ),
                const SizedBox(width: 40),
                IconButton(
                  icon: const Icon(Icons.close,
                      color: Colors.red, size: 32),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
