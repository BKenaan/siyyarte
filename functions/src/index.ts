/**
 * Garagi Cloud Functions.
 *
 *  • dailyReminderSweep — scheduled daily; for every user's vehicles it works
 *    out which date-certain reminders are due (time-based services + insurance
 *    + Mécanique inspection) and sends FCM push to the user's devices. This
 *    complements the on-device local notifications: local handles offline /
 *    mileage-based alerts, the server sweep guarantees cross-device delivery
 *    even when the app hasn't been opened.
 *
 *  • setAdminClaim — callable; lets an existing admin grant/revoke the `admin`
 *    custom claim used by firestore.rules and the admin panel. The FIRST admin
 *    is bootstrapped manually (see README).
 *
 * NOTE: mileage-based predictions ("due in 500 km") cannot be computed
 * server-side without knowing future driving, so those stay on-device.
 */

import * as crypto from "crypto";
import {onSchedule} from "firebase-functions/v2/scheduler";
import {onCall, onRequest, HttpsError} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";
import {initializeApp} from "firebase-admin/app";
import {getFirestore, Timestamp, FieldValue} from "firebase-admin/firestore";
import {getMessaging} from "firebase-admin/messaging";
import {getAuth} from "firebase-admin/auth";
import {getStorage} from "firebase-admin/storage";
// Heavy SDKs are type-only here and dynamically imported inside the handlers
// that use them — keeps module load (and deploy-time discovery) fast.
import type Anthropic from "@anthropic-ai/sdk";

initializeApp();
const db = getFirestore();

// --- Factory severe-conditions month intervals (mirror of the Dart engine) ---
const SERVICE_MONTHS: Record<string, number> = {
  oilChange: 6,
  oilFilter: 6,
  airFilter: 24,
  sparkPlugs: 96,
  coolant: 48,
  transmissionFluid: 48,
  timingBelt: 84,
  suspension: 18,
  brakePads: 18,
  tires: 60,
  battery: 36,
  inspection: 12,
};

const MAKE_MONTH_OVERRIDES: Record<string, Record<string, number>> = {
  Toyota: {sparkPlugs: 120, coolant: 60},
  Honda: {sparkPlugs: 96},
  Hyundai: {sparkPlugs: 96},
  Kia: {sparkPlugs: 96},
  BMW: {oilChange: 12, sparkPlugs: 72},
  "Mercedes-Benz": {oilChange: 12},
  Volkswagen: {oilChange: 12},
};

const SERVICE_LABELS: Record<string, string> = {
  oilChange: "Oil change",
  oilFilter: "Oil filter",
  airFilter: "Air filter",
  sparkPlugs: "Spark plugs",
  coolant: "Coolant",
  transmissionFluid: "Transmission fluid",
  timingBelt: "Timing belt/chain",
  suspension: "Suspension check",
  brakePads: "Brake pads",
  tires: "Tires",
  battery: "Battery",
  inspection: "General inspection",
};

const SERVICE_LEAD_DAYS = 14; // notify when a service falls due within 14 days
const EXPIRY_LEAD_DAYS = 30; // notify 30 days before insurance / Mécanique

function addMonths(date: Date, months: number): Date {
  const d = new Date(date);
  d.setMonth(d.getMonth() + months);
  return d;
}

function daysUntil(target: Date, now: Date): number {
  const ms = target.getTime() - now.getTime();
  return Math.floor(ms / (1000 * 60 * 60 * 24));
}

/** Tolerant date parse — our app stores ISO strings, but accept Timestamps. */
function toDate(v: unknown): Date | null {
  if (!v) return null;
  if (v instanceof Timestamp) return v.toDate();
  if (typeof v === "string") {
    const d = new Date(v);
    return isNaN(d.getTime()) ? null : d;
  }
  return null;
}

function monthsFor(make: string, type: string): number {
  return MAKE_MONTH_OVERRIDES[make]?.[type] ?? SERVICE_MONTHS[type];
}

interface DueItem {
  label: string;
  daysRemaining: number;
}

