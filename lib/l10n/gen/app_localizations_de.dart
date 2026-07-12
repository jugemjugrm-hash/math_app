// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Mathe-Drill Mittelstufe';

  @override
  String get statsTooltip => 'Statistik';

  @override
  String todayReviewCount(int count) {
    return 'Heutige Wiederholung: $count';
  }

  @override
  String get beginButton => 'Los';

  @override
  String get gradeName1 => 'Klasse 7';

  @override
  String get gradeName2 => 'Klasse 8';

  @override
  String get gradeName3 => 'Klasse 9';

  @override
  String unitTitleFormat(String grade, String title) {
    return '$grade · $title';
  }

  @override
  String loadError(String error) {
    return 'Aufgaben konnten nicht geladen werden: $error';
  }

  @override
  String resumeButton(int current, int total) {
    return 'Fortsetzen ($current/$total)';
  }

  @override
  String get restartButton => 'Von vorn';

  @override
  String get randomTenButton => '10 zufällige Aufgaben';

  @override
  String reviewDueButton(int count) {
    return 'Wiederholen ($count heute fällig)';
  }

  @override
  String reviewWaitingLabel(int count, int days) {
    return '$count in der Warteschlange (nächste Wiederholung in $days Tagen)';
  }

  @override
  String get answerHint => 'Antwort';

  @override
  String get submitButton => 'OK';

  @override
  String get correctLabel => 'Richtig!';

  @override
  String incorrectLabel(String answer) {
    return 'Falsch (Lösung: $answer)';
  }

  @override
  String get nextQuestionButton => 'Nächste Aufgabe';

  @override
  String get seeResultsButton => 'Ergebnis anzeigen';

  @override
  String get resultTitle => 'Ergebnis';

  @override
  String scoreSummary(int score, int total) {
    return '$score / $total richtig';
  }

  @override
  String accuracySummary(int percent) {
    return 'Trefferquote $percent %';
  }

  @override
  String get backToUnitsButton => 'Zur Themenliste';

  @override
  String get overallSection => 'Gesamt';

  @override
  String get answeredStat => 'Gelöst';

  @override
  String get accuracyStat => 'Trefferquote';

  @override
  String get reviewListStat => 'Wiederholungsliste';

  @override
  String get weakPointsSection => 'Schwachstellen';

  @override
  String get noRecords =>
      'Noch keine Lerneinträge – wähle ein Thema und leg los!';

  @override
  String unitAnswerLine(int answered, int correct) {
    return '$answered gelöst / $correct richtig';
  }

  @override
  String reviewPendingLine(int count) {
    return '$count zur Wiederholung';
  }

  @override
  String weakCountLabel(int count) {
    return '$count';
  }

  @override
  String get languageTitle => 'Sprache';

  @override
  String get systemDefault => 'Geräteeinstellung folgen';
}
