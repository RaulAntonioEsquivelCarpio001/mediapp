import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              "Menú",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),

          // ======================
          // PRINCIPAL
          // ======================
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
              Navigator.pushReplacementNamed(context, "/medicamentos");
            },
          ),
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text("Tratamientos"),
            onTap: () {
              Navigator.pushReplacementNamed(context, "/tratamientos");
            },
          ),
          ListTile(
            leading: const Icon(Icons.fact_check),
            title: const Text("Cuestionario MMAS-8"),
            onTap: () {
              Navigator.pushReplacementNamed(context, "/mmas8");
            },
          ),

          const Divider(),

          // ======================
          // 🧪 DEBUG (TEMPORAL)
          // ======================
          ListTile(
            leading: const Icon(Icons.bug_report, color: Colors.red),
            title: const Text(
              "Debug: Dose Logs",
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.pushNamed(context, "/debugLogs");
            },
          ),
        ],
      ),
    );
  }
}