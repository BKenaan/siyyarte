# Garagi — Firebase Go-Live Runbook

This takes Garagi from mock data to a live Firebase backend. Steps marked
**👤 you** need your Google account / console clicks; **🤖 done** is already
staged in the repo.

> Platform note: this machine is **Windows**, so iOS can't be built here. This
> runbook gets **Android + the backend + the admin web app** live now. iOS
> native config (Info.plist usage strings, push) is already staged for when you
> build on a Mac.

---

## Already staged 🤖
- `android/app/build.gradle.kts` — `minSdk` raised to 23 (Firebase Auth requirement).
- `android/app/src/main/AndroidManifest.xml` — INTERNET + notification permissions, FCM default channel, `flutter_local_notifications` boot receivers.
- `ios/Runner/Info.plist` — photo/camera usage strings + push background mode.
- `functions/` — Cloud Functions (`dailyReminderSweep`, `setAdminClaim`), compiled clean.
- `firestore.rules`, `storage.rules`, `firebase.json` — security rules + deploy config.
- `functions/scripts/set_admin.js` — first-admin bootstrap.

---

## Step 1 — Log in 👤
```bash
firebase login
dart pub global activate flutterfire_cli   # if not already
```

## Step 2 — Create the Firebase project 👤
Either the console (https://console.firebase.google.com → Add project) or:
```bash
firebase projects:create garagi-prod   # pick your own unique id
```

## Step 3 — Wire the apps into Flutter 👤
From the repo root:
```bash
flutterfire configure --project=garagi-prod
```
Select **Android**, **iOS**, **web** when prompted. This:
- writes real keys into `lib/core/firebase/firebase_options.dart` (replacing the placeholder),
- adds `android/app/google-services.json` + the Gradle google-services plugin,
- adds `ios/Runner/GoogleService-Info.plist`.

## Step 4 — Enable backend services in the console 👤
Firebase Console → Build:
- **Authentication** → Get started → enable **Email/Password**, **Phone**, **Google**, and **Apple**.
  - Google: pick a support email. Apple: needs an Apple Developer account (can defer).
  - Phone: add a test number while developing to avoid SMS costs.
- **Firestore Database** → Create (production mode; our rules handle access).
- **Storage** → Get started (our `storage.rules` handle access).

## Step 5 — Deploy rules + functions 👤
```bash
cd functions && npm install && npm run build && cd ..
firebase deploy --only firestore:rules,storage,functions
```
> `dailyReminderSweep` needs the **Blaze** (pay-as-you-go) plan for scheduled
> functions + outbound FCM. Firestore/Auth/Storage themselves run fine on Spark
> for testing.

## Step 6 — Flip the app to Firebase 🤖→ (one line)
In `lib/core/bootstrap.dart` set:
```dart
const bool kUseFirebase = true;
```
Then:
```bash
flutter run        # Android device/emulator
```
Sign up → the user doc, vehicles and history now read/write Firestore (offline
cache included). Invoice photos upload to Storage. The FCM token is registered.

## Step 7 — Bootstrap the first admin 👤
1. Sign in once in the app (creates your Auth user).
2. Firebase Console → Authentication → Users → copy your **UID**.
3. Console → Project settings → Service accounts → **Generate new private key** → save as `functions/service-account.json` (git-ignored).
4. Grant yourself admin:
```bash
cd functions
GOOGLE_APPLICATION_CREDENTIALS=./service-account.json node scripts/set_admin.js <YOUR_UID>
```
5. Sign out/in to refresh your token. You can now use the admin panel:
```bash
flutter run -d chrome -t lib/main_admin.dart
```

## Step 8 — Smoke test ✅
- [ ] Sign up with email → user doc appears in Firestore.
- [ ] Add a vehicle → `users/{uid}/vehicles/...` doc appears.
- [ ] Mark a service done with a photo → record + Storage file appear.
- [ ] Phone OTP sign-in works (real SMS or test number).
- [ ] `firebase functions:log` shows `dailyReminderSweep` on schedule.
- [ ] A second user cannot read the first user's data (rules isolation).

---

### Rollback
Set `kUseFirebase = false` to return to offline mock mode at any time — no data
on device is lost (mock store is in-memory/prefs).

### Notes
- `google-services.json` / `GoogleService-Info.plist` contain client config, not
  secrets — committing them is fine (access is enforced by rules + App Check).
- The **service-account key IS a secret** — it stays git-ignored.
- Consider enabling **App Check** (Play Integrity / DeviceCheck) before public
  launch to block API abuse.
