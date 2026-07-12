// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Matemática do Fundamental II';

  @override
  String get statsTooltip => 'Desempenho';

  @override
  String todayReviewCount(int count) {
    return 'Revisão de hoje: $count';
  }

  @override
  String get beginButton => 'Começar';

  @override
  String get gradeName1 => '7.º ano';

  @override
  String get gradeName2 => '8.º ano';

  @override
  String get gradeName3 => '9.º ano';

  @override
  String unitTitleFormat(String grade, String title) {
    return '$grade · $title';
  }

  @override
  String loadError(String error) {
    return 'Falha ao carregar as questões: $error';
  }

  @override
  String resumeButton(int current, int total) {
    return 'Continuar ($current/$total)';
  }

  @override
  String get restartButton => 'Recomeçar';

  @override
  String get randomTenButton => '10 aleatórias';

  @override
  String reviewDueButton(int count) {
    return 'Revisar ($count de hoje)';
  }

  @override
  String reviewWaitingLabel(int count, int days) {
    return '$count na fila (próxima revisão em $days dias)';
  }

  @override
  String get answerHint => 'Resposta';

  @override
  String get submitButton => 'OK';

  @override
  String get correctLabel => 'Correto!';

  @override
  String incorrectLabel(String answer) {
    return 'Incorreto (resposta: $answer)';
  }

  @override
  String get nextQuestionButton => 'Próxima questão';

  @override
  String get seeResultsButton => 'Ver resultado';

  @override
  String get resultTitle => 'Resultado';

  @override
  String scoreSummary(int score, int total) {
    return '$score / $total corretas';
  }

  @override
  String accuracySummary(int percent) {
    return 'Taxa de acerto: $percent%';
  }

  @override
  String get backToUnitsButton => 'Voltar às unidades';

  @override
  String get overallSection => 'Geral';

  @override
  String get answeredStat => 'Respondidas';

  @override
  String get accuracyStat => 'Acertos';

  @override
  String get reviewListStat => 'Lista de revisão';

  @override
  String get weakPointsSection => 'Pontos fracos';

  @override
  String get noRecords =>
      'Ainda não há registros de estudo. Escolha uma unidade e comece!';

  @override
  String unitAnswerLine(int answered, int correct) {
    return '$answered respondidas / $correct corretas';
  }

  @override
  String reviewPendingLine(int count) {
    return '$count para revisar';
  }

  @override
  String weakCountLabel(int count) {
    return '$count';
  }

  @override
  String get languageTitle => 'Idioma';

  @override
  String get systemDefault => 'Seguir o idioma do aparelho';
}
