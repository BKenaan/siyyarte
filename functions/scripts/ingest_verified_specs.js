/**
 * Ingest the QA-passed verified dataset (data_backend/verified_specs.json) into
 * Firestore collection `verified_specs`. Idempotent: doc ids are deterministic,
 * so re-running overwrites cleanly. Only Verified Grade-A field rows are present
 * in the export (golden rule enforced upstream by the SQL QA gate).
 *
 * Usage (from functions/):  node scripts/ingest_verified_specs.js
 */
const admin = require("firebase-admin");
const fs = require("fs");
const path = require("path");

const key = path.resolve(__dirname, "..", "service-account.json");
admin.initializeApp({credential: admin.credential.cert(require(key))});
const db = admin.firestore();

const DATA = path.resolve(__dirname, "..", "..", "data_backend", "verified_specs.json");
const specs = JSON.parse(fs.readFileSync(DATA, "utf8"));

const slug = (s) => (s || "")
  .toString().toLowerCase().trim()
  .replace(/[^a-z0-9]+/g, "-").replace(/^-+|-+$/g, "");

// Deterministic id: make-model-market-engine-generation (engine/gen may be empty).
function docId(s) {
  return [s.make, s.model, s.market, s.engine_code || "na", s.generation || "na"]
    .map(slug).join("__");
}

(async () => {
  let batch = db.batch();
  let n = 0, written = 0;
  for (const s of specs) {
    const id = docId(s);
    const ref = db.collection("verified_specs").doc(id);
    batch.set(ref, {
      make: s.make,
      model: s.model,
      makeLower: (s.make || "").toLowerCase(),
      modelLower: (s.model || "").toLowerCase(),
      // Cheap equality key for the app's primary query.
      lookupKey: `${(s.make || "").toLowerCase()}|${(s.model || "").toLowerCase()}`,
      market: s.market,
      generation: s.generation || null,
      yearStart: s.year_start || null,
      yearEnd: s.year_end || null,
      modelYear: s.model_year || null,
      engineCode: s.engine_code || null,
      engineName: s.engine_name || null,
      fuelType: s.fuel_type || null,
      drivetrain: s.drivetrain || null,
      betaStatus: s.beta_status || null,
      fluids: s.fluids || [],
      attributes: s.attributes || [],
      maintenance: s.maintenance || [],
      lebanon: s.lebanon || null,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    n++;
    if (n % 400 === 0) { await batch.commit(); batch = db.batch(); }
    written++;
  }
  await batch.commit();
  console.log(`Ingested ${written} verified specs into Firestore 'verified_specs'.`);

  // Also store the market-routing clues as a single config doc.
  const routing = JSON.parse(fs.readFileSync(
    path.resolve(__dirname, "..", "..", "data_backend", "market_routing.json"), "utf8"));
  await db.collection("app_config").doc("market_routing").set({
    clues: routing, updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  console.log(`Stored ${routing.length} market-routing clues in app_config/market_routing.`);
  process.exit(0);
})().catch((e) => { console.error(e); process.exit(1); });
