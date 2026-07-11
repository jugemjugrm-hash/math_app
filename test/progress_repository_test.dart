import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:math_app/services/progress_repository.dart';

void main() {
  // Mid-day clock so start-of-day rounding is visible in expectations.
  final base = DateTime(2026, 7, 11, 12);

  int dayMs(int year, int month, int day) =>
      DateTime(year, month, day).millisecondsSinceEpoch;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('wrong answer schedules review for the next calendar day', () async {
    final repo = ProgressRepository('test');
    await repo.recordAnswer('q1', false, now: base);

    final stats = await repo.loadStats();
    expect(stats.answered, 1);
    expect(stats.correct, 0);

    expect(await repo.loadWrongIds(), {'q1'});

    final schedule = await repo.loadSchedule();
    expect(schedule['q1']!.stage, 0);
    // Due at midnight of July 12, not 24 hours after the answer.
    expect(schedule['q1']!.dueMs, dayMs(2026, 7, 12));

    expect(await repo.loadDueIds(now: base), isEmpty);
  });

  test('an evening mistake is due the next morning', () async {
    final repo = ProgressRepository('test');
    await repo.recordAnswer('q1', false, now: DateTime(2026, 7, 11, 21));

    final nextMorning = DateTime(2026, 7, 12, 7);
    expect(await repo.loadDueIds(now: nextMorning), {'q1'});
  });

  test('correct answers walk the 3-7-14 day ladder and then graduate',
      () async {
    final repo = ProgressRepository('test');
    await repo.recordAnswer('q1', false, now: base);

    var when = base.add(const Duration(days: 1)); // July 12, 12:00
    await repo.recordAnswer('q1', true, now: when);
    var schedule = await repo.loadSchedule();
    expect(schedule['q1']!.stage, 1);
    expect(schedule['q1']!.dueMs, dayMs(2026, 7, 15));

    when = when.add(const Duration(days: 3)); // July 15, 12:00
    await repo.recordAnswer('q1', true, now: when);
    schedule = await repo.loadSchedule();
    expect(schedule['q1']!.stage, 2);
    expect(schedule['q1']!.dueMs, dayMs(2026, 7, 22));

    when = when.add(const Duration(days: 7)); // July 22, 12:00
    await repo.recordAnswer('q1', true, now: when);
    schedule = await repo.loadSchedule();
    expect(schedule['q1']!.stage, 3);
    expect(schedule['q1']!.dueMs, dayMs(2026, 8, 5));

    // Fourth consecutive correct answer graduates the question.
    when = when.add(const Duration(days: 14));
    await repo.recordAnswer('q1', true, now: when);
    expect(await repo.loadSchedule(), isEmpty);
    expect(await repo.loadWrongIds(), isEmpty);
  });

  test('a wrong answer resets the ladder to stage 0', () async {
    final repo = ProgressRepository('test');
    await repo.recordAnswer('q1', false, now: base);
    await repo.recordAnswer('q1', true,
        now: base.add(const Duration(days: 1)));
    await repo.recordAnswer('q1', false,
        now: base.add(const Duration(days: 4)));

    final schedule = await repo.loadSchedule();
    expect(schedule['q1']!.stage, 0);
    expect(await repo.loadWrongIds(), {'q1'});
  });

  test('legacy wrong ids without a schedule are due and clear on success',
      () async {
    SharedPreferences.setMockInitialValues({
      'wrong_ids_v1_test': ['legacy1'],
    });
    final repo = ProgressRepository('test');

    expect(await repo.loadDueIds(now: base), {'legacy1'});
    expect(await repo.countReviewQuestions(), 1);

    await repo.recordAnswer('legacy1', true, now: base);
    expect(await repo.loadWrongIds(), isEmpty);
    expect(await repo.loadDueIds(now: base), isEmpty);
  });

  test('stats accumulate across answers', () async {
    final repo = ProgressRepository('test');
    await repo.recordAnswer('q1', true, now: base);
    await repo.recordAnswer('q2', false, now: base);
    await repo.recordAnswer('q3', true, now: base);

    final stats = await repo.loadStats();
    expect(stats.answered, 3);
    expect(stats.correct, 2);
    expect(stats.accuracy, closeTo(2 / 3, 0.001));
  });

  test('forgetMissingQuestions drops ids removed from the question set',
      () async {
    final repo = ProgressRepository('test');
    await repo.recordAnswer('kept', false, now: base);
    await repo.recordAnswer('removed', false, now: base);

    await repo.forgetMissingQuestions({'kept', 'other'});

    expect((await repo.loadSchedule()).keys, ['kept']);
    expect(await repo.loadWrongIds(), {'kept'});
  });

  test('corrupt stored values fall back to safe defaults', () async {
    SharedPreferences.setMockInitialValues({
      'stats_v1_test': 'not json',
      'srs_v1_test': '{"q1": "broken"}',
      'progress_v1_test': '[]',
    });
    final repo = ProgressRepository('test');

    final stats = await repo.loadStats();
    expect(stats.answered, 0);
    expect(await repo.loadSchedule(), isEmpty);
    expect(await repo.loadProgress(), isNull);

    // Recording still works after corruption.
    await repo.recordAnswer('q1', false, now: base);
    expect((await repo.loadSchedule())['q1']!.stage, 0);
  });
}
