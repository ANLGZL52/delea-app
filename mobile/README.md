# DLA+ (Flutter)

Kabin mülakatı / DLA İngilizce konuşma pratiği uygulaması.

## Firebase, web yayını ve alan adı

Prod Firebase projesi, Hosting ve özel domain adımları: **[../docs/FIREBASE_VE_ALAN_ADI.md](../docs/FIREBASE_VE_ALAN_ADI.md)**

Hızlı başlat (kendi Firebase projeni bağlamak):

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

## API adresi (geliştirme / cihaz)

`lib/services/api_service.dart` ve `--dart-define=API_BASE_URL=...` (detay aynı dokümantasyonda).

## Google Play: release imzası (AAB)

1. `android` klasöründe: `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass` ardından `.\create_play_upload_keystore.ps1` (sifre sorar; `delea-upload-key.jks` + `key.properties` olusur; ikisini de git'e ekleme).
2. Ustte `mobile`: `flutter build appbundle --release`
3. Cikis: `build/app/outputs/bundle/release/app-release.aab` — yukleme sifren; `.jks` yedegi sart.
