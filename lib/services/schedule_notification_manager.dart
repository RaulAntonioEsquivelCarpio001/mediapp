// lib/services/schedule_notification_manager.dart
import '../db/crud_methods.dart';
import 'notification_service.dart';
import '../models/schedule.dart';

class ScheduleNotificationManager {
  final CrudMethods _crud = CrudMethods();
  final NotificationService _notifs = NotificationService();

  Future<void> scheduleNotificationsForTreatment(int treatmentId) async {
    final schedules = await _crud.getSchedulesByTreatment(treatmentId);

    for (final Schedule s in schedules) {
      if (s.id == null) continue;

      final scheduledDt =
          DateTime.fromMillisecondsSinceEpoch(s.scheduledTimestamp);

      // Notificar 5 min antes. Si ya pasó, disparar ahora + 1s
      DateTime notifyAt = scheduledDt.subtract(const Duration(minutes: 5));
      if (notifyAt.isBefore(DateTime.now())) {
        notifyAt = DateTime.now().add(const Duration(seconds: 1));
      }

      final medBrief = await _crud.getMedicationBriefByTreatment(treatmentId);

      final payload = {
        "schedule_id": s.id,
        "treatment_id": s.treatmentId,
        "scheduled_timestamp": s.scheduledTimestamp,
        "med_name": medBrief,
      };

      await _notifs.scheduleFullscreenPersistentNotification(
        id: s.id!,
        scheduledDate: notifyAt,
        title: "Hora de tu medicamento",
        body: "$medBrief — ${_formatTime(scheduledDt)}",
        payload: payload,
      );
    }
  }

  Future<void> cancelNotificationsForTreatment(int treatmentId) async {
    final schedules = await _crud.getSchedulesByTreatment(treatmentId);
    for (final s in schedules) {
      if (s.id != null) await _notifs.cancelNotification(s.id!);
    }
  }

  Future<void> scheduleAllPendingNotifications() async {
    final treatments = await _crud.getTreatments();
    for (final t in treatments) {
      if (t.id != null) await scheduleNotificationsForTreatment(t.id!);
    }
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }
}
