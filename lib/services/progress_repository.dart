import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class QuizProgress {
  final int currentIndex;
  final int score;

  QuizProgress({required this.currentIndex, required this.score});
}

/// Persists where the user left off in a unit's drill, and which question
/// ids they have ever answered incorrectly (the review list). Answering a
/// wrong-list question correctly removes it from the list. Keys are scoped
/// per unitId so progress in one unit doesn't clobber another's.
class ProgressRepository {
  final String unitId;

  ProgressRepository(this.unitId);

  String get _progressKey => 'progress_v1_$unitId';
  String get _wrongIdsKey => 'wrong_ids_v1_$unitId';

  Future<void> saveProgress(QuizProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _progressKey,
      jsonEncode({
        'currentIndex': progress.currentIndex,
        'score': progress.score,
      }),
    );
  }

  Future<QuizProgress?> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_progressKey);
    if (raw == null) return null;
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return QuizProgress(
      currentIndex: map['currentIndex'] as int,
      score: map['score'] as int,
    );
  }

  Future<void> clearProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_progressKey);
  }

  Future<Set<String>> loadWrongIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_wrongIdsKey)?.toSet() ?? <String>{};
  }

  Future<void> _saveWrongIds(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_wrongIdsKey, ids.toList());
  }

  Future<void> markWrong(String questionId) async {
    final ids = await loadWrongIds();
    ids.add(questionId);
    await _saveWrongIds(ids);
  }

  Future<void> markCorrect(String questionId) async {
    final ids = await loadWrongIds();
    if (ids.remove(questionId)) {
      await _saveWrongIds(ids);
    }
  }
}
