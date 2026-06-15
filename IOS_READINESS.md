# Siyyarte — iOS readiness plan (parallel track)

Goal: ship iOS to TestFlight then the App Store, treated as first-class alongside Android.
Build method: **Codemagic cloud CI** (no Mac to purchase). See `codemagic.yaml`.

Markers: **[DONE]** in place · **[STAGED]** added to repo, verify on first CI build · **[YOU]** needs your account/credential action.

## Staged in the repo (done from Windows)
- [STAGED] `ios/Podfile` — min iOS 15.5 (ML Kit requirement) + deployment-target post_install
- [STAGED] `ios/Runner/PrivacyInfo.xcprivacy` — Apple privacy manifest (data types + required-reason APIs)
- [STAGED] `codemagic.yaml` — cloud iOS (TestFlight) + Android pipelines
- [DONE] `firebase_options.dart` already has the iOS app; Info.plist has camera/photo usage strings + background modes
- [DONE] all plugins used support iOS; `AppDelegate.swift` secure-screen written

## Hard gates (you provide)
1. [YOU] **Apple Developer Program** — $99/yr (developer.apple.com/programs). Required for any iOS build / TestFlight / submission.
2. [YOU] **Codemagic account** connected to this repo + an **App Store Connect API key** integration (named `CODEMAGIC_ASC_KEY` in codemagic.yaml).

## Credentials / console steps (you, with my guidance)
- [YOU] **App Store Connect**: create the app (bundle id `com.garagi.garagi`).
- [YOU] **GoogleService-Info.plist**: Firebase console → iOS app → download → add to `ios/Runner/` and the Xcode target. Needed for native Firebase + Google Sign-In.
- [YOU] **Google Sign-In URL scheme**: the iOS OAuth `REVERSED_CLIENT_ID` (from that plist) goes into Info.plist `CFBundleURLTypes`.
- [YOU] **Sign in with Apple**: enable the capability in the Apple dev portal + Xcode (REQUIRED by Apple because we offer Google sign-in).
- [YOU] **Push (APNs)**: create an APNs auth key in the Apple dev portal, upload to Firebase Cloud Messaging; enable Push Notifications capability.
- [YOU] **RevenueCat iOS**: create the iOS app in App Store Connect + RevenueCat, the auto-renewing subscription products, and the `appl_` public SDK key → set `kRevenueCatIosKey`.
- [YOU] **AdMob iOS**: create an iOS app + ad unit in AdMob → set `GADApplicationIdentifier` in Info.plist (currently Google's TEST id) and `kAdMobIosBanner`.

## Things I do once those exist (from Windows)
- Wire `kRevenueCatIosKey` and `kAdMobIosBanner` values in code.
- Add the Google `CFBundleURLTypes` block to Info.plist from the plist's reversed client id.
- Add `Runner.entitlements` (Apple sign-in + aps-environment) — staged to land with the Xcode capability step so signing doesn't break.
- Iterate on the first Codemagic build log (pod versions, deployment target, signing) until green.

## Xcode-only steps (run on Codemagic's macOS / via its UI)
- Add `PrivacyInfo.xcprivacy` to the Runner target's "Copy Bundle Resources".
- Enable capabilities: Sign in with Apple, Push Notifications (in-app purchase is automatic).

## Honest caveats
- None of the iOS config has been compiled yet — Windows can't run `pod install`/Xcode. The first Codemagic build will surface real issues (pod versions, deployment targets, signing); we iterate there. Treat every [STAGED] item as not-yet-verified.
- iOS monetization is a *separate* setup from Android (App Store Connect products + RevenueCat iOS), not a toggle.

## Suggested order
1. Apple Developer enrollment (gates everything; ~24–48h to approve).
2. Codemagic + ASC API key + create the app → first **unsigned** build to shake out pods.
3. GoogleService-Info.plist + URL scheme + capabilities → first signed TestFlight build.
4. RevenueCat iOS + AdMob iOS → monetization parity.
5. App Store listing (reuse the Android copy/assets) → submit.
