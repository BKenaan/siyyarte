/// RevenueCat configuration. Fill these with the public SDK keys from the
/// RevenueCat dashboard (Project settings → API keys → "Public app-specific").
/// While empty, the purchase flow stays in "coming soon" mode (no checkout),
/// and the paywall's debug test-toggle is the only way to flip premium.
const String kRevenueCatAndroidKey = ''; // e.g. "goog_xxxxxxxx"
const String kRevenueCatIosKey = ''; // e.g. "appl_xxxxxxxx"

/// The entitlement identifier configured in RevenueCat that grants Plus.
const String kPlusEntitlementId = 'plus';
