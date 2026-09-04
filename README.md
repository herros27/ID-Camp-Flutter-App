# Story App (ID Camp Intermediate / Expert Flutter Project)

Aplikasi Flutter untuk berbagi cerita (stories) yang dilengkapi dengan sistem autentikasi, daftar dan detail cerita, pengunggahan foto & deskripsi, integrasi Google Maps untuk pemilihan dan pemetaan lokasi, serta pengkonfigurasian **Product Flavors** (`free` & `paid`).

---

## 📌 Fitur Utama

- 🔐 **Autentikasi User**: Registrasi akun baru dan Login pengguna dengan manajemen token sesi (`SharedPreferences`).
- 📜 **Story Feed / List**: Menampilkan daftar cerita pengguna yang telah diunggah.
- 🔍 **Detail Story**: Menampilkan rincian foto, deskripsi, tanggal pembuatan, serta peta lokasi pengunggahan.
- ➕ **Upload Story**: Mengunggah cerita baru beserta gambar (kamera/galeri) dan lokasi interaktif.
- 📍 **Google Maps & Location Picker**: Integrasi peta untuk memilih koordinat lokasi story saat upload dan menampilkan penanda pada detail story.
- 🎨 **Product Flavors**:
  - **Free Flavor**: Versi gratis aplikasi (`.free` ID suffix).
  - **Paid Flavor**: Versi berbayar aplikasi (`.paid` ID suffix).
- 🛡️ **Guarded Navigation**: Pengaturan rute menggunakan `go_router` yang secara otomatis mengarahkan ke halaman login jika token belum ada.

---

## 🛠️ Teknologi & Dependencies

- **Framework**: [Flutter](https://flutter.dev) (SDK ^3.7.2)
- **Routing**: `go_router` (^15.1.1)
- **Networking**: `http` (^1.4.0)
- **State & Data Modeling**: `freezed` (^3.0.0), `json_annotation` (^4.9.0)
- **Local Storage**: `shared_preferences` (^2.5.3)
- **Peta & Lokasi**: `google_maps_flutter`, `geocoding`, `location`
- **Media**: `image_picker` (^1.1.2)
- **Environment Management**: `flutter_dotenv` (^5.2.1)
- **Code Generation**: `build_runner`, `freezed`, `json_serializable`

---

## 📂 Struktur Proyek

```text
lib/
├── models/             # Data Models (Story model generated via Freezed)
│   ├── story.dart
│   ├── story.freezed.dart
│   └── story.g.dart
├── screens/            # UI / Tampilan Layar Aplikasi
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── story_list_screen.dart
│   ├── story_detail_screen.dart
│   ├── story_upload_screen.dart
│   └── map_picker_screen.dart
├── services/           # Service API & Autentikasi
│   ├── auth_service.dart
│   └── story_service.dart
├── utils/              # Utility & Config Env
│   └── env.dart
├── main.dart           # Entry point standar
├── main_common.dart    # Logic shared antar flavors
├── main_free.dart      # Entry point flavor Free
├── main_paid.dart      # Entry point flavor Paid
└── router.dart         # Konfigurasi GoRouter & Auth Guard
```

---

## 🚀 Panduan Memulai (Getting Started)

### 1. Prasyarat
- Flutter SDK v3.7.2 atau yang terbaru.
- Dart SDK.
- Google Maps API Key.

### 2. Setup Environment Variable & Google Maps API Key
1. Buat file `.env` di direktori utama proyek (root):
   ```env
   BASE_URL=https://story-api.dicoding.dev/v1
   ```
2. Tambahkan `MAPS_API_KEY` pada file `android/local.properties`:
   ```properties
   MAPS_API_KEY=YOUR_GOOGLE_MAPS_API_KEY_HERE
   ```

### 3. Install Dependencies
Jalankan perintah berikut di terminal:
```bash
flutter pub get
```

### 4. Code Generation (Jika Memodifikasi Model)
Jika ada perubahan pada model data Freezed/JSON Serializable:
```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## 💻 Menjalankan Aplikasi

### Menjalankan Flavor Standard / Default:
```bash
flutter run
```

### Menjalankan Flavor Free:
```bash
flutter run --flavor free -t lib/main_free.dart
```

### Menjalankan Flavor Paid:
```bash
flutter run --flavor paid -t lib/main_paid.dart
```

---

## 📦 Build Release (APK)

Untuk menghasilkan file APK sesuai flavor:

- **Free Flavor APK**:
  ```bash
  flutter build apk --flavor free -t lib/main_free.dart
  ```

- **Paid Flavor APK**:
  ```bash
  flutter build apk --flavor paid -t lib/main_paid.dart
  ```

