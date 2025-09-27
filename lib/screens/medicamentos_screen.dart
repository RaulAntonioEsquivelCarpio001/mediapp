import 'dart:io'; // para mostrar imágenes guardadas en File
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
    _loadMedicamentos();
  }

  // 🔹 Cargar medicamentos desde la BD
  Future<void> _loadMedicamentos() async {
    final list = await crud.getMedications();
    setState(() {
      medicamentos = list;
      medicamentosFiltrados = list;
    });
  }

  // 🔹 Filtrar por nombre
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
              child: Text("Menú", style: TextStyle(color: Colors.white, fontSize: 24)),
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tabla dinámica de medicamentos
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text("Nombre")),
                    DataColumn(label: Text("Dosis")),
                    DataColumn(label: Text("Forma ID")), // por ahora solo ID
                    DataColumn(label: Text("Imagen")),
                    DataColumn(label: Text("")), // columna vacía para botón editar
                  ],
                  rows: medicamentosFiltrados.map((med) {
                    return DataRow(
                      cells: [
                        DataCell(Text(med.name)),
                        DataCell(Text(med.dose)),
                        DataCell(Text(med.formId.toString())), // TODO: join con tabla Form
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.image),
                            onPressed: () {
                              if (med.photoPath != null) {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: Text(med.name),
                                    content: Image.file(
                                      File(med.photoPath!),
                                      fit: BoxFit.cover,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("Cerrar"),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditarMedicamentoScreen(
                                    medicamento: med, // ✅ aquí mandamos el objeto
                                  ),
                                ),
                              ).then((_) => _loadMedicamentos()); // refrescar al volver
                            },
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RegistrarMedicamentoScreen()),
          ).then((_) => _loadMedicamentos()); // refrescar al volver
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