/** Compute the date-certain reminders due for one vehicle. */
function dueRemindersForVehicle(
  vehicle: FirebaseFirestore.DocumentData,
  history: FirebaseFirestore.DocumentData[],
  now: Date
): DueItem[] {
  const items: DueItem[] = [];
  const make = (vehicle.make as string) ?? "";
  const created = toDate(vehicle.createdAt) ?? now;

  // Latest service date per type.
  const lastByType = new Map<string, Date>();
  for (const r of history) {
    const type = r.type as string;
    const date = toDate(r.date);
    if (!date) continue;
    const prev = lastByType.get(type);
    if (!prev || date > prev) lastByType.set(type, date);
  }

  for (const type of Object.keys(SERVICE_MONTHS)) {
    const months = monthsFor(make, type);
    if (!months) continue;
    const base = lastByType.get(type) ?? created;
    const due = addMonths(base, months);
    const remaining = daysUntil(due, now);
    if (remaining <= SERVICE_LEAD_DAYS) {
      items.push({label: SERVICE_LABELS[type] ?? type, daysRemaining: remaining});
    }
  }

  const insurance = toDate(vehicle.insuranceExpiry);
  if (insurance) {
    const remaining = daysUntil(insurance, now);
    if (remaining <= EXPIRY_LEAD_DAYS) {
      items.push({label: "Insurance renewal", daysRemaining: remaining});
    }
  }

  const inspection = toDate(vehicle.inspectionExpiry);
  if (inspection) {
    const remaining = daysUntil(inspection, now);
    if (remaining <= EXPIRY_LEAD_DAYS) {
      items.push({label: "Mécanique inspection", daysRemaining: remaining});
    }
  }

  return items;
}

export const dailyReminderSweep = onSchedule(
  {schedule: "every day 08:00", timeZone: "Asia/Beirut"},
  async () => {
    const now = new Date();
    const usersSnap = await db.collection("users").get();

    for (const userDoc of usersSnap.docs) {
      // Push reminders are a Siyyarte Plus feature (also keeps the sweep's
      // Firestore reads proportional to paying users).
      if (userDoc.get("plus") !== true) continue;
      const tokens: string[] = userDoc.get("fcmTokens") ?? [];
      if (tokens.length === 0) continue;

      const vehiclesSnap = await userDoc.ref.collection("vehicles").get();
      const lines: string[] = [];

      for (const vDoc of vehiclesSnap.docs) {
        const vehicle = vDoc.data();
        const historySnap = await vDoc.ref.collection("history").get();
        const history = historySnap.docs.map((d) => d.data());

        const due = dueRemindersForVehicle(vehicle, history, now);
        if (due.length === 0) continue;

        const name = `${vehicle.year} ${vehicle.make} ${vehicle.model}`;
        const labels = due.map((d) => d.label).join(", ");
        lines.push(`${name}: ${labels}`);
      }

      if (lines.length === 0) continue;

      const message = {
        tokens,
        notification: {
          title: "Siyyarte — upcoming maintenance",
          body: lines.join("\n"),
        },
        data: {type: "reminder_sweep"},
      };

      const res = await getMessaging().sendEachForMulticast(message);

      // Prune tokens that are no longer valid.
      const stale: string[] = [];
      res.responses.forEach((r, i) => {
        const code = r.error?.code;
        if (
          code === "messaging/registration-token-not-registered" ||
          code === "messaging/invalid-registration-token"
        ) {
          stale.push(tokens[i]);
        }
      });
      if (stale.length > 0) {
        await userDoc.ref.update({
          fcmTokens: FieldValue.arrayRemove(...stale),
        });
      }
    }
  }
);

