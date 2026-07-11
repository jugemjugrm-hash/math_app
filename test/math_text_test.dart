import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:math_app/widgets/math_text.dart';

void main() {
  group('parseMathSegments', () {
    test('plain text stays a single segment', () {
      final segments = parseMathSegments('3 + 5 を計算しなさい。');
      expect(segments.length, 1);
      expect(segments.single.isFraction, isFalse);
      expect(segments.single.text, '3 + 5 を計算しなさい。');
    });

    test('lone fraction becomes one fraction segment', () {
      final segments = parseMathSegments('{{1}}/{{6}}');
      expect(segments.length, 1);
      expect(segments.single.isFraction, isTrue);
      expect(segments.single.numerator, '1');
      expect(segments.single.denominator, '6');
    });

    test('mixed text and fractions split in order', () {
      final segments = parseMathSegments('1-{{1}}/{{6}}={{5}}/{{6}}');
      expect(segments.length, 4);
      expect(segments[0].text, '1-');
      expect(segments[1].numerator, '1');
      expect(segments[1].denominator, '6');
      expect(segments[2].text, '=');
      expect(segments[3].numerator, '5');
      expect(segments[3].denominator, '6');
    });

    test('numerator may contain expressions', () {
      final segments = parseMathSegments('x={{-3±√5}}/{{2}}');
      expect(segments.length, 2);
      expect(segments[1].numerator, '-3±√5');
      expect(segments[1].denominator, '2');
    });
  });

  testWidgets('MathText renders numerator and denominator as stacked text',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: MathText('確率は{{5}}/{{36}}です。')),
      ),
    );

    expect(find.text('5'), findsOneWidget);
    expect(find.text('36'), findsOneWidget);

    // The numerator sits above the denominator.
    final numeratorY = tester.getCenter(find.text('5')).dy;
    final denominatorY = tester.getCenter(find.text('36')).dy;
    expect(numeratorY, lessThan(denominatorY));
  });

  testWidgets('MathText without markup renders like plain Text',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: MathText('y=2x+1 のグラフ')),
      ),
    );

    expect(find.text('y=2x+1 のグラフ'), findsOneWidget);
  });
}
