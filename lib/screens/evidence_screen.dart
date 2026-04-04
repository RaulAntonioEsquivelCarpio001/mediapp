import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../db/crud_methods.dart';
import '../services/notification_service.dart';

class EvidenceScreen extends StatefulWidget {
  final int scheduleId;

  const EvidenceScreen({super.key, required this.scheduleId});

  @override
  State<EvidenceScreen> createState() => _EvidenceScreenState();
}

class _EvidenceScreenState extends State<EvidenceScreen> {
  File? _photo;
  final ImagePicker _picker = ImagePicker();
  bool _loading = false;

  Future<void> _takePhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        _photo = File(picked.path);
      });
    }
  }

  Future<void> _confirm() async {
    if (_photo == null) return;

    setState(() => _loading = true);

    final crud = CrudMethods();
    final notifService = NotificationService();

    await crud.registerDoseTaken(
      scheduleId: widget.scheduleId,
      photoPath: _photo!.path,
    );

    await notifService.cancelNotification(widget.scheduleId);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 420,
        child: Column(
          children: [
            const Text(
              "Confirmar toma",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _photo == null
                      ? const Center(
                          child: Text("📷 Toma una foto del medicamento"),
                        )
                      : Image.file(_photo!, fit: BoxFit.cover),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _takePhoto,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Foto"),
                ),

                ElevatedButton.icon(
                  onPressed: _photo != null && !_loading ? _confirm : null,
                  icon: _loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check),
                  label: const Text("Confirmar"),
                ),
              ],
            ),

            const SizedBox(height: 8),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            )
          ],
        ),
      ),
    );
  }
}