// Full account deletion (Admin SDK) — removes EVERYTHING the user owns, not
// just the Auth record. Cascades: users/{uid} subtree (vehicles + history +
// reminders), the user's vin_registry claims, ocr_usage, the user's Storage
// prefix (invoice/registration photos = PII), then the Auth user last.
// Running server-side also avoids the client "requires-recent-login" problem.
export const deleteAccount = onCall(async (req) => {
  if (!req.auth) {
    throw new HttpsError("unauthenticated", "Sign in required.");
  }
  const uid = req.auth.uid;

  // 1. Release this user's VIN-registry claims (so the cars can be re-added by
  //    a future owner) + drop their OCR usage counter.
  const regSnap =
    await db.collection("vin_registry").where("uid", "==", uid).get();
  let batch = db.batch();
  let n = 0;
  for (const d of regSnap.docs) {
    batch.delete(d.ref);
    if (++n % 400 === 0) { await batch.commit(); batch = db.batch(); }
  }
  batch.delete(db.collection("ocr_usage").doc(uid));
  await batch.commit();

  // 2. Recursively delete the user document tree (vehicles, history, reminders).
  await db.recursiveDelete(db.collection("users").doc(uid));

  // 3. Delete the user's Storage files (photos are PII).
  try {
    await getStorage().bucket().deleteFiles({prefix: `users/${uid}/`});
  } catch (e) {
    console.error("deleteAccount: storage cleanup failed for", uid, e);
  }

  // 4. Finally remove the Auth user.
  await getAuth().deleteUser(uid);
  return {ok: true};
});

export const setAdminClaim = onCall(async (req) => {
  if (req.auth?.token.admin !== true) {
    throw new HttpsError("permission-denied", "Admins only.");
  }
  const uid = req.data?.uid as string | undefined;
  const makeAdmin = Boolean(req.data?.admin);
  if (!uid) throw new HttpsError("invalid-argument", "uid is required.");

  await getAuth().setCustomUserClaims(uid, {admin: makeAdmin});
  return {ok: true, uid, admin: makeAdmin};
});

// --- AI OCR: extract service-record fields or an odometer reading from a photo.
const ANTHROPIC_API_KEY = defineSecret("ANTHROPIC_API_KEY");

const SERVICE_TYPE_IDS = [
  "oilChange", "oilFilter", "airFilter", "sparkPlugs", "brakePads", "tires",
  "battery", "coolant", "transmissionFluid", "timingBelt", "suspension",
  "inspection", "insurance", "registration", "fuel", "parking", "otherExpense",
];

const INVOICE_PROMPT =
  "This is a photo of a car service invoice/receipt from Lebanon (text may be " +
  "Arabic, French, or English). Extract the fields and respond with ONLY a " +
  "JSON object — no prose, no code fences — of exactly this shape:\n" +
  `{"type": <one of ${JSON.stringify(SERVICE_TYPE_IDS)} that best matches the ` +
  "main service, else \"otherExpense\">, " +
  "\"date\": <ISO yyyy-mm-dd or null>, " +
  "\"odometerKm\": <integer km or null>, " +
  "\"garageName\": <string or null>, " +
  "\"amount\": <number, the total, or null>, " +
  "\"currency\": <\"USD\" or \"LBP\" or null>, " +
  "\"notes\": <short string or null>}";

const ODOMETER_PROMPT =
  "This is a photo of a car's odometer/dashboard. Read the total odometer " +
  "(not the trip meter). Respond with ONLY a JSON object: " +
  "{\"odometerKm\": <integer kilometers or null>}";

