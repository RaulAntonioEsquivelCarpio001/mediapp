import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../db/crud_methods.dart';
import '../models/medication.dart';
import 'registrar_medicamento_screen.dart';
import 'editar_medicamento_screen.dart';

class MedicamentosScreen extends StatefulWidget {
  const MedicamentosScreen({super.key});

  @override
  State<MedicamentosScreen> createState() => _MedicamentosScreenState();
}

class _MedicamentosScreenState extends State<MedicamentosScreen> {
  final CrudMethods crud = CrudMethods();
  List<Medication> medicamentos = [];
  List<Medication> medicamentosFiltrados = [];

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    final list = await crud.getMedicationsWithFormName();
    setState(() {
      medicamentos = list;
      medicamentosFiltrados = list;
    });
  }

  void _filtrarMedicamentos(String query) {
    setState(() {
      medicamentosFiltrados = medicamentos
          .where((m) => m.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              color: Colors.grey[300],
              margin: const EdgeInsets.only(right: 8),
              child: const Icon(Icons.medication, color: Colors.blue),
            ),
            const Text("Medicamentos"),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text("Menú",
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Inicio"),
              onTap: () {
                Navigator.pushReplacementNamed(context, "/");
              },
            ),
            ListTile(
              leading: const Icon(Icons.medication),
              title: const Text("Medicamentos"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text("Tratamientos"),
              onTap: () {
                Navigator.pushReplacementNamed(context, "/tratamientos");
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Buscar
            Row(
              children: [
                const Text("Buscar: ", style: TextStyle(fontSize: 16)),
                Expanded(
                  child: TextField(
                    onChanged: _filtrarMedicamentos,
                    decoration: InputDecoration(
                      hintText: "Nombre del medicamento",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tabla de medicamentos
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text("Nombre")),
                    DataColumn(label: Text("Dosis")),
                    DataColumn(label: Text("Forma")),
                    DataColumn(label: Text("Imagen")),
                    DataColumn(label: Text("Acciones")),
                  ],
                  rows: medicamentosFiltrados.map((med) {
                    return DataRow(
                      cells: [
                        DataCell(Text(med.name)),
                        DataCell(Text(med.dose)),
                        DataCell(Text(med.formName ?? "Desconocida")),
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.image),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text(med.name),
                                  content: med.photoPath != null &&
                                          med.photoPath!.isNotEmpty
                                      ? (kIsWeb
                                          ? Container(
                                              height: 200,
                                              color: Colors.grey[200],
                                              child: const Center(
                                                  child: Text(
                                                      "Imagen local no disponible en web")),
                                            )
                                          : Image.file(
                                              File(med.photoPath!),
                                              height: 200,
                                              fit: BoxFit.contain,
                                            ))
                                      : Container(
                                          height: 200,
                                          color: Colors.grey[200],
                                          child: const Center(
                                              child: Text("Sin imagen")),
                                        ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context),
                                      child: const Text("Cerrar"),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          EditarMedicamentoScreen(
                                              medicamento: med),
                                    ),
                                  ).then((_) => _loadMedications());
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title:
                                          const Text("Confirmar eliminación"),
                                      content: Text(
                                        "¿Seguro que deseas eliminar '${med.name}'?\n\n"
                                        "👉 Si el medicamento está en un tratamiento activo, solo se desactivará.",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: const Text("Cancelar"),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            // primero cerrar el diálogo
                                            Navigator.of(context).pop();

                                            try {
                                              final result =
                                                  await crud.deleteMedicationSafe(
                                                      med.id!);

                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        "✅ Medicamento eliminado correctamente")),
                                              );

                                              _loadMedications();
                                            } catch (e) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        "Error al eliminar: $e")),
                                              );
                                            }
                                          },
                                          child: const Text("Eliminar",
                                              style: TextStyle(
                                                  color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const RegistrarMedicamentoScreen()),
          );
          _loadMedications();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
