import 'dart:io';
import 'dart:typed_data';

/// Mobil: dosya yolundan bytes oku
Future<Uint8List> getAudioBytesFromPath(String path) async {
  final file = File(path);
  if (!await file.exists()) throw Exception('Ses dosyası bulunamadı');
  return file.readAsBytes();
}
