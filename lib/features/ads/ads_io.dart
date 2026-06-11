import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

Future<void> initAds() async {
  try {
    await MobileAds.instance.initialize();
  } catch (_) {}
}

/// Google's official TEST banner ad units — show real test ads without an
/// AdMob account. Replace with your own unit IDs (and the App ID in the
/// Android manifest / iOS Info.plist) before release.
const _androidTestBanner = 'ca-app-pub-3940256099942544/6300978111';
const _iosTestBanner = 'ca-app-pub-3940256099942544/2934735716';

/// An adaptive banner shown to free users. Renders nothing until the ad loads
/// (and nothing at all on platforms without ads).
class AdBanner extends StatefulWidget {
  const AdBanner({super.key});

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final ad = BannerAd(
      adUnitId: Platform.isIOS ? _iosTestBanner : _androidTestBanner,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, _) => ad.dispose(),
      ),
    );
    _ad = ad;
    ad.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _ad == null) return const SizedBox.shrink();
    return SafeArea(
      top: false,
      child: SizedBox(
        width: _ad!.size.width.toDouble(),
        height: _ad!.size.height.toDouble(),
        child: AdWidget(ad: _ad!),
      ),
    );
  }
}
