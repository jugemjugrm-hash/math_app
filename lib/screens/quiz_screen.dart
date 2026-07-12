import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/progress_repository.dart';
import '../utils/answer_checker.dart';
import '../widgets/math_text.dart';
import '../widgets/scratch_pad.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final List<Question> questions;

  /// Called once per answered question. Handles the review list, the
  /// spaced-repetition schedule, and lifetime counters — kept as a callback
  /// so mixed-unit sessions can route each question to its own unit's
  /// repository.
  final Future<void> Function(Question question, bool correct) onAnswer;

  /// When set, the drill position (currentIndex/score) is persisted here so
  /// the user can resume later. Review and random sessions leave it null.
  final ProgressRepository? resumeRepository;

  final int initialIndex;
  final int initialScore;

  const QuizScreen({
    super.key,
    required this.questions,
    required this.onAnswer,
    this.resumeRepository,
    this.initialIndex = 0,
    this.initialScore = 0,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final _numericController = TextEditingController();
  late int _currentIndex = widget.initialIndex;
  late int _score = widget.initialScore;
  bool _answered = false;
  bool _isCorrect = false;
  String? _selectedChoice;
  List<String>? _shuffledChoices;

  /// Whether the scratch pad is open. Owned here (not by the pad) so the
  /// choice persists across questions even though each question gets a fresh
  /// blank canvas.
  bool _scratchExpanded = true;

  Question get _current => widget.questions[_currentIndex];

  @override
  void initState() {
    super.initState();
    _prepareChoices();
  }

  /// Shuffles the current question's choices so the answer position isn't
  /// memorized between sessions. Shuffled once per question, not per build.
  void _prepareChoices() {
    final choices = _current.choices;
    _shuffledChoices = choices == null ? null : ([...choices]..shuffle());
  }

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
    widget.onAnswer(_current, correct);
  }

  void _goNext() {
    if (_currentIndex + 1 >= widget.questions.length) {
      widget.resumeRepository?.clearProgress();
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
      _prepareChoices();
    });
    widget.resumeRepository?.saveProgress(
      QuizProgress(currentIndex: _currentIndex, score: _score),
    );
  }

  @override
  void dispose() {
    _numericController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _current;
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    return Scaffold(
      appBar: AppBar(
        title: Text('${_currentIndex + 1} / ${widget.questions.length}'),
      ),
      body: Column(
        children: [
          // Question and answer area scrolls independently, so long
          // questions never collide with the pinned scratch pad below.
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MathText(q.subunit,
                      style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  MathText(q.question,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 24),
                  if (q.type == 'numeric') _buildNumericInput(),
                  if (q.type == 'choice') _buildChoices(),
                  const SizedBox(height: 24),
                  if (_answered) _buildFeedback(q),
                ],
              ),
            ),
          ),
          // A fresh blank scratch pad per question (keyed by index).
          ScratchPad(
            key: ValueKey(_currentIndex),
            expanded: _scratchExpanded,
            compact: keyboardOpen,
            onToggle: () =>
                setState(() => _scratchExpanded = !_scratchExpanded),
          ),
        ],
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

  Widget _buildChoices() {
    return Column(
      children: (_shuffledChoices ?? const []).map((choice) {
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
            child: MathText(choice),
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
          MathText(
            _isCorrect ? '正解！' : '不正解(正解: ${q.answer})',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _isCorrect ? Colors.green.shade800 : Colors.red.shade800,
            ),
          ),
          const SizedBox(height: 8),
          MathText(q.explanation),
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
