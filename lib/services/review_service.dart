import '../models/question.dart';
import '../models/unit.dart';
import 'progress_repository.dart';
import 'question_repository.dart';

/// Today's due review questions gathered across every unit, with each
/// question routed back to its own unit's repository for recording.
class TodayReview {
  final List<Question> questions;
  final Map<String, ProgressRepository> repositoryByQuestionId;

  const TodayReview({
    required this.questions,
    required this.repositoryByQuestionId,
  });

  bool get isEmpty => questions.isEmpty;

  Future<void> recordAnswer(Question question, bool correct) async {
    await repositoryByQuestionId[question.id]
        ?.recordAnswer(question.id, correct);
  }
}

class ReviewService {
  final QuestionRepository _questionRepository;

  ReviewService([QuestionRepository? questionRepository])
      : _questionRepository = questionRepository ?? QuestionRepository();

  /// Counts due questions per unit without loading any question files.
  Future<int> countDueQuestions({DateTime? now}) async {
    var count = 0;
    for (final unit in units) {
      final dueIds = await ProgressRepository(unit.id).loadDueIds(now: now);
      count += dueIds.length;
    }
    return count;
  }

  /// Loads the actual due questions of every unit, shuffled for the session.
  Future<TodayReview> loadTodayReview({DateTime? now}) async {
    final questions = <Question>[];
    final repos = <String, ProgressRepository>{};
    for (final unit in units) {
      final repo = ProgressRepository(unit.id);
      var dueIds = await repo.loadDueIds(now: now);
      if (dueIds.isEmpty) continue;
      final unitQuestions =
          await _questionRepository.loadQuestions(unit.assetPath);
      // Heal stale ids left behind by content updates, so the due count
      // can't stay stuck on questions that no longer exist.
      await repo
          .forgetMissingQuestions(unitQuestions.map((q) => q.id).toSet());
      dueIds = await repo.loadDueIds(now: now);
      for (final q in unitQuestions.where((q) => dueIds.contains(q.id))) {
        questions.add(q);
        repos[q.id] = repo;
      }
    }
    questions.shuffle();
    return TodayReview(questions: questions, repositoryByQuestionId: repos);
  }
}
