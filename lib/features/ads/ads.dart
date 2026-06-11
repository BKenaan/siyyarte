// Platform-selecting export: real AdMob banners on mobile (Android/iOS), and
// no-op stubs everywhere else (web, desktop, tests) so those builds never
// compile the mobile-only `google_mobile_ads` plugin.
export 'ads_stub.dart' if (dart.library.io) 'ads_io.dart';
