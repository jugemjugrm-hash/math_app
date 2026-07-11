import 'dart:math';

import 'package:flutter/material.dart';
import '../models/question.dart';
import '../models/unit.dart';
import '../services/progress_repository.dart';
import '../services/question_repository.dart';
import 'quiz_screen.dart';

class StartScreen extends StatefulWidget {
  final Unit unit;

  const StartScreen({super.key, required this.unit});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final _questionRepository = QuestionRepository();
  late final _progressRepository = ProgressRepository(widget.unit.id);
  bool _loading = false;
  bool _initializing = true;
  String? _error;
  QuizProgress? _savedProgress;
  int _dueCount = 0;
  int _scheduledCount = 0;
  int _daysUntilNextReview = 0;
  List<Question>? _questions;

  @override
  void initState() {
    super.initState();
    _loadSavedState();
  }

  Future<void> _loadSavedState() async {
    setState(() => _initializing = true);
    try {
      final questions = _questions ??
          await _questionRepository.loadQuestions(widget.unit.assetPath);
      // Heal the review list if a content update removed question ids.
      await _progressRepository
          .forgetMissingQuestions(questions.map((q) => q.id).toSet());
      final progress = await _progressRepository.loadProgress();
      final now = DateTime.now();
      final dueIds = await _progressRepository.loadDueIds(now: now);
      final schedule = await _progressRepository.loadSchedule();
      var daysUntilNext = 0;
      if (dueIds.isEmpty && schedule.isNotEmpty) {
        // Due timestamps are midnights, so compare calendar days.
        final nextDue = DateTime.fromMillisecondsSinceEpoch(
            schedule.values.map((e) => e.dueMs).reduce(min));
        final today = DateTime(now.year, now.month, now.day);
        daysUntilNext = max(1, nextDue.difference(today).inDays);
      }
      if (!mounted) return;
      setState(() {
        _questions = questions;
        _savedProgress = progress;
        _dueCount = dueIds.length;
        _scheduledCount = schedule.length;
        _daysUntilNextReview = daysUntilNext;
        _initializing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '問題データの読み込みに失敗しました: $e';
        _initializing = false;
      });
    }
  }

  Future<void> _recordAnswer(Question question, bool correct) =>
      _progressRepository.recordAnswer(question.id, correct);

  Future<void> _openQuiz(List<Question> questions,
      {ProgressRepository? resumeRepository,
      int initialIndex = 0,
      int initialScore = 0}) async {
    setState(() => _loading = true);
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          questions: questions,
          onAnswer: _recordAnswer,
          resumeRepository: resumeRepository,
          initialIndex: initialIndex,
          initialScore: initialScore,
        ),
      ),
    );
    if (mounted) setState(() => _loading = false);
    _loadSavedState();
  }

  Future<void> _startFresh() async {
    final questions = _questions;
    if (questions == null || _loading) return;
    // Disable the button synchronously so a double tap can't start two
    // quizzes (clearProgress suspends before _openQuiz would disable it).
    setState(() => _loading = true);
    await _progressRepository.clearProgress();
    if (!mounted) return;
    await _openQuiz(questions, resumeRepository: _progressRepository);
  }

  Future<void> _resume() async {
    final questions = _questions;
    final progress = _savedProgress;
    if (questions == null || progress == null) return;
    await _openQuiz(
      questions,
      resumeRepository: _progressRepository,
      initialIndex: progress.currentIndex,
      initialScore: progress.score,
    );
  }

  Future<void> _startRandomTen() async {
    final questions = _questions;
    if (questions == null || questions.isEmpty) return;
    final shuffled = [...questions]..shuffle();
    await _openQuiz(shuffled.take(10).toList());
  }

  Future<void> _startReview() async {
    final questions = _questions;
    if (questions == null) return;
    setState(() => _loading = true);
    final dueIds = await _progressRepository.loadDueIds();
    final reviewQuestions =
        questions.where((q) => dueIds.contains(q.id)).toList();
    if (!mounted || reviewQuestions.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    await _openQuiz(reviewQuestions..shuffle());
  }

  @override
  Widget build(BuildContext context) {
    final total = _questions?.length;
    final fullTitle = '中${widget.unit.grade}「${widget.unit.title}」';
    return Scaffold(
      appBar: AppBar(title: Text(fullTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(fullTitle,
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(widget.unit.description),
              const SizedBox(height: 32),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(_error!,
                      style: const TextStyle(color: Colors.red)),
                ),
              if (!_initializing && _savedProgress != null && total != null) ...[
                ElevatedButton(
                  onPressed: _loading ? null : _resume,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    child: Text(
                        '続きから (${_savedProgress!.currentIndex + 1}/$total)'),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              ElevatedButton(
                onPressed: (_loading || _initializing) ? null : _startFresh,
                child: (_loading || _initializing)
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        child: Text(_savedProgress == null ? 'はじめる' : '最初から'),
                      ),
              ),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed:
                    (_loading || _initializing) ? null : _startRandomTen,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text('ランダム10問'),
                ),
              ),
              if (!_initializing && _dueCount > 0) ...[
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _loading ? null : _startReview,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    child: Text('復習する (今日の分 $_dueCount問)'),
                  ),
                ),
              ] else if (!_initializing && _scheduledCount > 0) ...[
                const SizedBox(height: 16),
                Text(
                  '復習待ち $_scheduledCount問(次の復習まで あと$_daysUntilNextReview日)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