const REGISTRATION_PROMPT =
  "This is a photo of a Lebanese vehicle registration card (دفتر السيارة). " +
  "IMPORTANT: the card is frequently photographed ROTATED (90°, 180° or 270°) " +
  "or skewed — mentally rotate and read the text in whatever orientation it " +
  "appears. It may be either face:\n\n" +
  "FRONT (header 'الجمهورية اللبنانية / REPUBLIC OF LEBANON', 'Vehicle " +
  "Registration Card / Carte d'Immatriculation'): has the PLATE number " +
  "(a letter + digits, e.g. 'Y 345555'), the owner/holder NAME, and " +
  "registration dates. Make/model/VIN are NOT on the front.\n\n" +
  "BACK (header 'أوصاف المركبة الآليّة' = vehicle specifications): a two-column " +
  "table, Arabic labels on the RIGHT, values on the LEFT (values often in " +
  "Latin capitals). Label → meaning:\n" +
  "- الماركة → make (e.g. TOYOTA, MERCEDES, LEXUS)\n" +
  "- تاريخ الصنع / سنة الصنع → manufacture YEAR (e.g. 2015)\n" +
  "- طرازها / الطراز → model (e.g. LAND CRUISER PRADO, GLE 400, LX 570)\n" +
  "- نوعها / شكلها → body type (SEDAN, مقفلة=saloon) — not needed\n" +
  "- رقم المحرّك → ENGINE number (e.g. 09020721, 1GR-B060551) — this is NOT " +
  "the VIN, never return it as vin\n" +
  "- رقم الهيكل (also called رقم الشاسيه) → CHASSIS number = the VIN: a " +
  "17-character alphanumeric code (e.g. WDC2923561A116639, JTEBU9FJ3FK083126, " +
  "JTJHY00W6A4036590)\n" +
  "- قوة المحرّك line shows fuel: بنزين=Petrol, مازوت/ديزل=Diesel\n\n" +
  "CRITICAL RULES:\n" +
  "1. vin = the value next to رقم الهيكل / رقم الشاسيه ONLY. It is 17 chars " +
  "long. If the string you picked is shorter or sits next to رقم المحرّك, it's " +
  "the engine number — do NOT use it as the VIN.\n" +
  "2. Transcribe the VIN EXACTLY, character by character (distinguish O vs 0, " +
  "I vs 1, S vs 5, B vs 8). No spaces. Uppercase.\n" +
  "3. Keep make/model in their printed Latin spelling.\n" +
  "4. If a field is not on this face or is unreadable, return null — never " +
  "guess.\n\n" +
  "Respond with ONLY a JSON object — no prose, no code fences:\n" +
  "{\"isRegistrationCard\": <true only if this really is a vehicle " +
  "registration/ownership document, else false>, " +
  "\"holderName\": <owner name as printed, or null>, " +
  "\"vin\": <17-char chassis number, uppercase no spaces, or null>, " +
  "\"plateNumber\": <plate number, or null>, " +
  "\"make\": <make in Latin letters, or null>, " +
  "\"model\": <model in Latin letters, or null>, " +
  "\"year\": <integer manufacture year, or null>, " +
  "\"fuelType\": <\"Petrol\"|\"Diesel\"|null>}";

function parseJsonObject(text: string): Record<string, unknown> {
  const start = text.indexOf("{");
  const end = text.lastIndexOf("}");
  if (start < 0 || end < 0) return {};
  try {
    return JSON.parse(text.slice(start, end + 1));
  } catch {
    return {};
  }
}

const OCR_MAX_IMAGE_B64 = 7_000_000; // ~5 MB image, base64-encoded
// Daily scan quotas — heavy scanning is a Plus perk and the free cap bounds
// the worst-case AI spend per free account to ~a cent a day.
const OCR_DAILY_FREE = 5;
const OCR_DAILY_PLUS = 40;

