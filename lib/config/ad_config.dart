/// AdMob identifiers.
///
/// While [useTestAds] is true the app shows Google's official sample ads,
/// which are always safe to display and click during development. Before
/// release, set [useTestAds] to false and fill in the real ids issued by
/// your AdMob account (also update the APPLICATION_ID in
/// android/app/src/main/AndroidManifest.xml).
class AdConfig {
  const AdConfig._();

  static const bool useTestAds = true;

  // Google's official test ids (Android).
  static const String _testBannerAndroid =
      'ca-app-pub-3940256099942544/6300978111';

  // TODO: replace with the real AdMob banner unit id before release.
  static const String _realBannerAndroid =
      'ca-app-pub-0000000000000000/0000000000';

  static String get bannerAdUnitId =>
      useTestAds ? _testBannerAndroid : _realBannerAndroid;
}
