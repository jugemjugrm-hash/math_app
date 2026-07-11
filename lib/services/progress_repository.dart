import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class QuizProgress {
  final int currentIndex;
  final int score;

  QuizProgress({required this.currentIndex, required this.score});
}

/// Lifetime answer counters for one unit, used by the dashboard.
class UnitStats {
  final int answered;
  final int correct;

  const UnitStats({required this.answered, required this.correct});

  double get accuracy => answered == 0 ? 0 : correct / answered;
}

/// One question's place in the spaced-repetition schedule.
///
/// A wrong answer puts the question at stage 0, due the next day. Each
/// correct answer moves it up a stage and pushes the due date further out
/// (3 -> 7 -> 14 days); the fourth correct answer graduates it off the
/// review list entirely. A wrong answer at any point resets to stage 0.
///
/// Due timestamps are midnight (start of day) so that "due tomorrow" means
/// any time tomorrow — a question missed at 21:00 must show up in the next
/// morning's review, not at 21:00 the next evening.
class SrsEntry {
  final int stage;
  final int dueMs;

  const SrsEntry({required this.stage, required this.dueMs});

  bool isDue(DateTime now) => dueMs <= now.millisecondsSinceEpoch;
}

/// Persists per-unit learning state: where the user left off in the drill,
/// lifetime answer counters, and the spaced-repetition schedule for
/// questions they have answered incorrectly. Keys are scoped per unitId so
/// progress in one unit doesn't clobber another's.
class ProgressRepository {
  final String unitId;

  ProgressRepository(this.unitId);

  static const _graduationStage = 4;
  static const _intervalDaysByStage = [1, 3, 7, 14];

  String get _progressKey => 'progress_v1_$unitId';
  String get _wrongIdsKey => 'wrong_ids_v1_$unitId';
  String get _statsKey => 'stats_v1_$unitId';
  String get _srsKey => 'srs_v1_$unitId';

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
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return QuizProgress(
        currentIndex: map['currentIndex'] as int,
        score: map['score'] as int,
      );
    } catch (_) {
      return null;
    }
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

  Future<UnitStats> loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_statsKey);
    if (raw == null) return const UnitStats(answered: 0, correct: 0);
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return UnitStats(
        answered: map['answered'] as int? ?? 0,
        correct: map['correct'] as int? ?? 0,
      );
    } catch (_) {
      return const UnitStats(answered: 0, correct: 0);
    }
  }

  Future<void> _saveStats(UnitStats stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _statsKey,
      jsonEncode({'answered': stats.answered, 'correct': stats.correct}),
    );
  }

  Future<Map<String, SrsEntry>> loadSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_srsKey);
    if (raw == null) return {};
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return map.map((id, value) {
        final entry = value as Map<String, dynamic>;
        return MapEntry(
          id,
          SrsEntry(stage: entry['stage'] as int, dueMs: entry['due'] as int),
        );
      });
    } catch (_) {
      return {};
    }
  }

  Future<void> _saveSchedule(Map<String, SrsEntry> schedule) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _srsKey,
      jsonEncode(schedule.map(
        (id, e) => MapEntry(id, {'stage': e.stage, 'due': e.dueMs}),
      )),
    );
  }

  /// Midnight at the start of the day [days] days after [from], so due
  /// checks work per calendar day rather than per 24-hour window.
  static int _dueAtStartOfDay(DateTime from, int days) {
    final target = from.add(Duration(days: days));
    return DateTime(target.year, target.month, target.day)
        .millisecondsSinceEpoch;
  }

  /// Records one answered question: updates the lifetime counters, the
  /// wrong-answer review list, and the spaced-repetition schedule.
  ///
  /// [now] exists so tests can fix the clock.
  Future<void> recordAnswer(String questionId, bool correct,
      {DateTime? now}) async {
    final clock = now ?? DateTime.now();

    final stats = await loadStats();
    await _saveStats(UnitStats(
      answered: stats.answered + 1,
      correct: stats.correct + (correct ? 1 : 0),
    ));

    final schedule = await loadSchedule();
    final wrongIds = await loadWrongIds();

    if (!correct) {
      schedule[questionId] = SrsEntry(
        stage: 0,
        dueMs: _dueAtStartOfDay(clock, _intervalDaysByStage[0]),
      );
      wrongIds.add(questionId);
    } else {
      final entry = schedule[questionId];
      if (entry != null) {
        final nextStage = entry.stage + 1;
        if (nextStage >= _graduationStage) {
          schedule.remove(questionId);
          wrongIds.remove(questionId);
        } else {
          schedule[questionId] = SrsEntry(
            stage: nextStage,
            dueMs: _dueAtStartOfDay(clock, _intervalDaysByStage[nextStage]),
          );
        }
      } else {
        // Legacy review-list entry from before the schedule existed:
        // one correct answer clears it, as the old behavior did.
        wrongIds.remove(questionId);
      }
    }

    await _saveSchedule(schedule);
    await _saveWrongIds(wrongIds);
  }

  /// Drops stored ids that no longer exist in the unit's question set
  /// (e.g. after a content update renamed or removed questions), so stale
  /// entries can't inflate review counts forever.
  Future<void> forgetMissingQuestions(Set<String> validIds) async {
    final schedule = await loadSchedule();
    final wrongIds = await loadWrongIds();
    final staleSchedule = schedule.keys.where((id) => !validIds.contains(id));
    final staleWrong = wrongIds.where((id) => !validIds.contains(id));
    if (staleSchedule.isEmpty && staleWrong.isEmpty) return;
    schedule.removeWhere((id, _) => !validIds.contains(id));
    wrongIds.removeWhere((id) => !validIds.contains(id));
    await _saveSchedule(schedule);
    await _saveWrongIds(wrongIds);
  }

  /// Number of questions on the review list (scheduled or legacy).
  Future<int> countReviewQuestions() async {
    final schedule = await loadSchedule();
    final wrongIds = await loadWrongIds();
    return wrongIds.union(schedule.keys.toSet()).length;
  }

  /// Questions whose review is due now, i.e. today's review set.
  Future<Set<String>> loadDueIds({DateTime? now}) async {
    final clock = now ?? DateTime.now();
    final schedule = await loadSchedule();
    final due = schedule.entries
        .where((e) => e.value.isDue(clock))
        .map((e) => e.key)
        .toSet();
    // Legacy wrong ids with no schedule are always considered due.
    final wrongIds = await loadWrongIds();
    final scheduled = schedule.keys.toSet();
    due.addAll(wrongIds.difference(scheduled));
    return due;
  }
}
