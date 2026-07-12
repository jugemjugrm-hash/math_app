// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '初中数学练习';

  @override
  String get statsTooltip => '成绩';

  @override
  String todayReviewCount(int count) {
    return '今日复习：$count题';
  }

  @override
  String get beginButton => '开始';

  @override
  String get gradeName1 => '初一';

  @override
  String get gradeName2 => '初二';

  @override
  String get gradeName3 => '初三';

  @override
  String unitTitleFormat(String grade, String title) {
    return '$grade·$title';
  }

  @override
  String loadError(String error) {
    return '题目数据加载失败：$error';
  }

  @override
  String resumeButton(int current, int total) {
    return '继续（$current/$total）';
  }

  @override
  String get restartButton => '重新开始';

  @override
  String get randomTenButton => '随机10题';

  @override
  String reviewDueButton(int count) {
    return '复习（今日$count题）';
  }

  @override
  String reviewWaitingLabel(int count, int days) {
    return '待复习$count题（距下次复习还有$days天）';
  }

  @override
  String get answerHint => '答案';

  @override
  String get submitButton => '确定';

  @override
  String get correctLabel => '答对了！';

  @override
  String incorrectLabel(String answer) {
    return '答错了（正确答案：$answer）';
  }

  @override
  String get nextQuestionButton => '下一题';

  @override
  String get seeResultsButton => '查看结果';

  @override
  String get resultTitle => '结果';

  @override
  String scoreSummary(int score, int total) {
    return '答对 $score / $total 题';
  }

  @override
  String accuracySummary(int percent) {
    return '正确率 $percent%';
  }

  @override
  String get backToUnitsButton => '返回单元列表';

  @override
  String get overallSection => '总体';

  @override
  String get answeredStat => '已答题数';

  @override
  String get accuracyStat => '正确率';

  @override
  String get reviewListStat => '复习清单';

  @override
  String get weakPointsSection => '薄弱环节';

  @override
  String get noRecords => '还没有学习记录，选择一个单元开始吧！';

  @override
  String unitAnswerLine(int answered, int correct) {
    return '已答$answered题 / 答对$correct题';
  }

  @override
  String reviewPendingLine(int count) {
    return '待复习$count题';
  }

  @override
  String weakCountLabel(int count) {
    return '$count题';
  }

  @override
  String get languageTitle => '语言';

  @override
  String get systemDefault => '跟随系统设置';
}
