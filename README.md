# عدن الرقمية — Aden Digital

A modern, premium **Flutter** government‑services app for the citizens of Aden.

> Arabic‑first (RTL) • Material 3 • Light/Dark • Responsive • Clean Architecture

---

## ✨ Highlights

- **Material 3** design system with a government‑green brand, gold accents, soft shadows, rounded cards, smooth animations and a custom brand loader.
- **Arabic (default) + English**, full **RTL**, **dark & light** themes — all switchable live from Settings and persisted.
- **Clean Architecture + feature‑first** folder structure.
- **Riverpod** state management, **GoRouter** navigation with auth‑aware redirects.
- **Phone + OTP login** (Firebase Auth) with *Remember me* via Flutter Secure Storage.
- **6 government services** (National ID, Passport, Driving License, Vehicle, Municipality, Utilities) — each with real, working forms and request tracking.
- **Full reports system**: 8 categories, photos (camera/gallery), GPS location, status + tracking timeline.
- **Interactive map** with filterable layers (reports, government / electricity / water offices, police, hospitals) and a legend.
- **Notifications** center (report updates, service updates, announcements).
- **Profile & settings** with editable personal info.

---

## 🚀 Run it

```bash
flutter pub get
flutter run
```

The app **runs out of the box in DEMO mode** (no backend required):

- Use **any phone number** and OTP **`123456`** to sign in.
- Reports, requests, notifications and the map are seeded with realistic sample data.
- The map uses a built‑in, dependency‑free interactive canvas so it renders without a Maps API key.

> Demo mode activates automatically while Firebase credentials are placeholders.

---

## 🔌 Going to production (wire real backends)

Everything is already coded against real SDKs behind interfaces — you only add credentials.

### 1. Firebase

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

This regenerates `lib/core/config/firebase_options.dart` with real keys. Once the
placeholder `REPLACE_*` values are gone, the app leaves demo mode and uses
**Firebase Auth + Cloud Firestore + Storage** automatically (see
`features/auth/data/repositories/firebase_auth_repository.dart` and
`features/reports/data/repositories/firebase_report_repository.dart`).

Enable in the Firebase console: **Phone Authentication**, **Firestore**, **Storage**, **Cloud Messaging**.

### 2. Google Maps

- Android: set the key in `android/app/src/main/AndroidManifest.xml`
  (`com.google.android.geo.API_KEY`).
- iOS: add `GMSServices.provideAPIKey("...")` in `AppDelegate.swift`.
- In `features/map/presentation/screens/map_screen.dart`, swap `CanvasMap(...)`
  for `GoogleMapView(...)` (see `widgets/google_map_view.dart`).

---

## 🗂 Architecture

```
lib/
├── core/                     # cross-cutting: theme, router, storage, widgets, utils, config
│   ├── config/               # firebase_options + runtime flags (demo mode)
│   ├── theme/                # Material 3 colors, themes, settings controller
│   ├── router/               # GoRouter + auth redirect
│   ├── storage/              # secure storage + shared prefs
│   ├── widgets/              # shared premium UI building blocks
│   └── utils/                # formatters, location service, l10n lookup
├── l10n/                     # ARB files (ar/en) + generated AppLocalizations
└── features/                 # feature-first; each: data / domain / presentation
    ├── auth/                 # phone + OTP login, profile entity & repos
    ├── home/                 # dashboard, announcements, quick services
    ├── services/             # 6 services catalog, detail, forms, tracking
    ├── reports/              # list, new report (photos+GPS), detail timeline
    ├── map/                  # interactive map, places, filters, legend
    ├── notifications/        # notification center
    ├── profile/              # profile, settings, edit, about
    └── shell/                # bottom-nav scaffold
```

Each feature follows **data → domain → presentation** with repository interfaces
in `domain/` and Firebase + mock implementations in `data/`.

---

## 🌐 Localization

Strings live in `lib/l10n/app_ar.arb` (default) and `lib/l10n/app_en.arb`.
After editing them, regenerate the Dart bindings:

```bash
flutter gen-l10n
```

---

## 📦 Key packages

Riverpod · GoRouter · Dio · firebase_core/auth/firestore/storage/messaging ·
flutter_secure_storage · google_maps_flutter · geolocator · image_picker ·
camera · cached_network_image · lottie · flutter_svg · intl · google_fonts ·
flutter_animate · shimmer.
