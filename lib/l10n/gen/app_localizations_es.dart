// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Matemáticas de Secundaria';

  @override
  String get statsTooltip => 'Progreso';

  @override
  String todayReviewCount(int count) {
    return 'Repaso de hoy: $count';
  }

  @override
  String get beginButton => 'Empezar';

  @override
  String get gradeName1 => 'Grado 7';

  @override
  String get gradeName2 => 'Grado 8';

  @override
  String get gradeName3 => 'Grado 9';

  @override
  String unitTitleFormat(String grade, String title) {
    return '$grade · $title';
  }

  @override
  String loadError(String error) {
    return 'No se pudieron cargar las preguntas: $error';
  }

  @override
  String resumeButton(int current, int total) {
    return 'Continuar ($current/$total)';
  }

  @override
  String get restartButton => 'Desde el principio';

  @override
  String get randomTenButton => '10 al azar';

  @override
  String reviewDueButton(int count) {
    return 'Repasar ($count de hoy)';
  }

  @override
  String reviewWaitingLabel(int count, int days) {
    return '$count en cola (próximo repaso en $days días)';
  }

  @override
  String get answerHint => 'Respuesta';

  @override
  String get submitButton => 'OK';

  @override
  String get correctLabel => '¡Correcto!';

  @override
  String incorrectLabel(String answer) {
    return 'Incorrecto (respuesta: $answer)';
  }

  @override
  String get nextQuestionButton => 'Siguiente pregunta';

  @override
  String get seeResultsButton => 'Ver resultados';

  @override
  String get resultTitle => 'Resultados';

  @override
  String scoreSummary(int score, int total) {
    return '$score / $total correctas';
  }

  @override
  String accuracySummary(int percent) {
    return 'Precisión: $percent%';
  }

  @override
  String get backToUnitsButton => 'Volver a las unidades';

  @override
  String get overallSection => 'General';

  @override
  String get answeredStat => 'Respondidas';

  @override
  String get accuracyStat => 'Precisión';

  @override
  String get reviewListStat => 'Lista de repaso';

  @override
  String get weakPointsSection => 'Puntos débiles';

  @override
  String get noRecords =>
      'Aún no hay registros de estudio. ¡Elige una unidad y empieza!';

  @override
  String unitAnswerLine(int answered, int correct) {
    return '$answered respondidas / $correct correctas';
  }

  @override
  String reviewPendingLine(int count) {
    return '$count por repasar';
  }

  @override
  String weakCountLabel(int count) {
    return '$count';
  }

  @override
  String get languageTitle => 'Idioma';

  @override
  String get systemDefault => 'Usar el idioma del dispositivo';
}
