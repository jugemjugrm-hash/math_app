import 'package:flutter/material.dart';
import '../models/unit.dart';
import '../services/progress_repository.dart';
import '../services/question_repository.dart';

class _UnitReport {
  final Unit unit;
  final UnitStats stats;
  final int scheduledCount;

  const _UnitReport({
    required this.unit,
    required this.stats,
    required this.scheduledCount,
  });
}

class _WeakSubunit {
  final Unit unit;
  final String subunit;
  final int wrongCount;

  const _WeakSubunit({
    required this.unit,
    required this.subunit,
    required this.wrongCount,
  });
}

/// 成績ダッシュボード: 単元ごとの正答率と、いま復習リストに残っている
/// 問題から見えてくる苦手分野を表示する。
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _questionRepository = QuestionRepository();
  bool _loading = true;
  List<_UnitReport> _reports = [];
  List<_WeakSubunit> _weakSubunits = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final reports = <_UnitReport>[];
    final weak = <_WeakSubunit>[];

    for (final unit in units) {
      final repo = ProgressRepository(unit.id);
      final stats = await repo.loadStats();
      final wrongIds = await repo.loadWrongIds();
      reports.add(_UnitReport(
        unit: unit,
        stats: stats,
        // Union of scheduled and legacy wrong-list ids, so the dashboard
        // agrees with the home screen's due counts for migrated data.
        scheduledCount: await repo.countReviewQuestions(),
      ));

      // Group this unit's review-list questions by subunit to surface
      // where the mistakes concentrate.
      if (wrongIds.isNotEmpty) {
        final questions =
            await _questionRepository.loadQuestions(unit.assetPath);
        final counts = <String, int>{};
        for (final q in questions.where((q) => wrongIds.contains(q.id))) {
          counts[q.subunit] = (counts[q.subunit] ?? 0) + 1;
        }
        counts.forEach((subunit, count) {
          weak.add(_WeakSubunit(
              unit: unit, subunit: subunit, wrongCount: count));
        });
      }
    }

    weak.sort((a, b) => b.wrongCount.compareTo(a.wrongCount));
    if (!mounted) return;
    setState(() {
      _reports = reports;
      _weakSubunits = weak.take(3).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('成績')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final started = _reports.where((r) => r.stats.answered > 0).toList();
    final totalAnswered =
        started.fold(0, (sum, r) => sum + r.stats.answered);
    final totalCorrect = started.fold(0, (sum, r) => sum + r.stats.correct);
    final totalScheduled =
        _reports.fold(0, (sum, r) => sum + r.scheduledCount);
    final overallPercent = totalAnswered == 0
        ? 0
        : (totalCorrect / totalAnswered * 100).round();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('全体', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _SummaryNumber(label: '解いた問題', value: '$totalAnswered'),
                    _SummaryNumber(label: '正答率', value: '$overallPercent%'),
                    _SummaryNumber(label: '復習リスト', value: '$totalScheduled'),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (_weakSubunits.isNotEmpty) ...[
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('苦手ポイント',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  for (final w in _weakSubunits)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.flag, size: 18,
                              color: Colors.orange),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '中${w.unit.grade}「${w.unit.title}」 ${w.subunit}',
                            ),
                          ),
                          Text('${w.wrongCount}問',
                              style:
                                  Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 8),
        if (started.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text('まだ学習記録がありません。単元を選んで始めましょう！'),
          )
        else
          for (final r in started) _UnitRow(report: r),
      ],
    );
  }
}

class _SummaryNumber extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryNumber({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineSmall),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _UnitRow extends StatelessWidget {
  final _UnitReport report;

  const _UnitRow({required this.report});

  @override
  Widget build(BuildContext context) {
    final stats = report.stats;
    final percent = (stats.accuracy * 100).round();
    final isWeak = stats.answered >= 10 && stats.accuracy < 0.6;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '中${report.unit.grade}「${report.unit.title}」',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                if (isWeak)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(Icons.priority_high,
                        size: 18, color: Colors.red),
                  ),
                Text('$percent%',
                    style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: stats.accuracy,
                minHeight: 8,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${stats.answered}問解答 / 正解${stats.correct}問'
              '${report.scheduledCount > 0 ? ' / 復習待ち${report.scheduledCount}問' : ''}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
