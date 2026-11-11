/**
 * Creates (or resets) a dedicated THROWAWAY beta-test account in this project's
 * Firebase Auth, with a ready profile + one demo vehicle so testers land on a
 * working app. For closed-test / login-testing only — delete when done.
 *
 * Usage (from functions/):  node scripts/create_test_user.js
 */
const admin = require("firebase-admin");
const crypto = require("crypto");
const path = require("path");

admin.initializeApp({
  credential: admin.credential.cert(
    require(path.resolve(__dirname, "..", "service-account.json"))),
});
const auth = admin.auth();
const db = admin.firestore();

const EMAIL = "beta-test@bkenaan.dev";
// Strong, typeable password (no ambiguous chars).
const PASSWORD =
  "Siyyarte-" + crypto.randomBytes(4).toString("hex").toUpperCase() + "-7x";

(async () => {
  let uid;
  try {
    const existing = await auth.getUserByEmail(EMAIL);
    uid = existing.uid;
    await auth.updateUser(uid, {password: PASSWORD, emailVerified: true});
    console.log("Reset existing test user.");
  } catch (e) {
    const u = await auth.createUser({
      email: EMAIL,
      password: PASSWORD,
      displayName: "Siyyarte Tester",
      emailVerified: true,
    });
    uid = u.uid;
    console.log("Created new test user.");
  }

  // Profile (so login skips the city-setup gate and goes to the dashboard).
  await db.collection("users").doc(uid).set({
    name: "Siyyarte Tester",
    city: "Beirut",
    currency: "USD",
  }, {merge: true});

  // One demo vehicle — a Toyota Corolla 2020 (GCC), which showcases the
  // manufacturer-verified specs layer. No VIN so it doesn't touch the registry.
  const now = new Date().toISOString();
  await db.collection("users").doc(uid).collection("vehicles").doc("demo-corolla")
    .set({
      make: "Toyota",
      model: "Corolla",
      year: 2020,
      trim: "GLI",
      engineType: "1.8L I4",
      fuelType: "Petrol",
      transmission: "CVT",
      odometerKm: 62000,
      odometerUpdatedAt: now,
      plateNumber: "DEMO 1234",
      registrationCardUrl: "seed://demo",
      regStatus: "none",
      createdAt: now,
    }, {merge: true});

  console.log("\n=== SIYYARTE TEST LOGIN ===");
  console.log("Email:    " + EMAIL);
  console.log("Password: " + PASSWORD);
  console.log("(email/password sign-in; one login works on all devices)");
  process.exit(0);
})().catch((e) => { console.error(e); process.exit(1); });
