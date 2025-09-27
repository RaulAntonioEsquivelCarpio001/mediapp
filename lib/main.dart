import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/medicamentos_screen.dart';
import 'screens/registrar_medicamento_screen.dart';

void main() {
  runApp(const MediApp());
}

class MediApp extends StatelessWidget {
  const MediApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "MediApp",
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: "/",
      routes: {
        "/": (context) => const HomeScreen(),
        "/medicamentos": (context) => const MedicamentosScreen(),
        "/registrarMedicamento": (context) => const RegistrarMedicamentoScreen(),
        // "/tratamientos": (context) => const TratamientosScreen(),  // por crear
      },
    );
  }
}
