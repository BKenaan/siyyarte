# Garagi — كراجي

**Car maintenance tracker & reminder, built for the Lebanese market.**
Track services, get smart reminders (by mileage *and* time, incl. insurance &
Mécanique), estimate costs in USD/LBP, and keep full service history — offline-first,
in English & Arabic (full RTL).

Built with **Flutter + Firebase** (Riverpod, gen-l10n).

---

## Quick start

```bash
flutter pub get
flutter gen-l10n        # generates AppLocalizations from lib/l10n/*.arb
flutter run             # runs immediately on mock data — no backend needed
flutter test            # runs the maintenance-engine unit tests
```

The app **runs out of the box with no cloud setup**: until Firebase is wired it
uses in-memory mock repositories seeded with a demo Lebanese car (2018 Toyota
Corolla GLI) so every screen is populated. Sign in with any email/password, or
tap any social/phone button — the mock accepts anything.

---

## Architecture

```
lib/
├─ main.dart                      app entry, ProviderScope, prefs override
├─ app.dart                       MaterialApp, theming, locale/RTL, auth gate
├─ core/
│  ├─ bootstrap.dart              kUseFirebase flag + safe Firebase init
│  ├─ providers.dart              Riverpod providers (repos, auth, vehicles, locale)
│  ├─ firebase/                   firebase_options.dart (placeholder)
│  ├─ theme/                      app_colors.dart, app_theme.dart
│  ├─ constants/                  lebanon.dart (cities, currencies, markets)
│  └─ models/                     money.dart (USD/LBP)
├─ l10n/                          app_en.arb, app_ar.arb
└─ features/
   ├─ auth/                       AuthRepository + mock impl, login screen
   ├─ vehicles/                   Vehicle model, GarageRepository + mock impl
   ├─ maintenance/                ServiceType, rules, ServiceRecord
   │  └─ engine/                  MaintenanceEngine ← the core IP
   ├─ dashboard/                  dashboard + HealthGauge
   ├─ settings/                   language toggle, logout
   └─ shell/                      bottom-nav HomeShell
```

### The maintenance engine
`features/maintenance/engine/maintenance_engine.dart` is **pure, deterministic
Dart** — no Flutter, no I/O — so it runs identically on-device (offline) and in
a server-side validation Cloud Function. Given a vehicle + its history it
computes next-due mileage/date and a Green/Yellow/Red status per service, with a
trim → model → make → global rule cascade. Covered by `test/maintenance_engine_test.dart`.

---

## Connecting Firebase (when ready)

1. `dart pub global activate flutterfire_cli`
2. `flutterfire configure --project=<your-firebase-project>`
   (overwrites `lib/core/firebase/firebase_options.dart`, adds platform files)
3. Set `kUseFirebase = true` in `lib/core/bootstrap.dart`.
4. Implement `FirebaseAuthRepository` / `FirestoreGarageRepository` against the
   existing `AuthRepository` / `GarageRepository` interfaces and swap the two
   overrides in `lib/core/providers.dart`. **No screen changes needed.**

Firestore layout, security rules, Cloud Functions, and the admin panel are
specified in the design doc delivered with this project.

---

## Status (MVP)

| Area | State |
|------|-------|
| Theming + design tokens | ✅ |
| EN/AR i18n + full RTL | ✅ |
| Auth (mock + Firebase impl) | ✅ |
| Vehicle model + repository | ✅ |
| **Factory-sourced** maintenance engine + tests | ✅ |
| Dashboard + health gauge | ✅ |
| Add/edit vehicle guided flow | ✅ |
| Mark-service-done sheet (→ engine recalculates) | ✅ |
| Cost center (USD/LBP, editable) | ✅ |
| Service history timeline + PDF export | ✅ |
| Reminders (local notifications + FCM hook) | ✅ |
| Firestore + FirebaseAuth implementations | ✅ |
| Firestore + Storage security rules | ✅ |
| Admin web panel (`lib/main_admin.dart`) | ✅ |
| Editable make/model combos (grey-market imports) | ✅ |
| Invoice photo upload (image_picker → Storage) | ✅ |
| FCM token registration | ✅ |
| Cloud Functions: daily reminder sweep + admin claim | ✅ |
| Onboarding carousel (EN/AR) + language pick | ✅ |
| Profile setup + edit (name/city/currency) | ✅ |
| Phone OTP entry flow | ✅ |
| Account deletion + data export (PDF) | ✅ |

### Maintenance intervals are factory-sourced
Intervals come from manufacturers' published maintenance schedules (Toyota,
Honda, Nissan, Hyundai/Kia, BMW, Mercedes, VW…), encoded with BOTH the normal
and the **severe / special-operating-conditions** values. Lebanon's driving
(dust, heat, short trips, stop-and-go) meets every OEM's severe-conditions
definition, so the engine defaults to the severe schedule. Items with no factory
interval (tires, battery, brake pads) are flagged in-app as wear-based
estimates, and the annual Mécanique is flagged as a legal requirement. See
`lib/features/maintenance/models/maintenance_rule.dart` for the cited table; the
admin panel overrides any value per make/model/trim.

All cost figures are estimates and vary by location, garage, exchange rate and
vehicle type.

## Admin panel

```bash
flutter run -d chrome -t lib/main_admin.dart
```

Manages the vehicle catalog, factory intervals, cost tariffs, users and
announcements. Gated behind the Firebase `admin` custom claim in production
(see `firestore.rules`).

## Backend (Cloud Functions)

Lives in [`functions/`](functions/) (TypeScript). See its
[README](functions/README.md) for deploy + first-admin bootstrap.

- **`dailyReminderSweep`** — scheduled 08:00 Asia/Beirut. Computes date-certain
  reminders (time-based services + insurance + Mécanique) per vehicle and sends
  FCM push, pruning dead tokens. Mirrors the Dart engine's factory
  severe-conditions month intervals. (Mileage-based alerts stay on-device.)
- **`setAdminClaim`** — callable (admins only) to grant/revoke the `admin` claim.

```bash
cd functions && npm install && npm run build && firebase deploy --only functions
```

Rules + functions are tied together by [`firebase.json`](firebase.json):
`firebase deploy` ships `firestore.rules`, `storage.rules` and the functions.
