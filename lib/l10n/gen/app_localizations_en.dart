// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Middle School Math Drills';

  @override
  String get statsTooltip => 'Progress';

  @override
  String todayReviewCount(int count) {
    return 'Today\'s review: $count';
  }

  @override
  String get beginButton => 'Start';

  @override
  String get gradeName1 => 'Grade 7';

  @override
  String get gradeName2 => 'Grade 8';

  @override
  String get gradeName3 => 'Grade 9';

  @override
  String unitTitleFormat(String grade, String title) {
    return '$grade · $title';
  }

  @override
  String loadError(String error) {
    return 'Failed to load question data: $error';
  }

  @override
  String resumeButton(int current, int total) {
    return 'Resume ($current/$total)';
  }

  @override
  String get restartButton => 'Start over';

  @override
  String get randomTenButton => 'Random 10';

  @override
  String reviewDueButton(int count) {
    return 'Review ($count due today)';
  }

  @override
  String reviewWaitingLabel(int count, int days) {
    return '$count in review queue (next review in $days days)';
  }

  @override
  String get answerHint => 'Answer';

  @override
  String get submitButton => 'Submit';

  @override
  String get correctLabel => 'Correct!';

  @override
  String incorrectLabel(String answer) {
    return 'Incorrect (answer: $answer)';
  }

  @override
  String get nextQuestionButton => 'Next question';

  @override
  String get seeResultsButton => 'See results';

  @override
  String get resultTitle => 'Results';

  @override
  String scoreSummary(int score, int total) {
    return '$score / $total correct';
  }

  @override
  String accuracySummary(int percent) {
    return 'Accuracy $percent%';
  }

  @override
  String get backToUnitsButton => 'Back to units';

  @override
  String get overallSection => 'Overall';

  @override
  String get answeredStat => 'Answered';

  @override
  String get accuracyStat => 'Accuracy';

  @override
  String get reviewListStat => 'Review list';

  @override
  String get weakPointsSection => 'Weak points';

  @override
  String get noRecords => 'No study records yet — pick a unit and get started!';

  @override
  String unitAnswerLine(int answered, int correct) {
    return '$answered answered / $correct correct';
  }

  @override
  String reviewPendingLine(int count) {
    return '$count to review';
  }

  @override
  String weakCountLabel(int count) {
    return '$count';
  }

  @override
  String get languageTitle => 'Language';

  @override
  String get systemDefault => 'Follow device setting';
}
