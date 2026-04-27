# Firebase ve alan adı (DLA+)

Uygulamanın **tüm platformlarda** aynı çekirdekle çalışması, **web’i özel alan** üzerinden yayınlamak ve ileride Analytics / Remote Config gibi hizmetlere açılmak için Firebase temel iskeleti eklendi.

## Repoda neler var?

| Bileşen | Açıklama |
|--------|----------|
| `mobile/lib/firebase_options.dart` | Firebase uygulama anahtarları. Şu an **FlutterFire e2e** örnek proje; **kendi projeni** `flutterfire configure` ile üret. |
| `mobile/lib/core/firebase_bootstrap.dart` | Uygulama açılırken `Firebase.initializeApp(...)`. |
| `mobile/lib/main.dart` | `configureFirebase()` çağrısı. |
| `firebase.json` (depo kökü) | **Firebase Hosting** — web build’i (Flutter web) yayınlamak için. |
| `.firebaserc` (şablon) | Firebase proje ID’si; **kendi ID** ile düzenle. |
| `backend` CORS | `CORS_ALLOW_ORIGINS` ile canlıdaki **web alan adın** listelenebilir. |

## 1) Firebase projesini oluştur

1. [Firebase Console](https://console.firebase.google.com/) → **Add project**.
2. Analytics isteğe bağlı; geliştirme için kapatabilirsin.
3. Projeye **Web, Android, iOS** (ve gerekiyorsa) uygulamaları ekle.

## 2) `firebase_options` dosyasını kendi projenle üret

Geliştirme makinesinde:

```bash
cd mobile
dart pub global activate flutterfire_cli
flutter pub get
flutterfire configure
```

- Sorulan sorularda aynı Firebase projesini seç; çıktı **`lib/firebase_options.dart`** dosyasını **üzerine yazar**.
- Bu dosyadaki **müşteri API anahtarları** halka açık kabul edilir; yine de **güvenlik kurallarını** (Storage, Firestore, vb.) sunucu tarafında kısıtla.

**Not:** Eski `lib/firebase_options.dart` sadece geliştirme için commit edilebilir; canlıda mutlaka kendi `projectId` ile değiştir.

## 3) CLI ile Firebase’e giriş ve Hosting (web + alan adı)

```bash
# Depo kökü (delea-app)
npm install -g firebase-tools
firebase login
# .firebaserc içinde "projects.default" = kendi project ID'n
```

### Web build ve ilk deploy

```bash
cd mobile
flutter build web --release
cd ..
firebase deploy --only hosting
```

### Özel alan (custom domain)

1. Console → **Hosting** → **Add custom domain** (ör. `app.senin-domain.com` veya `dla.senin-domain.com`).
2. Sana verilen **A / AAAA** veya **TXT** kayıtlarını DNS’te (Cloudflare, GoDaddy, vs.) ekle; doğrulama bitince **SSL** Firebase tarafında ücretsiz açılır.
3. Flutter web, API’ye (ör. `https://api.delea.app`) istek atar; aşağıdaki **CORS** bölümünü uygula.

**Önemli:** Uygulama `ApiService` içinde release modda `https://api.delea.app` (veya `--dart-define=API_BASE_URL=...`) kullanır. **API ayrı sunucudaysa** (Python FastAPI), API’nin o sunucuda çalışması gerekir; Firebase Hosting sadece **statik web** (Flutter build) barındırır.

## 4) Arka uç (FastAPI) CORS ve alan adı

Tüm origin’lere izin (`*`) canlıda sorunlu olabilir. `.env` ile kısıtla:

```env
CORS_ALLOW_ORIGINS=https://app.senin-domain.com,https://senin-domain.com,https://api.delea.app
```

Aynı satırlar `backend/.env.example` içinde örnek verilmiştir.

- **CORS sadece tarayıcıyı** ilgilendirir; mobil (Android/iOS) uygulaması aynı API’ye farklı kurallarla bağlanabilir.
- iOS / Android uygulama imzaları, mağaza paket adları ayrı konudur; Firebase’de **SHA-1** (Android) ve **Bundle ID** (iOS) eşlemesi, özellikle **Google Sign-In / FCM** eklerken gerekir.

## 5) Ortam bazlı API adresi (Flutter)

| Amaç | Komut / ayar |
|------|----------------|
| Lokal | Varsayılan veya `API_BASE_URL=http://127.0.0.1:8000` |
| Cihazda bilgisayar | `--dart-define=API_BASE_URL=http://IP:8000` |
| Canlı | Release + `https://...` veya `API_BASE_URL` CI’da set |

## 6) Sık sorunlar

- **Web’de ağ hatası:** CORS’te Flutter web’in **tam origin**’i (şema + alan, port) olmalı.
- **iOS `pod install`:** İlk `firebase_core` sonrası `cd ios && pod install`.
- **Farklı Firebase proje (dev / prod):** Ayrı Firebase projeleri + CI’da farklı `flutter build` with `--dart-define` veya farklı `firebase_options` (ör. `firebase_options_staging.dart`) ileri seviye; şimdilik tek proje yeter.

## Özet

1. `flutterfire configure` → kendi `firebase_options.dart`
2. `flutter build web` + `firebase deploy` → canlı web + alan
3. DNS’i Firebase yönergesine göre bağla
4. `CORS_ALLOW_ORIGINS` / API domain’i üretim ortamına koy
5. Mobil mağaza derlemesinde aynı Firebase projesini (isteğe bağlı) eşle

Daha ileri: **App Check**, **Cloud Functions** (proxy), **FCM** bildirimleri ayrı adımlarla eklenebilir.