export const extractFromImage = onCall(
  {secrets: [ANTHROPIC_API_KEY], timeoutSeconds: 60, memory: "512MiB"},
  async (req) => {
    if (!req.auth) {
      throw new HttpsError("unauthenticated", "Sign in required.");
    }
    const imageBase64 = req.data?.imageBase64 as string | undefined;
    const mimeType = (req.data?.mimeType as string) || "image/jpeg";
    const rawMode = req.data?.mode as string;
    const mode = rawMode === "odometer" || rawMode === "registration" ?
      rawMode : "invoice";
    if (!imageBase64) {
      throw new HttpsError("invalid-argument", "imageBase64 is required.");
    }
    if (imageBase64.length > OCR_MAX_IMAGE_B64) {
      throw new HttpsError("invalid-argument", "Image is too large.");
    }

    // Per-user daily quota so a single account cannot run up the AI bill.
    // Plus subscribers get the high tier; `plus` on users/{uid} is written
    // ONLY by the RevenueCat webhook (clients can't set it — see rules).
    const userSnap = await db.collection("users").doc(req.auth.uid).get();
    const isPlus = userSnap.get("plus") === true;
    const limit = isPlus ? OCR_DAILY_PLUS : OCR_DAILY_FREE;

    const usageRef = db.collection("ocr_usage").doc(req.auth.uid);
    const day = new Date().toISOString().slice(0, 10); // UTC day
    const allowed = await db.runTransaction(async (tx) => {
      const snap = await tx.get(usageRef);
      const data = snap.data();
      const count = data && data.day === day ? (data.count as number) : 0;
      if (count >= limit) return false;
      tx.set(usageRef, {day, count: count + 1});
      return true;
    });
    if (!allowed) {
      throw new HttpsError(
        "resource-exhausted",
        isPlus ?
          "Daily scan limit reached. Try again tomorrow." :
          `Daily scan limit reached (${OCR_DAILY_FREE}/day on the free ` +
          "plan). Upgrade to Siyyarte Plus for more, or try again tomorrow.");
    }

    const {default: AnthropicSdk} = await import("@anthropic-ai/sdk");
    const client = new AnthropicSdk({apiKey: ANTHROPIC_API_KEY.value()});
    try {
      const message = await client.messages.create({
        // Invoice/odometer OCR is easy → Haiku (cheap, frequent). The Lebanese
        // registration card is dense Arabic/French small print and is scanned
        // only ONCE per car, so spend on the strongest vision model there.
        model: mode === "registration" ? "claude-opus-4-8" : "claude-haiku-4-5",
        max_tokens: 1024,
        messages: [
          {
            role: "user",
            content: [
              {
                type: "image",
                source: {
                  type: "base64",
                  media_type: mimeType as "image/jpeg" | "image/png",
                  data: imageBase64,
                },
              },
              {
                type: "text",
                text: mode === "odometer" ? ODOMETER_PROMPT :
                  mode === "registration" ? REGISTRATION_PROMPT :
                    INVOICE_PROMPT,
              },
            ],
          },
        ],
      });
      const text = message.content
        .filter((b): b is Anthropic.TextBlock => b.type === "text")
        .map((b) => b.text)
        .join("\n");
      return parseJsonObject(text);
    } catch (e) {
      // Log the detail server-side; return a generic message to the client.
      console.error("extractFromImage failed:", e);
      throw new HttpsError("internal", "OCR failed. Please try again.");
    }
  }
);

// --- VIN ownership transfer: one car ↔ one account ------------------------
// A VIN already claimed by another account cannot simply be re-added. The
// buyer calls requestVinTransfer; the CURRENT owner gets an email with an
// approve/reject link (resolveVinTransfer). On approval the registry entry
// flips to the buyer and the seller's copy is marked transferred-out.

const SMTP_URL = defineSecret("SMTP_URL"); // smtps://user:pass@host:465

const TRANSFER_EXPIRY_MS = 14 * 24 * 60 * 60 * 1000; // 14 days

function normVin(v: unknown): string | null {
  if (typeof v !== "string") return null;
  const vin = v.replace(/\s/g, "").toUpperCase();
  return vin.length >= 11 && vin.length <= 20 ? vin : null;
}

