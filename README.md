# PsychoSound (MusicTerapi)

**Türkçe** | [English](#english)

Duygu durumuna göre müzik dinletip seans öncesi/sonrası stres düzeyini ölçen, Flutter ile yazılmış bir **müzik terapi** uygulaması. Basit bir deney/kontrol grubu düzeniyle küçük çaplı araştırmalarda veri toplamak için tasarlandı. Tüm veriler cihazda (Hive) tutulur; uygulama internet bağlantısı veya sunucu kullanmaz.

## Özellikler
- **Karşılama (onboarding)** ekranı; ilk açılışta kullanıcı rastgele **Grup 1 (Deney)** veya **Grup 2 (Kontrol)** grubuna atanır.
- **Duygu seçimi:** Stresli 😣, Kaygılı 😟, Yorgun 😴, Odak 🎯, Mutsuz 😔.
  - Grup 1: seçilen duyguyla etiketlenmiş aktif seslerden çalınır.
  - Grup 2: tüm aktif seslerden çalınır.
- **Seans öncesi stres** ölçümü (1–10 kaydırıcı).
- **Dinleme seansı:** 5 / 7 / 10 / 12 / 15 dakikalık zamanlayıcı, erken bitirme; ses çalınamazsa zamanlayıcı yine çalışır.
- **Seans sonrası stres** ölçümü ve **mini anket** (rahatlama 1–5, iyi hissetme 1–5, tekrar ister misiniz).
- **Seans geçmişi** ve seans detayı (önce/sonra stres, Δ stres, anket).
- **Grafikler:** son 14 günün özeti, ortalama stres önce/sonra, Δ stres, anket sonuçları, duygu dağılımı.
- **CSV dışa aktarma** (`muzik_terapi_<tarih>.csv`): dosyaya kaydet veya paylaş.
- **Admin Panel:** MP3/WAV/M4A ses içe aktarma, önizleme, başlık ve duygu etiketlerini düzenleme, sesi aktif/pasif yapma, silme; seans süresi ve grup değiştirme; tüm verileri sıfırlama.
- Açık/koyu tema (Material 3, teal).

## Teknolojiler
- Flutter, Dart SDK `^3.5.0`
- `flutter_riverpod` (durum yönetimi), `hive` / `hive_flutter` (yerel veritabanı)
- `just_audio`, `just_audio_windows`, `audio_session` (ses çalma)
- `file_picker`, `path_provider`, `csv`, `share_plus`, `uuid`, `intl`

Platform klasörleri: Android, iOS, Windows, Linux, macOS, Web. Sürüm yalnızca Android ve Windows için derlendi; diğerleri test edilmedi.

## Kurulum ve çalıştırma
```bash
flutter pub get
flutter run                 # bağlı cihaz / emülatör
flutter build apk --release # Android
flutter build windows       # Windows
```
Firebase, API anahtarı veya `--dart-define` gerekmez. İlk kullanımda **Ayarlar → Admin Panel**'den ses dosyası ekleyip duygu etiketlerini seçin; ses yoksa seans başlatılamaz.

## Proje yapısı
```
lib/
  main.dart            Hive başlatma, rastgele grup ataması, tema
  constants.dart       duygular ve seans süreleri
  models/              Track, SessionRecord, AppSettings (+ Hive adapter'ları)
  providers/           Riverpod sağlayıcıları (ses, seans, ayar)
  screens/             onboarding, ana sayfa, duygu, stres önce/sonra, dinleme,
                       anket, geçmiş, detay, grafikler, ayarlar, admin
  services/            CSV dışa aktarma, dosya içe aktarma, güvenli ses oynatıcı
```

## Bilinen sorunlar / notlar
- Android release derlemesi **debug anahtarıyla** imzalanıyor (Flutter varsayılanı). Mağazaya koymak için kendi imza ayarınızı ekleyin.
- Admin Panel herhangi bir şifre ile korunmuyor; Ayarlar ekranından herkes erişebilir.
- Ses dosyaları uygulamayla birlikte gelmez, kullanıcı tarafından eklenir.
- `test/widget_test.dart` varsayılan şablon testi olarak kalmış olabilir.

## Proje tarihleri
- Oluşturma: **21 Şubat 2026**
- Son güncelleme: **24 Şubat 2026**

(Tarihler kaynak dosyalarının değiştirilme tarihlerinden alınmıştır.)

## Lisans
Lisans belirtilmemiştir.

---

<a name="english"></a>
## English

**PsychoSound (MusicTerapi)** is a Flutter **music therapy** app that plays music based on the user's mood and measures stress before and after each session. It uses a simple experimental/control group design for collecting data in small studies. All data stays on the device (Hive); the app uses no network or backend.

### Features
- Onboarding; on first launch the user is randomly assigned to **Group 1 (Experimental)** or **Group 2 (Control)**.
- Mood selection (Stressed, Anxious, Tired, Focus, Sad). Group 1 plays tracks tagged with the chosen mood; Group 2 plays from all active tracks.
- Pre-session stress rating (1–10), listening session with a 5/7/10/12/15-minute timer, post-session stress rating, and a mini survey (relaxation 1–5, feeling good 1–5, would repeat).
- Session history and detail, charts (last 14 days, average stress before/after, Δ stress, survey results, mood distribution).
- CSV export (save or share).
- Admin panel: import MP3/WAV/M4A, preview, edit title and mood tags, enable/disable, delete; change session length and group; reset all data.
- Light/dark Material 3 theme. UI language: Turkish.

### Tech
Flutter (Dart SDK `^3.5.0`), Riverpod, Hive, just_audio (+ Windows), audio_session, file_picker, path_provider, csv, share_plus, uuid, intl. Platform folders: Android, iOS, Windows, Linux, macOS, Web (built and used on Android and Windows only).

### Build
```bash
flutter pub get
flutter run
flutter build apk --release
flutter build windows
```
No Firebase, API keys or `--dart-define` are required. Add audio files via **Settings → Admin Panel** before starting a session.

### Known issues
- Android release builds are signed with the debug key (Flutter default).
- The admin panel is not password protected.
- No audio tracks are bundled.

### Project dates
- Created: **February 21, 2026**
- Last updated: **February 24, 2026**

### License
No license specified.