class Question {
  final String id;
  final String subunit;
  final String type; // 'numeric' or 'choice'
  final String question;
  final List<String>? choices;
  final String answer;
  final String explanation;
  final int difficulty;
  final List<String> tags;

  Question({
    required this.id,
    required this.subunit,
    required this.type,
    required this.question,
    required this.choices,
    required this.answer,
    required this.explanation,
    required this.difficulty,
    required this.tags,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      subunit: json['subunit'] as String,
      type: json['type'] as String,
      question: json['question'] as String,
      choices: (json['choices'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      answer: json['answer'] as String,
      explanation: json['explanation'] as String,
      difficulty: json['difficulty'] as int,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
    );
  }
}