export const requestVinTransfer = onCall(
  {secrets: [SMTP_URL]},
  async (req) => {
    if (!req.auth) throw new HttpsError("unauthenticated", "Sign in required.");
    const vin = normVin(req.data?.vin);
    if (!vin) throw new HttpsError("invalid-argument", "A valid VIN is required.");

    const regSnap = await db.collection("vin_registry").doc(vin).get();
    if (!regSnap.exists) return {status: "free"};
    const ownerUid = regSnap.get("uid") as string;
    if (ownerUid === req.auth.uid) return {status: "already_yours"};

    // Idempotent: one live request per (vin, requester) — no email spam.
    const pending = await db.collection("vin_transfers")
      .where("vin", "==", vin)
      .where("toUid", "==", req.auth.uid)
      .where("status", "==", "pending")
      .limit(1)
      .get();
    if (!pending.empty) return {status: "requested"};

    const [owner, requester] = await Promise.all([
      getAuth().getUser(ownerUid),
      getAuth().getUser(req.auth.uid),
    ]);
    if (!owner.email) {
      throw new HttpsError(
        "failed-precondition",
        "The current owner has no email on file, so they cannot confirm the " +
        "transfer. Ask them to delete the car from their Siyyarte garage instead.");
    }

    // SMTP not configured yet (placeholder secret) → fail politely instead of
    // crashing mid-flow, and don't record a request no email will announce.
    const smtpUrl = SMTP_URL.value();
    if (!smtpUrl.startsWith("smtp")) {
      throw new HttpsError(
        "failed-precondition",
        "Ownership transfer by email isn't enabled yet. Ask the current " +
        "owner to delete the car from their Siyyarte garage instead.");
    }

    const token = crypto.randomBytes(24).toString("hex");
    await db.collection("vin_transfers").add({
      vin,
      fromUid: ownerUid,
      toUid: req.auth.uid,
      status: "pending",
      token,
      createdAt: FieldValue.serverTimestamp(),
    });

    const project = process.env.GCLOUD_PROJECT;
    const base =
      `https://us-central1-${project}.cloudfunctions.net/resolveVinTransfer`;
    const requesterLabel =
      requester.displayName || requester.email || "A Siyyarte user";

    let fromAddr = "no-reply@siyyarte.app";
    try {
      const u = decodeURIComponent(new URL(smtpUrl).username);
      if (u.includes("@")) fromAddr = u;
    } catch { /* keep default */ }

    const nodemailer = await import("nodemailer");
    await nodemailer.createTransport(smtpUrl).sendMail({
      from: `Siyyarte <${fromAddr}>`,
      replyTo: "Siyyarte Support <support@bkenaan.dev>",
      to: owner.email,
      subject: `Siyyarte — ownership transfer request (VIN ${vin})`,
      text:
        `${requesterLabel} says they bought your car (VIN ${vin}) and wants ` +
        "to move it to their Siyyarte account.\n\n" +
        "Open this link to review and approve or reject the transfer:\n" +
        `${base}?token=${token}\n\n` +
        "Approving moves the car out of your garage. Your service records " +
        "stay in your account for your own reference. This link expires in 14 days.",
    });

    return {status: "requested"};
  }
);

export const resolveVinTransfer = onRequest(async (req, res) => {
  const page = (title: string, body: string) =>
    "<!doctype html><html><head><meta charset=\"utf-8\">" +
    "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">" +
    "<title>Siyyarte</title></head>" +
    "<body style=\"font-family:system-ui,sans-serif;max-width:480px;" +
    "margin:64px auto;padding:0 16px;color:#1c1c1e\">" +
    `<h2 style="margin-bottom:8px">${title}</h2><p>${body}</p>` +
    "<p style=\"color:#8e8e93;font-size:13px;margin-top:32px\">Siyyarte — " +
    "vehicle ownership transfer</p></body></html>";

  // Token comes from the query on the confirmation GET, or the form body on
  // the POST that actually performs the action.
  const isPost = req.method === "POST";
  const token = String((isPost ? req.body?.token : req.query.token) ?? "");
  if (!/^[a-f0-9]{48}$/.test(token)) {
    res.status(400).send(page("Invalid link",
      "This transfer link is malformed. Use the link from the email."));
    return;
  }

  const snap = await db.collection("vin_transfers")
    .where("token", "==", token).limit(1).get();
  if (snap.empty) {
    res.status(404).send(page("Not found",
      "This transfer request does not exist."));
    return;
  }
  const doc = snap.docs[0];
  const t = doc.data();

  if (t.status !== "pending") {
    res.send(page("Already handled",
      `This request was already ${t.status}. Nothing more to do.`));
    return;
  }
  const created = t.createdAt instanceof Timestamp ?
    t.createdAt.toDate() : new Date(0);
  if (Date.now() - created.getTime() > TRANSFER_EXPIRY_MS) {
    await doc.ref.update({status: "expired"});
    res.status(410).send(page("Link expired",
      "This transfer request is older than 14 days. The buyer can send a new one."));
    return;
  }

  // GET = show a confirmation page; the buttons POST the action. This means an
  // email scanner / link-prefetcher that auto-opens the GET cannot approve or
  // reject anything — only an explicit button press (POST) mutates state.
  if (!isPost) {
    const btn = (action: string, label: string, color: string) =>
      "<form method=\"POST\" style=\"display:inline-block;margin:6px 8px 0 0\">" +
      `<input type="hidden" name="token" value="${token}">` +
      `<input type="hidden" name="action" value="${action}">` +
      `<button type="submit" style="background:${color};color:#fff;border:0;` +
      "border-radius:10px;padding:12px 20px;font-size:15px;cursor:pointer\">" +
      `${label}</button></form>`;
    res.send(page("Confirm ownership transfer",
      `Someone says they bought your car (VIN ${t.vin}) and wants to move it ` +
      "to their Siyyarte account. Approving removes it from your garage " +
      "(your service records stay in your account).<br><br>" +
      btn("approve", "Approve transfer", "#0d3573") +
      btn("reject", "Reject", "#b3261e")));
    return;
  }

  const action = String(req.body?.action ?? "");
  if (action !== "approve" && action !== "reject") {
    res.status(400).send(page("Invalid request",
      "Use the buttons on the confirmation page."));
    return;
  }

  if (action === "reject") {
    await doc.ref.update(
      {status: "rejected", resolvedAt: FieldValue.serverTimestamp()});
    res.send(page("Transfer rejected",
      `The car (VIN ${t.vin}) stays in your account. If this request was ` +
      "unexpected, no further action is needed."));
    return;
  }

  // Approve: registry flips to the buyer; the seller's copy leaves their
  // garage but keeps its records.
  const batch = db.batch();
  batch.update(db.collection("vin_registry").doc(t.vin as string), {
    uid: t.toUid,
    vehicleId: null,
    transferredAt: FieldValue.serverTimestamp(),
  });
  const oldVehicles = await db.collection("users").doc(t.fromUid as string)
    .collection("vehicles").where("vin", "==", t.vin).get();
  oldVehicles.docs.forEach((d) => batch.update(d.ref, {transferredOut: true}));
  batch.update(doc.ref,
    {status: "approved", resolvedAt: FieldValue.serverTimestamp()});
  await batch.commit();

  res.send(page("Transfer approved ✓",
    `The car (VIN ${t.vin}) has been released to the buyer's account. ` +
    "It no longer appears in your garage; your service records remain in " +
    "your account for reference."));
});

