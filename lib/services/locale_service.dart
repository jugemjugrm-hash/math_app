import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The languages the app ships UI and (mostly) content for.
const supportedLocales = <Locale>[
  Locale('ja'),
  Locale('en'),
  Locale('de'),
  Locale('pt'),
  Locale('es'),
  Locale('zh'),
];

/// Holds the user's chosen locale and persists it. A null [locale] means
/// "follow the device setting" — MaterialApp then resolves the system
/// locale against [supportedLocales].
class LocaleController extends ChangeNotifier {
  static const _key = 'locale_v1';

  Locale? _locale;
  Locale? get locale => _locale;

  /// Loads the saved preference. Call once at startup before runApp.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code != null && code.isNotEmpty) {
      _locale = Locale(code);
    }
    notifyListeners();
  }

  Future<void> setLocale(Locale? locale) async {
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, locale.languageCode);
    }
  }
}
