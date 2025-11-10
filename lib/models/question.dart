class Question {
  final int? id;
  final String questionText;
  final List<String> options;
  final int correctAnswer; // 正確答案的索引 (0, 1, 2, 3)
  final String? explanation;
  final String category;

  Question({
    this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    this.explanation,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'questionText': questionText,
      'options': options.join('|||'), // 使用分隔符儲存選項
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'category': category,
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'],
      questionText: map['questionText'],
      options: (map['options'] as String).split('|||'),
      correctAnswer: map['correctAnswer'],
      explanation: map['explanation'],
      category: map['category'],
    );
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    // 處理 correctAnswer 可能是數字或陣列的情況
    int correctAnswerValue;
    if (json['correctAnswer'] is List) {
      correctAnswerValue = (json['correctAnswer'] as List).first;
    } else {
      correctAnswerValue = json['correctAnswer'];
    }
    
    return Question(
      questionText: json['questionText'],
      options: List<String>.from(json['options']),
      correctAnswer: correctAnswerValue,
      explanation: json['explanation'],
      category: json['category'] ?? '未分類',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionText': questionText,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'category': category,
    };
  }
}
