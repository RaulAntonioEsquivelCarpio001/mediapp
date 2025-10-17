import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/medicamentos_screen.dart';
import 'screens/registrar_medicamento_screen.dart';
import 'screens/editar_medicamento_screen.dart';
import 'screens/tratamientos/tratamientos_screen.dart';
import 'screens/tratamientos/registrar_tratamiento_screen.dart';
import 'screens/tratamientos/editar_tratamiento_screen.dart';

void main() {
  runApp(const MediApp());
}

class MediApp extends StatelessWidget {
  const MediApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "MediApp",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: "/",
      routes: {
        "/": (context) => const HomeScreen(),
        "/medicamentos": (context) => const MedicamentosScreen(),
        "/registrarMedicamento": (context) => const RegistrarMedicamentoScreen(),
        "/tratamientos": (context) => const TratamientosScreen(),
        "/registrarTratamiento": (context) => const RegistrarTratamientoScreen(),
      },
      // Rutas dinámicas (para editar registros)
      onGenerateRoute: (settings) {
        if (settings.name == "/editarMedicamento") {
          final args = settings.arguments;
          if (args != null && args is Map<String, dynamic>) {
            return MaterialPageRoute(
              builder: (_) => EditarMedicamentoScreen(medicamento: args["medicamento"]),
            );
          }
        } else if (settings.name == "/editarTratamiento") {
          final args = settings.arguments;
          if (args != null && args is Map<String, dynamic>) {
            return MaterialPageRoute(
              builder: (_) => EditarTratamientoScreen(tratamiento: args["tratamiento"]),
            );
          }
        }
        return null;
      },
    );
  }
}

