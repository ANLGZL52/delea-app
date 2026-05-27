# iOS imzalama ve Codemagic — sıfırdan kurulum

Bundle ID: `com.delea.app`  
Team ID: `25YU5R23MS`  
Uygulama adı: DLA +

Bu rehber, eski sertifika/profil/entegrasyonları temizleyip Codemagic’in otomatik imzalama ile yeniden kurmanız içindir.

---

## Aşama 1 — Apple Developer Portal’da temizlik

[developer.apple.com/account](https://developer.apple.com/account) → oturum: Team `25YU5R23MS`.

### 1.1 Provisioning Profiles (önce bunlar)

**Profiles** → `com.delea.app` ile ilgili tüm profilleri bulun → **Delete** (özellikle App Store / Distribution olanlar).

### 1.2 Certificates

**Certificates** → şunları **Revoke** edin (sadece bu projeye özel olanlar; başka uygulama kullanıyorsa dokunmayın):

- **Apple Distribution** (eski ad: iOS Distribution)
- İsteğe bağlı: bu Mac’e özel **Apple Development** (sadece CI kullanıyorsanız Development’ı da silebilirsiniz)

> Apple en fazla **3** adet Distribution sertifikasına izin verir. Eski kayıtlar kalırsa Codemagic yeni sertifika oluşturamaz.

### 1.3 App ID (silme)

**Identifiers** → `com.delea.app` → **silinmez** (App Store Connect’te uygulama varsa bırakın). Sadece profil ve sertifikaları temizleyin.

---

## Aşama 2 — App Store Connect API key

[appstoreconnect.apple.com](https://appstoreconnect.apple.com) → **Users and Access** → **Integrations** → **App Store Connect API** → **Keys**.

### Eski key (isteğe bağlı)

Eski Codemagic key’ini **Revoke** edebilirsiniz (yeni key oluşturacaksanız).

### Yeni key

1. **+** → isim örn. `Codemagic DLA`
2. Erişim: **Admin** veya en az **App Manager** (sertifika/profil için gerekli)
3. **Generate** → **.p8 dosyasını bir kez indirin** (tekrar indirilemez)
4. **Issuer ID** ve **Key ID**’yi not edin

---

## Aşama 3 — Codemagic temizlik

[Codemagic](https://codemagic.io) → **Team settings**.

### 3.1 Code signing identities

**codemagic.yaml settings** → **Code signing identities** (veya uygulama → Distribution):

- `com.delea.app` ile ilgili tüm **sertifikaları** silin
- Tüm **provisioning profile** kayıtlarını silin

### 3.2 Entegrasyon

**Team integrations** → **Developer Portal** / **App Store Connect**:

- Eski `Codemagic delea` entegrasyonunu **silin** veya güncelleyin
- **Add integration** → App Store Connect API
- Ad: `codemagic.yaml` içindeki isimle **aynı** (`Codemagic delea` veya yaml’da değiştirdiğiniz ad)
- Issuer ID, Key ID, `.p8` yükleyin

### 3.3 Uygulama ayarı

Uygulama → **Repository** → working directory: **boş** veya `./` (ek `mobile/` prefix yok).

**Start new build** → workflow: `ios-workflow` / `DLA+ iOS`.

---

## Aşama 4 — İlk build (otomatik oluşturma)

`codemagic.yaml` şunları yapar:

1. `keychain initialize`
2. `app-store-connect fetch-signing-files` → yeni **Apple Distribution** + **App Store** profili
3. `xcode-project use-profiles`
4. `flutter build ipa --release` (sabit `ExportOptions.plist` yok)

Build log’da kontrol:

```text
Fetching signing files
Apple Distribution
```

`security find-identity` çıktısında **Apple Distribution** görünmeli.

---

## Aşama 5 — Sorun giderme

| Belirti | Çözüm |
|--------|--------|
| `No signing certificate "iOS Distribution"` | Aşama 1–3 tekrar; Distribution limiti (3) dolu mu? |
| API key hatası | Key rolü Admin/App Manager; Issuer/Key ID/.p8 doğru |
| Entegrasyon adı uyuşmuyor | `codemagic.yaml` → `integrations.app_store_connect` = UI adı |
| Profil bulunamadı | Apple’da `com.delea.app` App ID aktif; fetch log’unda hata var mı |
| Yanlış team | Team ID `25YU5R23MS` Apple hesabı ile API key aynı organizasyon |

---

## Yerel Mac (isteğe bağlı)

Keychain Access → **login** → eski `Apple Distribution: …` / `iPhone Developer` girişlerini silebilirsiniz. CI için zorunlu değil.

---

## Repo notları

- `mobile/ios/ExportOptions.plist` kaldırıldı — sabit profil adı (`DLA Plus App Store`) uyumsuzluğu önlenir.
- `Podfile` Release/Profile pod imzası: `Apple Distribution` + Team `25YU5R23MS` (CI ile uyumlu).

Entegrasyon adını değiştirirseniz `codemagic.yaml` içindeki `app_store_connect` satırını güncelleyin.
