# SIGAP

**SIGAP (Sistem Informasi Gestion Area Penyakit)** adalah aplikasi mobile Flutter untuk pemetaan dan monitoring laporan warga terkait pembangunan desa dan masalah kesehatan masyarakat.

## Project Overview

SIGAP adalah platform yang memungkinkan warga untuk melaporkan berbagai masalah di lingkungan mereka, yang kemudian diproses melalui workflow verifikasi dan penanganan oleh berbagai role seperti surveyor, verifikator, petugas, dan operator.

### Stack Teknologi

| Kategori | Teknologi |
|----------|-----------|
| Framework | Flutter 3.x |
| State Management | Riverpod (flutter_riverpod, riverpod_annotation) |
| Local Database | Drift (SQLite) |
| Networking | Dio |
| Navigation | GoRouter |
| Maps | flutter_map dengan OpenStreetMap |
| Location | geolocator, permission_handler |
| Image Handling | image_picker, image, exif |
| Background Sync | workmanager |
| Notifications | flutter_local_notifications |

## Prerequisites

- **Flutter SDK**: versi 3.x atau lebih tinggi
- **Dart SDK**: versi yang kompatibel dengan Flutter SDK
- **Android SDK**: untuk build Android APK
- **iOS toolchain**: Xcode dan CocoaPods untuk build iOS (jika targeting iOS)

## Setup

### 1. Install Dependencies

```bash
cd kmipn-26-flutter
flutter pub get
```

### 2. Generate Riverpod Code (jika diperlukan)

Beberapa file menggunakan annotations yang memerlukan code generation:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Konfigurasi API Base URL

API base URL dikonfigurasi pada **compile time** menggunakan `--dart-define`. Lihat section API Configuration di bawah untuk detail lengkap.

## Development

### Run Development Server

**Android Emulator (koneksi ke host machine):**
```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8787
```

**Physical Device atau Emulator lain:**
```bash
flutter run --dart-define=API_BASE_URL=http://YOUR_HOST_IP:8787
```

### Run dengan Release Build (Debug)

```bash
flutter run --release --dart-define=API_BASE_URL=http://10.0.2.2:8787
```

## Build

### Android APK (Release)

```bash
flutter build apk --release
```

Default production URL adalah `https://sigap.live`.

### Android APK dengan Custom URL

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://custom-api.example.com
```

### Android APK (Debug)

```bash
flutter build apk --debug
```

### iOS (Release)

```bash
flutter build ios --release
```

## Deployment

### Building for Production

The Flutter app is configured to connect to the production API at `https://sigap.live` by default when built with `--release`.

**Android Release APK:**
```bash
flutter build apk --release
```

**iOS Release:**
```bash
flutter build ios --release
```

### Connecting to a Deployed Backend

The app connects to the backend API defined by `API_BASE_URL` at compile time. The default production URL is `https://sigap.live`.

**To connect to a different backend:**
```bash
# Local development (Android emulator connects to host machine)
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8787

# Custom deployed backend
flutter build apk --release --dart-define=API_BASE_URL=https://your-backend.example.com
```

> **Note:** The app does not read `.env` at runtime. The API URL must be set at compile time via `--dart-define`.

### Publishing

**Android (Play Store):** Follow Google Play Store publishing guidelines. Build the release APK with `flutter build apk --release`, sign it, and upload to the Play Console.

**iOS (App Store):** Build with `flutter build ios --release`, then use Xcode or Transporter to upload to the App Store.

## API Configuration

API base URL diatur pada **compile time** menggunakan `String.fromEnvironment`. Dart tidak membaca `.env` file pada runtime, sehingga konfigurasi harus dilakukan via `--dart-define`.

### Default (Production)

```bash
flutter build apk --release
```

Defaults ke `https://sigap.live`.

### Override pada Build Time

**Build production dengan custom URL:**
```bash
flutter build apk --release --dart-define=API_BASE_URL=https://sigap.live
```

**Local dev (Android emulator connects to host machine):**
```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8787
```

> **Note:** Dart tidak membaca `.env` files pada runtime. Override harus dilakukan via `--dart-define` pada saat build atau run.

## Project Structure

