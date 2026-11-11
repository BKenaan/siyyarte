# Siyyarte — App Store Connect listing (paste-ready)

Use once the Apple Developer account is approved and you create the app in
App Store Connect (bundle id `com.garagi.garagi`). Apple's fields differ from
Google Play — this is tailored to Apple.

## App information
- **App Name** (max 30 chars): `Siyyarte — Car Care`
- **Subtitle** (max 30 chars): `Service log, reminders & VIN`
- **Primary category:** Utilities  ·  **Secondary:** Productivity
  - (Apple has no "Auto & Vehicles" category; Utilities is the best fit.)
- **Bundle ID:** com.garagi.garagi
- **SKU:** siyyarte-001 (internal id, any unique string)

## Promotional text (max 170 chars — editable anytime without review)
```
Track every service, get reminders for oil, insurance & Mécanique, scan your
registration card, and build a verified Service Booklet that raises resale value.
```

## Keywords (max 100 chars, comma-separated, no spaces)
```
car,maintenance,service,vehicle,reminder,oil,garage,mecanique,VIN,fuel,Lebanon,booklet
```

## Description (reuse the Play copy)
```
Siyyarte (سيّارتي) keeps your car's full story in your pocket — every service,
every receipt, every reminder — built for the way we drive in Lebanon.

TRACK MAINTENANCE THE FACTORY WAY
• Service schedules based on manufacturer (OEM) intervals — oil, filters, plugs,
  coolant, transmission, timing belt and more
• Manufacturer-verified specs for supported cars, cited to the official manual
• Add any car: 60+ makes, or instant specs by VIN

NEVER MISS A DATE
• Smart reminders for services, insurance renewal and the Mécanique inspection
• Works offline

KNOW WHAT YOUR CAR COSTS
• Log services in seconds — or scan the invoice
• Track fuel economy (L/100km) and running costs in USD and LBP

SELL FOR MORE WITH THE SERVICE BOOKLET (PLUS)
• Verified against the registration card (دفتر السيارة)
• Tamper-evident service log; export a branded Service Booklet PDF

Made in Lebanon, for Lebanon. English & Arabic, full RTL support.
Questions? support@bkenaan.dev
```

## URLs
- Support URL: `https://garagi-prod.web.app`
- Marketing URL (optional): `https://garagi-prod.web.app`
- Privacy Policy URL: `https://garagi-prod.web.app/privacy.html`

## Age rating
- Answer the questionnaire with all "None" → **4+**.

## App Privacy ("nutrition labels" — mirror the PrivacyInfo.xcprivacy)
- **Data linked to you** (App Functionality): Email, Name, Photos, Other user
  content (vehicles/service records).
- **Data used to track you:** None (unless you enable personalized ads later).
- **Device ID:** Used for Third-Party Advertising (AdMob), not linked, not tracking.

## Sign in with Apple — REQUIRED
Because the app offers Google sign-in, Apple **requires** "Sign in with Apple"
to be offered too (App Store Review Guideline 4.8). The capability + code must
be enabled before submission.

## Screenshots (DIFFERENT from Play — Apple needs exact sizes)
Required iPhone sizes (at least one set; the 6.7" set is reused for others):
- **6.7"** (1290 × 2796) — iPhone 15/16 Pro Max — REQUIRED
- **6.5"** (1242 × 2688) — optional fallback
Provide 2–10 screenshots. Reuse the same scenes as Play (Dashboard, Vehicle
detail with verified specs, Fuel log, Plus paywall) captured on an iPhone
simulator/device at those resolutions.
- App icon is taken from the build (1024×1024 marketing icon also required in
  App Store Connect → use store_assets/icon_512 upscaled to 1024, or regenerate).

## In-app purchase (Plus) — separate from Android
Create the auto-renewing subscription in App Store Connect (e.g. product id
`plus_monthly`), then add the iOS app + product to RevenueCat and put the
`appl_…` public key in `kRevenueCatIosKey`. StoreKit testing first, then submit.

## Submission order
1. Account approved → create app in App Store Connect.
2. First TestFlight build via Codemagic (see IOS_READINESS.md).
3. Fill this listing + privacy + age rating.
4. Add Sign in with Apple, subscription product, screenshots.
5. Submit for review (Apple review is typically 24–48h).
