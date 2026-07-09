import 'package:flutter_test/flutter_test.dart';
import 'package:math_app/utils/answer_checker.dart';

void main() {
  group('normalizeNumericInput', () {
    test('trims whitespace', () {
      expect(normalizeNumericInput('  12 '), '12');
    });

    test('converts full-width digits to half-width', () {
      expect(normalizeNumericInput('１２'), '12');
    });

    test('converts full-width minus signs to half-width', () {
      expect(normalizeNumericInput('−５'), '-5');
      expect(normalizeNumericInput('－５'), '-5');
    });

    test('strips a leading plus sign', () {
      expect(normalizeNumericInput('+7'), '7');
    });
  });

  group('isNumericAnswerCorrect', () {
    test('matches equivalent numeric strings', () {
      expect(isNumericAnswerCorrect(' -12 ', '-12'), isTrue);
      expect(isNumericAnswerCorrect('－１２', '-12'), isTrue);
      expect(isNumericAnswerCorrect('+8', '8'), isTrue);
    });

    test('rejects incorrect answers', () {
      expect(isNumericAnswerCorrect('5', '-5'), isFalse);
      expect(isNumericAnswerCorrect('', '0'), isFalse);
    });
  });

  group('isChoiceAnswerCorrect', () {
    test('matches exact choice text', () {
      expect(isChoiceAnswerCorrect('7', '7'), isTrue);
    });

    test('rejects a different choice', () {
      expect(isChoiceAnswerCorrect('-7', '7'), isFalse);
    });
  });
}
