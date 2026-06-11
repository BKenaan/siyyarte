/**
 * One-off: grant the `admin` custom claim to a user, to bootstrap the FIRST
 * admin (after that, admins manage others via the setAdminClaim function /
 * admin panel).
 *
 * Usage (from the functions/ directory):
 *   # 1. Download a service-account key from Firebase Console →
 *   #    Project settings → Service accounts → Generate new private key
 *   #    and save it as functions/service-account.json
 *   # 2. node scripts/set_admin.js <UID> [pathToServiceAccount.json]
 *
 * Find the UID in Firebase Console → Authentication → Users.
 * Loading the key file directly means no GOOGLE_APPLICATION_CREDENTIALS env
 * var is needed (which is easy to get wrong on Windows).
 */
const admin = require("firebase-admin");
const path = require("path");

const uid = process.argv[2];
const keyPath = process.argv[3]
  ? path.resolve(process.argv[3])
  : path.resolve(__dirname, "..", "service-account.json");

if (!uid) {
  console.error("Usage: node scripts/set_admin.js <UID> [serviceAccount.json]");
  process.exit(1);
}

let serviceAccount;
try {
  serviceAccount = require(keyPath);
} catch (e) {
  console.error(
    `Could not read service-account key at:\n  ${keyPath}\n\n` +
      "Download it from Firebase Console → Project settings → Service " +
      "accounts → Generate new private key, and save it as " +
      "functions/service-account.json"
  );
  process.exit(1);
}

admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });

admin
  .auth()
  .setCustomUserClaims(uid, { admin: true })
  .then(() => {
    console.log(
      `✅ Granted admin to ${uid}. Sign out/in to refresh the token.`
    );
    process.exit(0);
  })
  .catch((err) => {
    console.error("Failed:", err.message || err);
    process.exit(1);
  });
