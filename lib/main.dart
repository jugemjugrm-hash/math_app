import 'package:flutter/material.dart';
import 'screens/unit_list_screen.dart';

void main() {
  runApp(const MathApp());
}

class MathApp extends StatelessWidget {
  const MathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '放課後の中学数学',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        // Math-style serif for Latin letters and digits; kanji/kana fall
        // back to the platform's default Japanese font.
        fontFamily: 'STIXTwoText',
      ),
      home: const UnitListScreen(),
    );
  }
}