// --- RevenueCat webhook: mirrors the Plus entitlement into Firestore -------
// RevenueCat calls this on purchase/renewal/expiration events. The app
// identifies users to RevenueCat by their Firebase uid (Purchases.logIn), so
// event.app_user_id IS the uid. users/{uid}.plus is written only here (the
// security rules block clients from touching it), which makes it safe for
// server-side checks like the OCR quota tier.
const REVENUECAT_WEBHOOK_AUTH = defineSecret("REVENUECAT_WEBHOOK_AUTH");

const PLUS_ON = new Set([
  "INITIAL_PURCHASE", "RENEWAL", "UNCANCELLATION", "PRODUCT_CHANGE",
  "SUBSCRIPTION_EXTENDED", "TRANSFER",
]);
const PLUS_OFF = new Set(["EXPIRATION"]);

export const revenuecatWebhook = onRequest(
  {secrets: [REVENUECAT_WEBHOOK_AUTH]},
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).send("POST only");
      return;
    }
    // Constant-time auth check — this header is the only gate protecting the
    // `plus` flag (the highest-value write), so avoid a timing side-channel.
    const provided = req.get("Authorization") ?? "";
    const expected = REVENUECAT_WEBHOOK_AUTH.value();
    const a = Buffer.from(provided);
    const b = Buffer.from(expected);
    if (a.length !== b.length || !crypto.timingSafeEqual(a, b)) {
      res.status(401).send("unauthorized");
      return;
    }
    const event = req.body?.event;
    const uid = event?.app_user_id as string | undefined;
    const type = event?.type as string | undefined;
    if (!uid || !type) {
      res.status(400).send("missing event");
      return;
    }
    // Ignore RevenueCat anonymous ids — only Firebase-uid-identified users.
    if (uid.startsWith("$RCAnonymousID:")) {
      res.status(200).send("anonymous ignored");
      return;
    }
    if (PLUS_ON.has(type)) {
      await db.collection("users").doc(uid)
        .set({plus: true}, {merge: true});
    } else if (PLUS_OFF.has(type)) {
      await db.collection("users").doc(uid)
        .set({plus: false}, {merge: true});
    }
    res.status(200).send("ok");
  }
);
