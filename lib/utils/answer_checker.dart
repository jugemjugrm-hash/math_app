/// 数値入力の解答判定に使う正規化・比較ロジック。
/// 全角数字・全角マイナスを半角に変換し、前後の空白と先頭の "+" を除去してから比較する。
String normalizeNumericInput(String input) {
  var result = input.trim();

  const fullWidthDigits = '０１２３４５６７８９';
  const halfWidthDigits = '0123456789';
  for (var i = 0; i < fullWidthDigits.length; i++) {
    result = result.replaceAll(fullWidthDigits[i], halfWidthDigits[i]);
  }

  result = result.replaceAll('−', '-'); // 全角マイナス(U+2212)
  result = result.replaceAll('－', '-'); // 全角ハイフンマイナス(U+FF0D)
  result = result.replaceAll(RegExp(r'\s'), '');

  if (result.startsWith('+')) {
    result = result.substring(1);
  }

  return result;
}

bool isNumericAnswerCorrect(String userInput, String correctAnswer) {
  return normalizeNumericInput(userInput) ==
      normalizeNumericInput(correctAnswer);
}

bool isChoiceAnswerCorrect(String selected, String correctAnswer) {
  return selected.trim() == correctAnswer.trim();
}
