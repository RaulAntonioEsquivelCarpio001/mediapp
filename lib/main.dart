// lib/main.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/medicamentos_screen.dart';
import 'screens/registrar_medicamento_screen.dart';
import 'screens/editar_medicamento_screen.dart';
import 'screens/tratamientos/tratamientos_screen.dart';
import 'screens/tratamientos/registrar_tratamiento_screen.dart';
import 'screens/tratamientos/editar_tratamiento_screen.dart';
import 'screens/mmas8_screen.dart';
import 'services/notification_service.dart';
import 'db/crud_methods.dart';
import 'services/schedule_notification_manager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'screens/debug/dose_logs_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar sistema de notificaciones
  final notifService = NotificationService();
  await notifService.init(onAction: (payloadStr, actionId) async {
  try {
    Map<String, dynamic> payload = {};
    if (payloadStr.isNotEmpty) {
      payload = jsonDecode(payloadStr) as Map<String, dynamic>;
    }

    final scheduleId = payload["schedule_id"] is int
        ? payload["schedule_id"] as int
        : int.tryParse(payload["schedule_id"]?.toString() ?? "");

    if (scheduleId == null) {
      print("❌ schedule_id inválido");
      return;
    }

    final crud = CrudMethods();
    final aid = actionId.toUpperCase();
    final notifService = NotificationService();

    if (aid == 'TAKE') {
      print("💊 Medicamento tomado");
      await crud.registerDoseTaken(scheduleId: scheduleId);
      await notifService.cancelNotification(scheduleId);

    } else if (aid == 'SKIP') {
      print("❌ Medicamento omitido");
      await crud.registerDoseMissed(scheduleId: scheduleId);
      await notifService.cancelNotification(scheduleId);

    } else if (aid == 'EVIDENCE') {
      print("📸 Evidencia solicitada (pendiente implementación)");

    } else {
      print("👆 Tap normal en notificación");
    }
  } catch (e, st) {
    print("🔥 Error en onAction: $e\n$st");
  }
});


  // 🔥 Permiso obligatorio para Android 13+
  final plugin = FlutterLocalNotificationsPlugin();
  await plugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();

  // Programar notificaciones pendientes
  final manager = ScheduleNotificationManager();
  await manager.scheduleAllPendingNotifications();

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
        "/mmas8": (context) => const MMAS8Screen(),
        "/debugLogs": (context) => const DoseLogsScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == "/editarMedicamento") {
          final args = settings.arguments;
          if (args != null && args is Map<String, dynamic>) {
            return MaterialPageRoute(
              builder: (_) =>
                  EditarMedicamentoScreen(medicamento: args["medicamento"]),
            );
          }
        } else if (settings.name == "/editarTratamiento") {
          final args = settings.arguments;
          if (args != null && args is Map<String, dynamic>) {
            return MaterialPageRoute(
              builder: (_) =>
                  EditarTratamientoScreen(tratamiento: args["tratamiento"]),
            );
          }
        }
        return null;
      },
    );
  }
}
