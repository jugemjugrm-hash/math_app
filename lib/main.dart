import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/gen/app_localizations.dart';
import 'services/locale_service.dart';
import 'screens/unit_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final localeController = LocaleController();
  await localeController.load();
  runApp(MathApp(localeController: localeController));
}

class MathApp extends StatelessWidget {
  final LocaleController localeController;

  const MathApp({super.key, required this.localeController});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: localeController,
      builder: (context, _) {
        return MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
            // Math-style serif for Latin letters and digits; kanji/kana fall
            // back to the platform's default Japanese font.
            fontFamily: 'STIXTwoText',
          ),
          locale: localeController.locale,
          supportedLocales: supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: LocaleControllerScope(
            controller: localeController,
            child: const UnitListScreen(),
          ),
        );
      },
    );
  }
}

/// Makes the app's [LocaleController] reachable from any screen (e.g. the
/// language picker) without a third-party state-management package.
class LocaleControllerScope extends InheritedWidget {
  final LocaleController controller;

  const LocaleControllerScope({
    super.key,
    required this.controller,
    required super.child,
  });

  static LocaleController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<LocaleControllerScope>();
    assert(scope != null, 'No LocaleControllerScope found in context');
    return scope!.controller;
  }

  @override
  bool updateShouldNotify(LocaleControllerScope oldWidget) =>
      controller != oldWidget.controller;
}
