import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Initializes the Mobile Ads SDK once at startup.
///
/// Ads only run on mobile: on web (and in widget tests, which never call
/// [initialize]) [ready] stays false and the banner widget renders nothing,
/// so those environments never touch the platform channel.
class AdService {
  const AdService._();

  static bool ready = false;

  static Future<void> initialize() async {
    if (kIsWeb) return;
    try {
      await MobileAds.instance.initialize();
      ready = true;
    } catch (_) {
      // No ad support on this platform/environment; run without ads.
      ready = false;
    }
  }
}
