/// Real AdMob ad-unit IDs (AdMob console → Apps → Ad units). While empty, the
/// app shows Google's official TEST banners. Debug builds ALWAYS use test
/// banners regardless — clicking real ads in your own app risks an AdMob ban.
///
/// NOTE: the AdMob *App ID* (ca-app-pub-…~…) lives separately in
/// android/app/src/main/AndroidManifest.xml (and iOS Info.plist), not here.
const String kAdMobAndroidBanner = ''; // e.g. ca-app-pub-1234567890123456/1234567890
const String kAdMobIosBanner = '';
