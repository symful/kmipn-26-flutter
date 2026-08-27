# SIGAP — Mobile Application (Flutter)

Mobile client application for **SIGAP (Sistem Informasi Geospasial & Penanganan Laporan Desa)** — a village infrastructure reporting, geospatial monitoring, and field operations platform built with **Flutter 3.x**, **Riverpod**, **Drift (Offline SQLite)**, and **flutter_map**.

---

## 📱 Mobile Overview & Workflow Architecture

The SIGAP mobile application is engineered for reliable field operations even in low-connectivity rural environments. It provides complete role-tailored interfaces for citizens, field surveyors, technical officers, verifiers, operators, local RT/RW heads, regional admins, auditors, and executive leaders.

```
┌────────────────────────────────────────────────────────┐
│                   SIGAP Mobile App                     │
├─────────────┬─────────────┬─────────────┬──────────────┤
│    WARGA    │  SURVEYOR   │   PETUGAS   │  VERIFIKATOR │
│ Create &    │ Checklists, │ Field work, │ Queue triage │
│ Track cases │ GPS survey  │ Proof photo │ & validation │
├─────────────┼─────────────┼─────────────┼──────────────┤
│  OPERATOR   │    RT/RW    │ ADMIN DAERAH│  EKSEKUTIF   │
│ Dispatch &  │ Local RT    │ Unit & SLA  │ KPI trends   │
│ Case stats  │ validation  │ configs     │ & summaries  │
└─────────────┴─────────────┴─────────────┴──────────────┘
                               │
             ┌─────────────────┴─────────────────┐
             ▼                                   ▼
    [ Drift Local DB ]                 [ Dio API Client ]
   (Offline-First Cache)            (Cloudflare Workers API)
             ▲                                   ▲
             └─────────[ WorkManager ]───────────┘
                    (Background Sync)
```

---

## ⚡ Key Capabilities

- **Offline-First Architecture**: Powered by Drift SQLite, allowing reports, surveys, and task updates to be saved locally when offline and automatically synced via WorkManager when network connection is restored.
- **Geospatial Map Intelligence**: Centered on the Indonesian archipelago (`LatLng(-2.548926, 118.0148634)`), constrained within national boundaries, auto-fitting report markers with clustering and interactive pins, plus a one-tap "Pusat Indonesia" camera reset floating action button.
- **Multi-Camera & Exif Extraction**: Integrated camera capture and photo picker with automatic GPS metadata (Latitude, Longitude) and timestamp extraction for verifiable report evidence.
- **Dynamic Field Surveys**: Surveyor checklists with location geocoding, multi-photo attachments, condition scoring, and instant sync.
- **Role Switcher & Quick QA**: Built-in role switcher dialog allowing evaluators and testers to switch between any of the 10 role personas seamlessly.
- **State Management & Architecture**: Feature-driven architecture using Riverpod (`riverpod_annotation`), GoRouter declarative routing, and Dio HTTP client with JWT interceptors.

---

## 🛠️ Technology Stack

| Category | Technology | Purpose |
|---|---|---|
| **Framework** | Flutter 3.x & Dart 3.x | Cross-platform native mobile engine |
| **State Management** | Riverpod 2.6 (`flutter_riverpod`, `riverpod_annotation`) | Reactive, testable state management |
| **Local Database** | Drift (`drift`, `drift_flutter`, `sqlite3`) | Offline-first relational SQLite database |
| **Navigation** | GoRouter 14.x | Declarative URL-driven navigation & guards |
| **Networking** | Dio 5.x | REST API client with JWT refresh interceptors |
| **Geospatial Maps** | flutter_map 7.x + OpenStreetMap | Interactive offline/online tile maps |
| **Location & GPS** | geolocator, permission_handler | High-accuracy GPS location and permissions |
| **Image & Exif** | image_picker, image, exif | Camera capture, compression, GPS metadata extraction |
| **Background Sync** | workmanager | Periodic and opportunistic background task sync |
| **Push / Local Notifs**| flutter_local_notifications | Local task alerts and status update notifications |
| **Design Tokens** | `SigapColors`, `SigapTypography`, `SigapRadius` | Design system tokens matching the web portal |

---

## 📁 Project Structure

