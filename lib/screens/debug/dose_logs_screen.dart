import 'package:flutter/material.dart';
import '../../db/crud_methods.dart';
import 'package:intl/intl.dart';

class DoseLogsScreen extends StatefulWidget {
  const DoseLogsScreen({super.key});

  @override
  State<DoseLogsScreen> createState() => _DoseLogsScreenState();
}

class _DoseLogsScreenState extends State<DoseLogsScreen> {
  final CrudMethods crud = CrudMethods();
  List<Map<String, dynamic>> logs = [];

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final data = await crud.getAllDoseLogsWithInfo();
    setState(() {
      logs = data;
    });
  }

  String _format(int? epoch) {
    if (epoch == null) return "-";
    final dt = DateTime.fromMillisecondsSinceEpoch(epoch);
    return DateFormat("dd/MM HH:mm:ss").format(dt);
  }

  Color _statusColor(String status) {
    switch (status) {
      case "TAKEN":
        return Colors.green;
      case "MISSED":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🧪 Debug - Dose Logs"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLogs,
          )
        ],
      ),
      body: logs.isEmpty
          ? const Center(child: Text("No hay registros"))
          : ListView.builder(
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final l = logs[index];

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: Icon(
                      Icons.medication,
                      color: _statusColor(l["status"]),
                    ),
                    title: Text(
                      "${l["med_name"] ?? "Medicamento"} (${l["status"]})",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _statusColor(l["status"]),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("🕒 Programado: ${_format(l["scheduled_timestamp"])}"),
                        Text("✅ Real: ${_format(l["actual_timestamp"])}"),
                        Text("🆔 Schedule ID: ${l["schedule_id"]}"),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}