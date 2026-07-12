// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => '中学数学 ドリル';

  @override
  String get statsTooltip => '成績';

  @override
  String todayReviewCount(int count) {
    return '今日の復習: $count問';
  }

  @override
  String get beginButton => '始める';

  @override
  String get gradeName1 => '中1';

  @override
  String get gradeName2 => '中2';

  @override
  String get gradeName3 => '中3';

  @override
  String unitTitleFormat(String grade, String title) {
    return '$grade「$title」';
  }

  @override
  String loadError(String error) {
    return '問題データの読み込みに失敗しました: $error';
  }

  @override
  String resumeButton(int current, int total) {
    return '続きから ($current/$total)';
  }

  @override
  String get restartButton => '最初から';

  @override
  String get randomTenButton => 'ランダム10問';

  @override
  String reviewDueButton(int count) {
    return '復習する (今日の分 $count問)';
  }

  @override
  String reviewWaitingLabel(int count, int days) {
    return '復習待ち $count問(次の復習まで あと$days日)';
  }

  @override
  String get answerHint => '答え';

  @override
  String get submitButton => '決定';

  @override
  String get correctLabel => '正解！';

  @override
  String incorrectLabel(String answer) {
    return '不正解(正解: $answer)';
  }

  @override
  String get nextQuestionButton => '次の問題へ';

  @override
  String get seeResultsButton => '結果を見る';

  @override
  String get resultTitle => '結果';

  @override
  String scoreSummary(int score, int total) {
    return '$score / $total 問正解';
  }

  @override
  String accuracySummary(int percent) {
    return '正答率 $percent%';
  }

  @override
  String get backToUnitsButton => '単元選択に戻る';

  @override
  String get overallSection => '全体';

  @override
  String get answeredStat => '解いた問題';

  @override
  String get accuracyStat => '正答率';

  @override
  String get reviewListStat => '復習リスト';

  @override
  String get weakPointsSection => '苦手ポイント';

  @override
  String get noRecords => 'まだ学習記録がありません。単元を選んで始めましょう！';

  @override
  String unitAnswerLine(int answered, int correct) {
    return '$answered問解答 / 正解$correct問';
  }

  @override
  String reviewPendingLine(int count) {
    return '復習待ち$count問';
  }

  @override
  String weakCountLabel(int count) {
    return '$count問';
  }

  @override
  String get languageTitle => '言語';

  @override
  String get systemDefault => '端末の設定に従う';
}
