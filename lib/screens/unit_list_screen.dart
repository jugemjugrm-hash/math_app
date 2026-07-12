import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';
import '../models/unit.dart';
import '../services/review_service.dart';
import 'dashboard_screen.dart';
import 'language_screen.dart';
import 'quiz_screen.dart';
import 'start_screen.dart';

class UnitListScreen extends StatefulWidget {
  const UnitListScreen({super.key});

  @override
  State<UnitListScreen> createState() => _UnitListScreenState();
}

class _UnitListScreenState extends State<UnitListScreen> {
  final _reviewService = ReviewService();
  int _dueCount = 0;
  bool _loadingReview = false;

  @override
  void initState() {
    super.initState();
    _refreshDueCount();
  }

  Future<void> _refreshDueCount() async {
    final count = await _reviewService.countDueQuestions();
    if (!mounted) return;
    setState(() => _dueCount = count);
  }

  String _localizedTitle(AppLocalizations l10n, Unit unit) {
    final grade = switch (unit.grade) {
      1 => l10n.gradeName1,
      2 => l10n.gradeName2,
      _ => l10n.gradeName3,
    };
    return l10n.unitTitleFormat(grade, unit.title);
  }

  Future<void> _startTodayReview() async {
    final languageCode = Localizations.localeOf(context).languageCode;
    setState(() => _loadingReview = true);
    final review =
        await _reviewService.loadTodayReview(languageCode: languageCode);
    if (!mounted) return;
    setState(() => _loadingReview = false);
    if (review.isEmpty) {
      _refreshDueCount();
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          questions: review.questions,
          onAnswer: review.recordAnswer,
        ),
      ),
    );
    _refreshDueCount();
  }

  Future<void> _openUnit(Unit unit) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => StartScreen(unit: unit)),
    );
    _refreshDueCount();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Preserve declaration order of grades as they first appear.
    final grades = <int>[];
    for (final u in units) {
      if (!grades.contains(u.grade)) grades.add(u.grade);
    }

    String gradeHeader(int grade) => switch (grade) {
          1 => l10n.gradeName1,
          2 => l10n.gradeName2,
          _ => l10n.gradeName3,
        };

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.translate),
            tooltip: l10n.languageTitle,
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LanguageScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.insights),
            tooltip: l10n.statsTooltip,
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
              );
              _refreshDueCount();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_dueCount > 0)
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.schedule),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.todayReviewCount(_dueCount),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    FilledButton(
                      onPressed: _loadingReview ? null : _startTodayReview,
                      child: _loadingReview
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.beginButton),
                    ),
                  ],
                ),
              ),
            ),
          for (final grade in grades) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
              child: Text(
                gradeHeader(grade),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            for (final unit in units.where((u) => u.grade == grade))
              Card(
                child: ListTile(
                  title: Text(_localizedTitle(l10n, unit)),
                  subtitle: Text(unit.description),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openUnit(unit),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
