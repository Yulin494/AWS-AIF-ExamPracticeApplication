class PracticeRecord {
  final int? id;
  final int questionId;
  final int userAnswer;
  final bool isCorrect;
  final DateTime timestamp;

  PracticeRecord({
    this.id,
    required this.questionId,
    required this.userAnswer,
    required this.isCorrect,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'questionId': questionId,
      'userAnswer': userAnswer,
      'isCorrect': isCorrect ? 1 : 0,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory PracticeRecord.fromMap(Map<String, dynamic> map) {
    return PracticeRecord(
      id: map['id'],
      questionId: map['questionId'],
      userAnswer: map['userAnswer'],
      isCorrect: map['isCorrect'] == 1,
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
