import 'package:flutter/material.dart';
import '../../db/crud_methods.dart';
import 'registrar_tratamiento_screen.dart';
import '../../widgets/app_drawer.dart';        // <-- IMPORTANTE
import 'editar_tratamiento_screen.dart';

class TratamientosScreen extends StatefulWidget {
  const TratamientosScreen({super.key});

  @override
  State<TratamientosScreen> createState() => _TratamientosScreenState();
}

class _TratamientosScreenState extends State<TratamientosScreen> {
  final CrudMethods crud = CrudMethods();
  List<Map<String, dynamic>> tratamientos = [];
  List<Map<String, dynamic>> tratamientosFiltrados = [];

  @override
  void initState() {
    super.initState();
    _loadTreatments();
  }

  Future<void> _loadTreatments() async {
    final list = await crud.getTreatmentsWithMedicationName();
    setState(() {
      tratamientos = list;
      tratamientosFiltrados = list;
    });
  }

  void _filtrarTratamientos(String query) {
    setState(() {
      tratamientosFiltrados = tratamientos
          .where((t) => (t['medication_name'] ?? '')
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tratamientos"),
      ),

      // ⭐⭐ AQUÍ USAMOS EL MISMO DRAWER PARA TODA LA APP ⭐⭐
      drawer: const AppDrawer(),

      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Campo de búsqueda
            Row(
              children: [
                const Text("Buscar: ", style: TextStyle(fontSize: 16)),
                Expanded(
                  child: TextField(
                    onChanged: _filtrarTratamientos,
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

            // Tabla de tratamientos
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columnSpacing: 10,
                  columns: const [
                    DataColumn(label: Text("Medicamento")),
                    DataColumn(label: Text("Frecuencia")),
                    DataColumn(label: Text("Hora")),
                    DataColumn(label: Text("Inicio")),
                    DataColumn(label: Text("Duración")),
                    DataColumn(label: Text("Estado")),
                    DataColumn(label: Text("Acciones")),
                  ],
                  rows: tratamientosFiltrados.map((t) {
                    return DataRow(
                      cells: [
                        DataCell(Text(t["medication_name"] ?? "Desconocido")),
                        DataCell(Text("${t["frequency_hours"] ?? '-'} h")),
                        DataCell(Text(t["scheduled_time"] ?? "-")),
                        DataCell(Text(
                          DateTime.fromMillisecondsSinceEpoch(t["start_date"])
                              .toLocal()
                              .toString()
                              .split(' ')[0],
                        )),
                        DataCell(Text("${t["duration_days"] ?? '-'} días")),
                        DataCell(Text(t["status"] ?? "ACTIVE")),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                tooltip: "Editar tratamiento",
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          EditarTratamientoScreen(tratamiento: t),
                                    ),
                                  );
                                  _loadTreatments();
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                tooltip: "Eliminar tratamiento",
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Función de eliminación pendiente."),
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
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const RegistrarTratamientoScreen(),
            ),
          );
          _loadTreatments();
        },
      ),
    );
  }
}
