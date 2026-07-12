import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/question.dart';

/// Localized display metadata for a unit: its name in the current language
/// and how many questions it holds.
class UnitMeta {
  final String name;
  final int questionCount;

  const UnitMeta({required this.name, required this.questionCount});
}

class QuestionRepository {
  /// Resolves the asset path for [assetPath] in [languageCode], returning
  /// null for Japanese (which uses the original path).
  String? _localizedPath(String assetPath, String languageCode) {
    if (languageCode == 'ja') return null;
    return assetPath.replaceFirst(
        'assets/questions/', 'assets/questions/$languageCode/');
  }

  Future<String> _loadRaw(String assetPath, String languageCode) async {
    final localized = _localizedPath(assetPath, languageCode);
    if (localized != null) {
      try {
        return await rootBundle.loadString(localized);
      } catch (_) {
        // Fall through to the Japanese original.
      }
    }
    return rootBundle.loadString(assetPath);
  }

  /// Loads a unit's questions, preferring the translation for
  /// [languageCode] when one is bundled and falling back to the original
  /// Japanese file otherwise (so partially translated languages still work).
  ///
  /// Japanese assets live at `assets/questions/gradeN/x.json`; translations
  /// mirror that tree under `assets/questions/<languageCode>/gradeN/x.json`.
  Future<List<Question>> loadQuestions(String assetPath,
      {String languageCode = 'ja'}) async {
    final raw = await _loadRaw(assetPath, languageCode);
    final data = json.decode(raw) as Map<String, dynamic>;
    final list = data['questions'] as List<dynamic>;
    return list
        .map((e) => Question.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Loads just the localized unit name and question count, for list and
  /// header display, without building full Question objects.
  Future<UnitMeta> loadUnitMeta(String assetPath,
      {String languageCode = 'ja'}) async {
    final raw = await _loadRaw(assetPath, languageCode);
    final data = json.decode(raw) as Map<String, dynamic>;
    final list = data['questions'] as List<dynamic>;
    return UnitMeta(
      name: data['unit'] as String,
      questionCount: list.length,
    );
  }
}
