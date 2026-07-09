import 'package:flutter/material.dart';
import '../services/progress_repository.dart';
import '../services/question_repository.dart';
import 'quiz_screen.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final _questionRepository = QuestionRepository();
  final _progressRepository = ProgressRepository();
  bool _loading = false;
  bool _initializing = true;
  String? _error;
  QuizProgress? _savedProgress;
  int _wrongCount = 0;

  @override
  void initState() {
    super.initState();
    _loadSavedState();
  }

  Future<void> _loadSavedState() async {
    final progress = await _progressRepository.loadProgress();
    final wrongIds = await _progressRepository.loadWrongIds();
    if (!mounted) return;
    setState(() {
      _savedProgress = progress;
      _wrongCount = wrongIds.length;
      _initializing = false;
    });
  }

  Future<void> _startFresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final questions = await _questionRepository.loadGrade1Seifu();
      await _progressRepository.clearProgress();
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => QuizScreen(questions: questions, saveResumeState: true),
        ),
      );
      _loadSavedState();
    } catch (e) {
      setState(() => _error = '問題データの読み込みに失敗しました: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resume() async {
    final progress = _savedProgress;
    if (progress == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final questions = await _questionRepository.loadGrade1Seifu();
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => QuizScreen(
            questions: questions,
            initialIndex: progress.currentIndex,
            initialScore: progress.score,
            saveResumeState: true,
          ),
        ),
      );
      _loadSavedState();
    } catch (e) {
      setState(() => _error = '問題データの読み込みに失敗しました: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _startReview() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final wrongIds = await _progressRepository.loadWrongIds();
      final all = await _questionRepository.loadGrade1Seifu();
      final reviewQuestions =
          all.where((q) => wrongIds.contains(q.id)).toList();
      if (!mounted) return;
      if (reviewQuestions.isEmpty) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => QuizScreen(questions: reviewQuestions),
        ),
      );
      _loadSavedState();
    } catch (e) {
      setState(() => _error = '問題データの読み込みに失敗しました: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('中学数学 ドリル')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('中1「正負の数」',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              const Text('全30問(符号・大小比較・四則混合)'),
              const SizedBox(height: 32),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(_error!,
                      style: const TextStyle(color: Colors.red)),
                ),
              if (!_initializing && _savedProgress != null) ...[
                ElevatedButton(
                  onPressed: _loading ? null : _resume,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    child: Text(
                        '続きから (${_savedProgress!.currentIndex + 1}/30)'),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              ElevatedButton(
                onPressed: _loading ? null : _startFresh,
                child: _loading
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
