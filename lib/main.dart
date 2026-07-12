import 'package:flutter/material.dart';

import 'services/ad_service.dart';
import 'widgets/ad_banner.dart';
import 'screens/unit_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AdService.initialize();
  runApp(const MathApp());
}

class MathApp extends StatelessWidget {
  const MathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '中学数学ドリル',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        // Math-style serif for Latin letters and digits; kanji/kana fall
        // back to the platform's default Japanese font.
        fontFamily: 'STIXTwoText',
      ),
      // A single banner pinned below every screen. Hidden while the keyboard
      // is open so it never floats awkwardly above it during number entry.
      builder: (context, child) {
        final content = child ?? const SizedBox.shrink();
        final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
        return Column(
          children: [
            Expanded(child: content),
            if (!keyboardOpen) const SafeArea(top: false, child: AdBanner()),
          ],
        );
      },
      home: const UnitListScreen(),
    );
  }
}
