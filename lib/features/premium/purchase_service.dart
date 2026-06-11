// Platform-selecting export: the real RevenueCat-backed PurchaseService on
// mobile (Android/iOS), and a no-op stub everywhere else (web, desktop, tests)
// so those builds never compile the mobile-only `purchases_flutter` plugin.
export 'purchase_service_stub.dart'
    if (dart.library.io) 'purchase_service_io.dart';
