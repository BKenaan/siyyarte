/**
 * Creates/resets a dedicated THROWAWAY beta-test account in this project's
 * Firebase Auth, with a ready profile + one demo vehicle so testers land on a
 * working app. For closed-test / login-testing only.
 *
 * Usage (from functions/):
 *   node scripts/create_test_user.js            # create or reset (new password)
 *   node scripts/create_test_user.js delete     # tear the account down
 */
const admin = require("firebase-admin");
const crypto = require("crypto");
const path = require("path");

const serviceAccount = require(path.resolve(__dirname, "..", "service-account.json"));

// Safety guard: refuse to touch any project other than the expected one, so a
// swapped service-account can never mint a test user on the wrong project.
const EXPECTED_PROJECT = "garagi-prod";
if (serviceAccount.project_id !== EXPECTED_PROJECT) {
  console.error(
    `Refusing to run: expected project ${EXPECTED_PROJECT}, got ` +
    `${serviceAccount.project_id}.`);
  process.exit(1);
}

admin.initializeApp({credential: admin.credential.cert(serviceAccount)});
const auth = admin.auth();
const db = admin.firestore();

const EMAIL = "beta-test@bkenaan.dev";
const MODE = process.argv[2];

async function teardown() {
  try {
    const u = await auth.getUserByEmail(EMAIL);
    await db.recursiveDelete(db.collection("users").doc(u.uid));
    await auth.deleteUser(u.uid);
    console.log("Deleted test user and its data.");
  } catch (e) {
    console.log("Nothing to delete (" + (e.code || e.message) + ").");
  }
  process.exit(0);
}

(async () => {
  if (MODE === "delete") return teardown();

  // 96 bits of entropy. A tiny readable prefix keeps it typeable and satisfies
  // any minimal password policy without reducing the random strength.
  const PASSWORD = "St-" + crypto.randomBytes(12).toString("hex");

  let uid;
  try {
    const existing = await auth.getUserByEmail(EMAIL);
    uid = existing.uid;
    // Do NOT force emailVerified on a shared account; login works without it.
    await auth.updateUser(uid, {password: PASSWORD});
    console.log("Reset existing test user (new password).");
  } catch (e) {
    const u = await auth.createUser({
      email: EMAIL,
      password: PASSWORD,
      displayName: "Siyyarte Tester",
    });
    uid = u.uid;
    console.log("Created new test user.");
  }

  // Profile (so login skips the city-setup gate and lands on the dashboard).
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
      make: "Toyota", model: "Corolla", year: 2020, trim: "GLI",
      engineType: "1.8L I4", fuelType: "Petrol", transmission: "CVT",
      odometerKm: 62000, odometerUpdatedAt: now, plateNumber: "DEMO 1234",
      regStatus: "none", createdAt: now,
    }, {merge: true});

  console.log("\n=== SIYYARTE TEST LOGIN ===");
  console.log("Email:    " + EMAIL);
  console.log("Password: " + PASSWORD);
  console.log("(email/password; one login works on all devices)");
  console.log("Tear down when done:  node scripts/create_test_user.js delete");
  process.exit(0);
})().catch((e) => { console.error(e); process.exit(1); });
