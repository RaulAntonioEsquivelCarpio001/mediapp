import 'package:flutter/material.dart';
import '../../db/crud_methods.dart';
import '../../models/treatment.dart';
import '../../models/medication.dart';

class RegistrarTratamientoScreen extends StatefulWidget {
  const RegistrarTratamientoScreen({super.key});

  @override
  State<RegistrarTratamientoScreen> createState() =>
      _RegistrarTratamientoScreenState();
}

class _RegistrarTratamientoScreenState
    extends State<RegistrarTratamientoScreen> {
  final CrudMethods crud = CrudMethods();

  List<Medication> medicamentos = [];
  Medication? selectedMedication;

  final TextEditingController _frequencyController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  TimeOfDay? _selectedTime;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    final list = await crud.getMedications();
    setState(() {
      medicamentos = list;
    });
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) setState(() => _selectedTime = time);
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024, 1),
      lastDate: DateTime(2100),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _saveTreatment() async {
    if (selectedMedication == null ||
        _frequencyController.text.isEmpty ||
        _durationController.text.isEmpty ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos.")),
      );
      return;
    }

    final treatment = Treatment(
      medicationId: selectedMedication!.id!,
      frequencyHours: int.tryParse(_frequencyController.text),
      scheduledTime: _selectedTime!.format(context),
      startDate: _selectedDate!.millisecondsSinceEpoch,
      durationDays: int.tryParse(_durationController.text)!,
      notes: _notesController.text,
      status: "ACTIVE",
    );

    await crud.insertTreatment(treatment);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registrar Tratamiento")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            DropdownButtonFormField<Medication>(
              value: selectedMedication,
              hint: const Text("Seleccionar medicamento"),
              items: medicamentos.map((m) {
                return DropdownMenuItem(
                  value: m,
                  child: Text(m.name),
                );
              }).toList(),
              onChanged: (val) => setState(() => selectedMedication = val),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _frequencyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Frecuencia (en horas)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                      "Hora: ${_selectedTime?.format(context) ?? 'No seleccionada'}"),
                ),
                ElevatedButton(
                  onPressed: _pickTime,
                  child: const Text("Elegir hora"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                      "Inicio: ${_selectedDate != null ? _selectedDate!.toLocal().toString().split(' ')[0] : 'No seleccionada'}"),
                ),
                ElevatedButton(
                  onPressed: _pickDate,
                  child: const Text("Elegir fecha"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Duración (días)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: "Notas (opcional)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green, size: 32),
                  onPressed: _saveTreatment,
                ),
                const SizedBox(width: 40),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red, size: 32),
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
