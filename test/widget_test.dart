import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:math_app/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Unit list shows grade header and unit tiles',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MathApp());

    expect(find.text('中1'), findsOneWidget);
    expect(find.text('正負の数'), findsOneWidget);
    expect(find.text('平面図形'), findsOneWidget);
    expect(find.text('比例と反比例'), findsOneWidget);
  });

  testWidgets('Tapping a unit navigates to its start screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MathApp());

    await tester.tap(find.text('正負の数'));
    await tester.pumpAndSettle();

    // The start screen shows the full title in both the app bar and the
    // headline, so expect at least one (not exactly one).
    expect(find.text('中1「正負の数」'), findsWidgets);
    expect(find.text('はじめる'), findsOneWidget);
  });
}