```
kmipn-26-flutter/
├── lib/
│   ├── main.dart                  # Application entry point & provider scope
│   ├── router.dart                # GoRouter route definitions & guards
│   ├── api/                       # Dio client, API endpoints, types & interceptors
│   │   ├── api_client.dart        # Full REST API service methods
│   │   ├── auth_interceptor.dart  # JWT Bearer token injection & rotation
│   │   └── types.g.dart           # Generated API DTO models
│   ├── config/                    # Environment & runtime configurations
│   ├── db/                        # Drift database schema, DAOs & migrations
│   │   ├── database.dart          # Local SQLite tables (reports, tasks, queue)
│   │   └── database.g.dart        # Generated Drift code
│   ├── features/                  # Role-based feature modules
│   │   ├── warga/                 # Citizen complaint submission & timeline
│   │   ├── surveyor/              # Field survey task queue & checklist forms
│   │   ├── petugas/               # Technical officer task handling & proof upload
│   │   ├── operator/              # Case dispatch, duplicate merge, SLA tracking
│   │   ├── verifikator/           # Triage queue, report validation & decision
│   │   ├── rt_rw/                 # Neighborhood verification & training
│   │   ├── admin_daerah/          # Technical units, SLA rules & regional stats
│   │   ├── auditor/               # Immutable audit log search & filters
│   │   ├── exec/                  # Executive dashboard with KPI trend charts
│   │   ├── map/                   # Fullscreen interactive geospatial map
│   │   ├── create/                # New report camera & location form
│   │   ├── detail/                # Case detail, timeline & sanggahan modal
│   │   ├── role_switcher/         # Quick QA role-switching dialog
│   │   ├── notifications/         # Notification inbox & preferences
│   │   ├── profile/               # User profile & credentials
│   │   └── settings/              # App preferences, cache & connectivity
│   ├── providers/                 # Riverpod state providers
│   ├── sync/                      # Background sync workers & queue manager
│   ├── theme/                     # SigapColors, typography & UI tokens
│   └── widgets/                   # Reusable cards, badges, buttons, headers
└── android/                       # Native Android configuration & Manifests
```

---

## 🚀 Getting Started & Prerequisites

### Prerequisites
- **Flutter SDK**: 3.22.x or higher
- **Dart SDK**: 3.4.x or higher
- **Android SDK**: API Level 34 / Android 14 target
- **Java**: OpenJDK 17

### Installation
```bash
cd kmipn-26-flutter

# Install Flutter dependencies
flutter pub get

# (Optional) Regenerate Riverpod & Drift code
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## ⚙️ Compilation & API Configuration

The API base URL is resolved at compile-time via `--dart-define=API_BASE_URL=...`.

### 1. Run Development (Connected to Cloudflare Remote)
```bash
flutter run --dart-define=API_BASE_URL=https://kmipn-26-deno.careday17.workers.dev
```

### 2. Run Development (Local Emulator -> Host Machine)
```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8787
```

---

## 📦 Building Production APKs

To build optimized release APKs split by CPU architecture (reducing APK size to ~15MB):

```bash
flutter build apk --release --split-per-abi --dart-define=API_BASE_URL=https://kmipn-26-deno.careday17.workers.dev
```

### Output APK Binaries:
After building, the release APK files are located at:
- `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` (Most modern Android phones)
- `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk` (Older 32-bit Android phones)
- `build/app/outputs/flutter-apk/app-x86_64-release.apk` (Emulators & ChromeOS devices)

To build a single universal fat APK:
```bash
flutter build apk --release --dart-define=API_BASE_URL=https://kmipn-26-deno.careday17.workers.dev
```

---

## 👥 Manual QA Test Accounts

The mobile app includes a built-in **Role Switcher** accessible from the drawer or profile menu. You can also log in directly using the following pre-seeded test accounts:

| Role | Email | Password | Access / Primary Features |
|---|---|---|---|
| **WARGA** | `warga@sigap.id` | `warga123` | Submit complaints, upload photos, view case progress, sanggahan |
| **SURVEYOR** | `surveyor@sigap.id` | `surveyor123` | View assigned survey tasks, fill survey checklist, verify GPS |
| **PETUGAS** | `petugas@sigap.id` | `petugas123` | Field tasks, work progress logs, upload completion evidence |
| **OPERATOR** | `operator@sigap.id` | `operator123` | Task dispatching, merge duplicate reports, SLA monitoring |
| **VERIFIKATOR** | `verifikator@sigap.id` | `verifikator123` | Verification queue, approve/reject reports, review sanggahan |
| **ADMIN_DAERAH** | `admin.daerah@sigap.id` | `admin123` | Regional admin dashboard, technical units, SLA configurations |
| **AUDITOR** | `auditor@sigap.id` | `auditor123` | Immutable audit log trail and user activity inspection |
| **PENGAMBIL_KEPUTUSAN** | `eksekutif@sigap.id` | `exec123` | Executive KPI analytics, budget statistics, resolution trends |
| **ADMIN** | `admin@sigap.id` | `admin123` | Full administrative control, category management, priority weights |
| **RT_RW** | `rtrw@sigap.id` | `rtrw123` | Local RT/RW report validation and community confirmation |

---

## 🧪 Testing & Verification

```bash
# Run unit & widget tests
flutter test

# Run analyzer checks (0 warnings expected)
flutter analyze lib
```

