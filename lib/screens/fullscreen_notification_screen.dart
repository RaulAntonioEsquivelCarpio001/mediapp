// lib/screens/fullscreen_notification_screen.dart
import 'package:flutter/material.dart';
import '../db/crud_methods.dart';

class FullscreenNotificationScreen extends StatefulWidget {
  final Map<String, dynamic> payload;
  final int notificationId;

  const FullscreenNotificationScreen({
    super.key,
    required this.payload,
    required this.notificationId,
  });

  @override
  State<FullscreenNotificationScreen> createState() =>
      _FullscreenNotificationScreenState();
}

class _FullscreenNotificationScreenState
    extends State<FullscreenNotificationScreen> {
  final CrudMethods crud = CrudMethods();
  bool _processing = false;

  String _formatEpoch(int epoch) {
    final dt = DateTime.fromMillisecondsSinceEpoch(epoch);
    return "${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}";
  }

  Future<void> _registerTaken() async {
    setState(() => _processing = true);
    try {
      final scheduleId = widget.payload['schedule_id'] as int?;
      if (scheduleId != null) {
        await crud.registerDoseTaken(scheduleId: scheduleId);
      }
      // cancelar notificación desde la app
      // NotificationService.cancelNotification viene desde notification_service
      // para evitar dependencia circular, usaremos Navigator pop y el caller en main cancelará la notif si es necesario.
    } catch (e) {
      // manejar error (log, snackbar)
    } finally {
      setState(() => _processing = false);
      Navigator.of(context).pop(true); // return true = action taken
    }
  }

  Future<void> _cancelNotificationOnly() async {
    Navigator.of(context).pop(false); // user canceled, caller can cancel notification
  }

  @override
  Widget build(BuildContext context) {
    final medName = widget.payload['med_name'] ?? 'Medicamento';
    final scheduledTs = widget.payload['scheduled_timestamp'] as int?;
    final scheduledStr =
        scheduledTs != null ? _formatEpoch(scheduledTs) : 'Hora';

    return WillPopScope(
      onWillPop: () async => false, // evitar salir con back
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Recordatorio: tomar medicación'),
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Text(
                medName,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text("Hora prevista: $scheduledStr", style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 18),
              // Nota de tratamiento si viene en payload
              if (widget.payload['note'] != null)
                Text(widget.payload['note'].toString(),
                    textAlign: TextAlign.center),
              const Spacer(),
              if (_processing) const CircularProgressIndicator(),
              if (!_processing)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _registerTaken,
                      icon: const Icon(Icons.check),
                      label: const Text("Registrar toma"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _cancelNotificationOnly,
                      icon: const Icon(Icons.close),
                      label: const Text("Cancelar"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