```
lib/
├── main.dart              # Entry point aplikasi
├── router.dart            # Konfigurasi GoRouter navigation
├── api/                   # API client dan service classes
├── config/                # Configuration files
├── db/                    # Drift database (SQLite)
├── features/              # Feature modules (role-based screens)
│   ├── admin_daerah/      # Admin Daerah dashboard & screens
│   ├── auditor/           # Auditor screens
│   ├── create/            # Create report screen
│   ├── detail/            # Report detail screen
│   ├── exec/              # Exec dashboard
│   ├── map/               # Map screen
│   ├── notifications/     # Notification screens
│   ├── operator/          # Operator dashboard & case management
│   ├── petugas/           # Petugas task screens
│   ├── profile/           # User profile screen
│   ├── role_switcher/     # Role switching UI
│   ├── rt_rw/             # RT/RW verification screens
│   ├── settings/          # Settings screen
│   ├── surveyor/          # Surveyor task screens
│   ├── verifikator/       # Verifikator queue & case screens
│   └── warga/             # Warga home & complaint screens
├── providers/             # Riverpod providers
├── screens/               # Shared screens (verifikator queue, petugas dashboard)
├── services/              # Services (notifications)
├── sync/                  # Background sync workers
├── theme/                 # App theme (colors, typography)
└── widgets/               # Reusable widgets
```

### Key Directories

- **lib/features/**: Setiap folder merepresentasikan sebuah role atau fitur spesifik. Setiap fitur memiliki screen-screen yang relevan.
- **lib/api/**: Berisi API client yang menggunakan Dio untuk HTTP requests.
- **lib/providers/**: Riverpod providers untuk state management. Menggunakan `riverpod_annotation` untuk generate kode.
- **lib/db/**: Drift database schema dan DAOs. Database SQLite untuk offline-first capability.
- **lib/sync/**: Background sync worker menggunakan WorkManager untuk sinkronisasi data.
- **lib/theme/**: App-wide theming dengan light/dark mode support.

## Role-Based Access

Aplikasi SIGAP mendukung multiple roles dengan akses yang berbeda:

| Role | Deskripsi |
|------|-----------|
| **Warga** | Membuat laporan, melihat status, upload bukti tambahan |
| **Surveyor** | Melihat dan menyelesaikan tugas survei |
| **Verifikator** | Memverifikasi laporan di antrean |
| **Petugas** | Menangani tugas di lapangan |
| **Operator** | Dashboard dan manajemen kasus |
| **Admin Daerah** | Konfigurasi wilayah, kategori, SLA, unit |
| **Auditor** | Melihat log audit |
| **Exec** | Executive dashboard |

## Testing

### Run Unit Tests

```bash
flutter test
```

### Run Integration Tests

```bash
flutter test integration_test/
```

## Troubleshooting

### Common Build Issues

**1. Drift Code Generation Fails**

Jika terjadi error pada file database, regenerate code dengan:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**2. Riverpod Provider Build Fails**

Regenerate Riverpod providers:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**3. API Connection Issues**

Pastikan API_BASE_URL sudah benar:
- Android Emulator: gunakan `http://10.0.2.2:8787` (10.0.2.2 adalah host machine dari emulator)
- Physical Device: gunakan IP address host machine, bukan `localhost`

**4. Location Permission Denied**

Pastikan permission handler dikonfigurasi dengan benar di `AndroidManifest.xml` dan `Info.plist`.

**5. Image Picker Tidak Berfungsi**

Untuk camera access, pastikan semua required permissions sudah di-set.

### Debugging Tips

1. **cek API Base URL**: Pastikan URL yang digunakan sesuai dengan environment (development vs production)
2. **Clear Flutter build cache**: `flutter clean` followed by `flutter pub get`
3. **Check drift database version**: Jika ada issue dengan schema, increment schema version di database.dart

## Background Sync

SIGAP menggunakan WorkManager untuk background sync. Sinkronisasi berjalan secara otomatis ketika:
- App dibuka
- Koneksi internet tersedia
- Berdasarkan schedule yang dikonfigurasi

Sync worker ada di `lib/sync/background_sync.dart`.

## Offline Capability

Dengan Drift (SQLite), aplikasi SIGAP mendukung offline-first approach:
- Data disimpan lokal sebelum di-sync ke server
- Perubahan offline di-queue untuk sync later
- Conflict resolution ditangani oleh sync worker

## Further Documentation

- [Flutter Documentation](https://docs.flutter.dev/)
- [Riverpod Documentation](https://riverpod.dev/)
- [Drift Documentation](https://drift.tech/)
- [GoRouter Documentation](https://gorouter.dev/)
- [flutter_map Documentation](https://docs.fleaflet.dev/)
