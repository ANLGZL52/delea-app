// Web-only: `package:http` blob: URL'lerde güvenilmez. Geçici olarak dart:html XHR; JS interop
// sürümlerinde stabilleşince package:web fetch'e geçilebilir.
// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;
import 'dart:typed_data';

/// Web: `package:http` tarayıcıda `blob:` URL'lerini bazen boş/eksik verir; gerçek baytlar için XHR/ArrayBuffer kullan.
Future<Uint8List> getAudioBytesFromPath(String path) async {
  final r = await html.HttpRequest.request(
    path,
    method: 'GET',
    responseType: 'arraybuffer',
  );
  if (r.status != 200) {
    throw Exception('Ses verisi alınamadı (HTTP ${r.status})');
  }
  final buf = r.response;
  if (buf is! ByteBuffer) {
    throw Exception('Ses yanıtı geçersiz (blob okunamadı)');
  }
  return Uint8List.view(buf);
}
