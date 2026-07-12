import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/ad_config.dart';
import '../services/ad_service.dart';

/// A bottom anchored adaptive banner ad. Renders nothing until an ad has
/// actually loaded, so it never leaves an empty gray strip, and nothing at
/// all when ads aren't available (web, tests, load failure).
class AdBanner extends StatefulWidget {
  const AdBanner({super.key});

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ad == null && !kIsWeb && AdService.ready) {
      _loadAd();
    }
  }

  Future<void> _loadAd() async {
    try {
      final width = MediaQuery.of(context).size.width.truncate();
      final size =
          await AdSize.getLargeAnchoredAdaptiveBannerAdSizeWithOrientation(
              Orientation.portrait, width);
      if (size == null || !mounted) return;
      final ad = BannerAd(
        size: size,
        adUnitId: AdConfig.bannerAdUnitId,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (_) {
            if (mounted) setState(() => _loaded = true);
          },
          onAdFailedToLoad: (ad, error) => ad.dispose(),
        ),
      );
      _ad = ad;
      await ad.load();
    } catch (_) {
      // Platform channel unavailable (e.g. tests); render nothing.
    }
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (!_loaded || ad == null) return const SizedBox.shrink();
    return SizedBox(
      width: ad.size.width.toDouble(),
      height: ad.size.height.toDouble(),
      child: AdWidget(ad: ad),
    );
  }
}
