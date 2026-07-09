import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/question.dart';

class QuestionRepository {
  Future<List<Question>> loadQuestions(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    final data = json.decode(raw) as Map<String, dynamic>;
    final list = data['questions'] as List<dynamic>;
    return list
        .map((e) => Question.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
