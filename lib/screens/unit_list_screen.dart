import 'package:flutter/material.dart';
import '../models/unit.dart';
import '../services/review_service.dart';
import 'dashboard_screen.dart';
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

  Future<void> _startTodayReview() async {
    setState(() => _loadingReview = true);
    final review = await _reviewService.loadTodayReview();
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
    // Preserve declaration order of grades as they first appear.
    final grades = <int>[];
    for (final u in units) {
      if (!grades.contains(u.grade)) grades.add(u.grade);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('放課後の中学数学'),
        actions: [
          IconButton(
            icon: const Icon(Icons.insights),
            tooltip: '成績',
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
                        '今日の復習: $_dueCount問',
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
                          : const Text('始める'),
                    ),
                  ],
                ),
              ),
            ),
          for (final grade in grades) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
              child: Text(
                '中$grade',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            for (final unit in units.where((u) => u.grade == grade))
              Card(
                child: ListTile(
                  title: Text(unit.title),
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
