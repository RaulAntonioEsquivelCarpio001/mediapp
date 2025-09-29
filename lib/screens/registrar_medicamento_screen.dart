import 'package:flutter/material.dart';
import '../db/crud_methods.dart';
import '../models/form.dart';
import '../models/medication.dart';

class RegistrarMedicamentoScreen extends StatefulWidget {
  const RegistrarMedicamentoScreen({super.key});

  @override
  State<RegistrarMedicamentoScreen> createState() =>
      _RegistrarMedicamentoScreenState();
}

class _RegistrarMedicamentoScreenState
    extends State<RegistrarMedicamentoScreen> {
  final CrudMethods crud = CrudMethods();

  int? selectedFormId; // ✅ guardamos solo el id de la forma

  final TextEditingController _formController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _doseController = TextEditingController();

  List<FormModel> forms = [];

  @override
  void initState() {
    super.initState();
    _loadForms();
  }

  // 🔹 Cargar formas desde la BD
  Future<void> _loadForms() async {
    final list = await crud.getForms();
    setState(() {
      forms = list;
    });
  }

  // 🔹 Insertar una nueva forma en BD
  Future<void> _addForm() async {
    if (_formController.text.isEmpty) return;
    final newForm = FormModel(name: _formController.text);
    final id = await crud.insertForm(newForm);
    setState(() {
      forms.add(FormModel(id: id, name: _formController.text));
      selectedFormId = id; // ✅ guardamos id
    });
    _formController.clear();
  }

  // 🔹 Insertar un medicamento en BD
  Future<void> _saveMedication() async {
    if (_nameController.text.isEmpty ||
        _doseController.text.isEmpty ||
        selectedFormId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos")),
      );
      return;
    }

    final med = Medication(
      name: _nameController.text,
      dose: _doseController.text,
      formId: selectedFormId!, // ✅ usamos id de forma
    );
    await crud.insertMedication(med);

    Navigator.pop(context); // volver a la lista de medicamentos
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registrar Medicamento")),
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

            // Campo Nombre
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Nombre del medicamento",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Campo Dosis
            TextField(
              controller: _doseController,
              decoration: const InputDecoration(
                labelText: "Dosis (ej. 500mg)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Contenedor para foto (a implementar después)
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
                child: const Center(
                  child: Text("📷 Tomar/Seleccionar foto del medicamento"),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Botones aceptar/cancelar
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.check,
                      color: Colors.green, size: 32),
                  onPressed: _saveMedication,
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
