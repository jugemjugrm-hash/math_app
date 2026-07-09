import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/progress_repository.dart';
import '../utils/answer_checker.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final List<Question> questions;
  final ProgressRepository progressRepository;
  final int initialIndex;
  final int initialScore;

  /// Whether to persist resume state (currentIndex/score) as the user
  /// progresses. Review sessions (a filtered subset of wrong questions)
  /// don't need a resume point, only the full drill does.
  final bool saveResumeState;

  const QuizScreen({
    super.key,
    required this.questions,
    required this.progressRepository,
    this.initialIndex = 0,
    this.initialScore = 0,
    this.saveResumeState = false,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final _numericController = TextEditingController();
  late final _progressRepository = widget.progressRepository;
  late int _currentIndex = widget.initialIndex;
  late int _score = widget.initialScore;
  bool _answered = false;
  bool _isCorrect = false;
  String? _selectedChoice;

  Question get _current => widget.questions[_currentIndex];

  void _submitNumeric() {
    if (_answered) return;
    final correct =
        isNumericAnswerCorrect(_numericController.text, _current.answer);
    _applyResult(correct);
  }

  void _submitChoice(String choice) {
    if (_answered) return;
    setState(() => _selectedChoice = choice);
    final correct = isChoiceAnswerCorrect(choice, _current.answer);
    _applyResult(correct);
  }

  void _applyResult(bool correct) {
    setState(() {
      _answered = true;
      _isCorrect = correct;
      if (correct) _score++;
    });
    if (correct) {
      _progressRepository.markCorrect(_current.id);
    } else {
      _progressRepository.markWrong(_current.id);
    }
  }

  void _goNext() {
    if (_currentIndex + 1 >= widget.questions.length) {
      if (widget.saveResumeState) {
        _progressRepository.clearProgress();
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            score: _score,
            total: widget.questions.length,
          ),
        ),
      );
      return;
    }
    setState(() {
      _currentIndex++;
      _answered = false;
      _isCorrect = false;
      _selectedChoice = null;
      _numericController.clear();
    });
    if (widget.saveResumeState) {
      _progressRepository.saveProgress(
        QuizProgress(currentIndex: _currentIndex, score: _score),
      );
    }
  }

  @override
  void dispose() {
    _numericController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _current;
    return Scaffold(
      appBar: AppBar(
        title: Text('${_currentIndex + 1} / ${widget.questions.length}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(q.subunit, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Text(q.question, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            if (q.type == 'numeric') _buildNumericInput(),
            if (q.type == 'choice') _buildChoices(q),
            const SizedBox(height: 24),
            if (_answered) _buildFeedback(q),
          ],
        ),
      ),
    );
  }

  Widget _buildNumericInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _numericController,
            enabled: !_answered,
            keyboardType:
                const TextInputType.numberWithOptions(signed: true),
            decoration: const InputDecoration(
              labelText: '答え',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _submitNumeric(),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _answered ? null : _submitNumeric,
          child: const Text('決定'),
        ),
      ],
    );
  }

  Widget _buildChoices(Question q) {
    return Column(
      children: q.choices!.map((choice) {
        final isSelected = _selectedChoice == choice;
        Color? color;
        if (_answered && isSelected) {
          color = _isCorrect ? Colors.green.shade100 : Colors.red.shade100;
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              alignment: Alignment.centerLeft,
            ),
            onPressed: _answered ? null : () => _submitChoice(choice),
            child: Text(choice),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFeedback(Question q) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isCorrect ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _isCorrect ? Colors.green : Colors.red,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _isCorrect ? '正解！' : '不正解(正解: ${q.answer})',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _isCorrect ? Colors.green.shade800 : Colors.red.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(q.explanation),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _goNext,
            child: Text(_currentIndex + 1 >= widget.questions.length
                ? '結果を見る'
                : '次の問題へ'),
          ),
        ],
      ),
    );
  }
}
