import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:math_app/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Start screen shows unit title and start button',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MathApp());

    expect(find.text('中1「正負の数」'), findsOneWidget);
    expect(find.text('はじめる'), findsOneWidget);
  });
}
