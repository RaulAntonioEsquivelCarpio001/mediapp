import 'package:flutter/material.dart';
import '../db/crud_methods.dart';
import 'package:intl/intl.dart';
import '../widgets/app_drawer.dart';   // <-- IMPORTANTE

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CrudMethods crud = CrudMethods();
  List<Map<String, dynamic>> dosesToday = [];

  @override
  void initState() {
    super.initState();
    _loadTodayDoses();
  }

  Future<void> _loadTodayDoses() async {
    final list = await crud.getScheduleForToday();
    setState(() {
      dosesToday = list;
    });
  }

  String _formatTimeFromEpoch(int epoch) {
    final dt = DateTime.fromMillisecondsSinceEpoch(epoch);
    return DateFormat("hh:mm a").format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("MediApp")),

      // ⭐ USAR EL MISMO DRAWER PARA TODA LA APP ⭐
      drawer: const AppDrawer(),

      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // =======================
            // HORARIO DEL DÍA
            // =======================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "📅 Horario del día",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  if (dosesToday.isEmpty)
                    const Text(
                      "No hay tomas programadas para hoy.",
                      style: TextStyle(color: Colors.grey),
                    )
                  else
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 250, // ⬅ límite visual del área (ajústalo si quieres)
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: dosesToday.map((d) {
                            final formatted = _formatTimeFromEpoch(
                              d["scheduled_timestamp"] as int,
                            );

                            return Card(
                              child: ListTile(
                                leading: const Icon(Icons.alarm),
                                title: Text(
                                  "$formatted – ${d["med_name"]}",
                                ),
                                subtitle: Text(d["med_dose"] ?? ""),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // =======================
            // DASHBOARD DE ADHERENCIA
            // =======================
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                    )
                  ],
                ),
                child: const Center(
                  child: Text(
                    "📊 Dashboard de Adherencia\n(Próximamente)",
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
