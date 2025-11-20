import 'package:flutter/material.dart';
import '../../db/crud_methods.dart';
import '../../models/treatment.dart';
import '../../models/medication.dart';

class EditarTratamientoScreen extends StatefulWidget {
  final Map<String, dynamic> tratamiento;
  const EditarTratamientoScreen({super.key, required this.tratamiento});

  @override
  State<EditarTratamientoScreen> createState() =>
      _EditarTratamientoScreenState();
}

class _EditarTratamientoScreenState extends State<EditarTratamientoScreen> {
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
    _loadData();
  }

  void _loadData() {
    _frequencyController.text =
        widget.tratamiento["frequency_hours"]?.toString() ?? "";
    _durationController.text =
        widget.tratamiento["duration_days"]?.toString() ?? "";
    _notesController.text = widget.tratamiento["notes"] ?? "";
    _selectedTime =
        _parseTimeOfDay(widget.tratamiento["scheduled_time"] ?? "08:00");
    _selectedDate = DateTime.fromMillisecondsSinceEpoch(
        widget.tratamiento["start_date"] ?? DateTime.now().millisecondsSinceEpoch);
  }

  TimeOfDay _parseTimeOfDay(String timeStr) {
  try {
    // Verificar si el formato tiene AM/PM
    final isAmPm = timeStr.toUpperCase().contains('AM') || timeStr.toUpperCase().contains('PM');

    if (isAmPm) {
      // Parsear formato 12h (ejemplo: "10:30 PM")
      final cleaned = timeStr.toUpperCase().replaceAll('AM', '').replaceAll('PM', '').trim();
      final parts = cleaned.split(':');
      int hour = int.tryParse(parts[0]) ?? 0;
      int minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;

      // Convertir a 24h
      if (timeStr.toUpperCase().contains('PM') && hour != 12) hour += 12;
      if (timeStr.toUpperCase().contains('AM') && hour == 12) hour = 0;

      return TimeOfDay(hour: hour, minute: minute);
    } else {
      // Parsear formato 24h (ejemplo: "14:30")
      final parts = timeStr.split(':');
      return TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 0,
        minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
      );
    }
  } catch (e) {
    // Valor por defecto si algo falla
    return const TimeOfDay(hour: 8, minute: 0);
  }
}


  Future<void> _loadMedications() async {
    final list = await crud.getMedications();
    setState(() {
      medicamentos = list;
      selectedMedication = list.firstWhere(
          (m) => m.id == widget.tratamiento["medication_id"],
          orElse: () => list.first);
    });
  }

    Future<void> _updateTreatment() async {
    if (selectedMedication == null ||
        _frequencyController.text.isEmpty ||
        _durationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos.")),
      );
      return;
    }

    final updated = Treatment(
      id: widget.tratamiento["id"],
      medicationId: selectedMedication!.id!,
      frequencyHours: int.tryParse(_frequencyController.text),
      scheduledTime: _selectedTime!.format(context),
      startDate: _selectedDate!.millisecondsSinceEpoch,
      durationDays: int.tryParse(_durationController.text)!,
      notes: _notesController.text,
      status: widget.tratamiento["status"],
    );

    // 1) Actualizar tratamiento
    await crud.updateTreatment(updated);

    // 2) Borrar schedule viejo y regenerar el nuevo basado en los datos actualizados
    try {
      if (updated.id != null) {
        await crud.deleteSchedulesByTreatment(updated.id!);
        await crud.generateScheduleForTreatment(
          treatmentId: updated.id!,
          startDateEpoch: updated.startDate,
          scheduledTime: updated.scheduledTime ?? "08:00",
          frequencyHours: updated.frequencyHours ?? 24,
          durationDays: updated.durationDays,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Tratamiento actualizado, pero error regenerando schedule: $e")),
      );
    }

    Navigator.pop(context);
  }


  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (time != null) setState(() => _selectedTime = time);
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2024, 1),
      lastDate: DateTime(2100),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar Tratamiento")),
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
                        "Hora: ${_selectedTime?.format(context) ?? 'No seleccionada'}")),
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
                        "Inicio: ${_selectedDate != null ? _selectedDate!.toLocal().toString().split(' ')[0] : 'No seleccionada'}")),
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
                  onPressed: _updateTreatment,
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
