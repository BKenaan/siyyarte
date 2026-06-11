# Garagi — Cloud Functions

Server-side backend for Garagi.

## Functions

| Function | Trigger | Purpose |
|----------|---------|---------|
| `dailyReminderSweep` | Scheduled, every day 08:00 Asia/Beirut | For each user's vehicles, computes date-certain reminders (time-based services + insurance + Mécanique) and sends FCM push to their devices. Prunes dead tokens. |
| `setAdminClaim` | Callable (admins only) | Grants/revokes the `admin` custom claim used by `firestore.rules` and the admin panel. |

> Mileage-based predictions ("due in 500 km") stay on-device (local
> notifications) — the server can't know future driving. The sweep mirrors the
> Dart engine's **factory severe-conditions month intervals** for date-based items.

## Deploy

```bash
cd functions
npm install
npm run build           # tsc → lib/
firebase deploy --only functions
# or everything: firebase deploy   (functions + firestore + storage rules)
```

Rules deploy from the repo root (`firebase.json` references `firestore.rules`
and `storage.rules`):

```bash
firebase deploy --only firestore:rules,storage
```

## Bootstrapping the first admin

`setAdminClaim` requires the caller to already be an admin, so seed the first
one once via the Admin SDK (e.g. a local script or Cloud Shell):

```js
const admin = require("firebase-admin");
admin.initializeApp();
admin.auth().setCustomUserClaims("<UID>", {admin: true});
```

After that, admins manage others through `setAdminClaim` / the admin panel.

## Local development

```bash
npm run serve   # build + start the functions emulator
```

Use the emulator suite (`firebase emulators:start`) to exercise the sweep
against seeded Firestore data before deploying.
