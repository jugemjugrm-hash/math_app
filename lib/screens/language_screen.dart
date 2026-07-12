import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';
import '../main.dart';
import '../services/locale_service.dart';

/// Endonyms — each language shown in its own name so a user who opened the
/// app in a language they don't read can still find theirs.
const _languageNames = <String, String>{
  'ja': '日本語',
  'en': 'English',
  'de': 'Deutsch',
  'pt': 'Português',
  'es': 'Español',
  'zh': '简体中文',
};

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = LocaleControllerScope.of(context);
    final current = controller.locale?.languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.languageTitle)),
      body: ListView(
        children: [
          RadioListTile<String?>(
            value: null,
            groupValue: current,
            title: Text(l10n.systemDefault),
            onChanged: (_) => controller.setLocale(null),
          ),
          const Divider(height: 1),
          for (final locale in supportedLocales)
            RadioListTile<String?>(
              value: locale.languageCode,
              groupValue: current,
              title: Text(_languageNames[locale.languageCode] ??
                  locale.languageCode),
              onChanged: (_) => controller.setLocale(locale),
            ),
        ],
      ),
    );
  }
}
