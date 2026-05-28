import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

/// Mikrofon izni — iOS App Review için net diyalog + Ayarlar kısayolu.
class MicrophonePermissionService {
  MicrophonePermissionService._();

  static final AudioRecorder _probe = AudioRecorder();

  static Future<bool> ensureGranted(BuildContext context) async {
    if (await _probe.hasPermission()) return true;

    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }

    if (status.isGranted || await _probe.hasPermission()) {
      return true;
    }

    if (!context.mounted) return false;

    if (status.isPermanentlyDenied || status.isRestricted) {
      await _showSettingsDialog(context);
      return false;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Konuşma kaydı için mikrofon izni gerekli. İzin verip tekrar deneyin.',
        ),
        duration: Duration(seconds: 4),
      ),
    );
    return false;
  }

  static Future<void> _showSettingsDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mikrofon izni kapalı'),
        content: const Text(
          'Sınav ve pratik bölümlerinde cevabınızı kaydetmek için mikrofon gerekir.\n\n'
          'Ayarlar → DLA+ → Mikrofon seçeneğini açın, ardından uygulamaya dönün.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await openAppSettings();
            },
            child: const Text('Ayarları aç'),
          ),
        ],
      ),
    );
  }
}
