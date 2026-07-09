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
  int _wrongCount = 0;
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
      final progress = await _progressRepository.loadProgress();
      final wrongIds = await _progressRepository.loadWrongIds();
      if (!mounted) return;
      setState(() {
        _questions = questions;
        _savedProgress = progress;
        _wrongCount = wrongIds.length;
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

  Future<void> _startFresh() async {
    final questions = _questions;
    if (questions == null) return;
    setState(() => _loading = true);
    await _progressRepository.clearProgress();
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          questions: questions,
          progressRepository: _progressRepository,
          saveResumeState: true,
        ),
      ),
    );
    if (mounted) setState(() => _loading = false);
    _loadSavedState();
  }

  Future<void> _resume() async {
    final questions = _questions;
    final progress = _savedProgress;
    if (questions == null || progress == null) return;
    setState(() => _loading = true);
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          questions: questions,
          progressRepository: _progressRepository,
          initialIndex: progress.currentIndex,
          initialScore: progress.score,
          saveResumeState: true,
        ),
      ),
    );
    if (mounted) setState(() => _loading = false);
    _loadSavedState();
  }

  Future<void> _startReview() async {
    final questions = _questions;
    if (questions == null) return;
    setState(() => _loading = true);
    final wrongIds = await _progressRepository.loadWrongIds();
    final reviewQuestions =
        questions.where((q) => wrongIds.contains(q.id)).toList();
    if (!mounted || reviewQuestions.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          questions: reviewQuestions,
          progressRepository: _progressRepository,
        ),
      ),
    );
    if (mounted) setState(() => _loading = false);
    _loadSavedState();
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
              if (!_initializing && _wrongCount > 0) ...[
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _loading ? null : _startReview,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    child: Text('復習する ($_wrongCount問)'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
