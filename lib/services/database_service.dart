import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/question.dart';
import '../models/practice_record.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('exam_practice.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        questionText TEXT NOT NULL,
        options TEXT NOT NULL,
        correctAnswer INTEGER NOT NULL,
        explanation TEXT,
        category TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE practice_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        questionId INTEGER NOT NULL,
        userAnswer INTEGER NOT NULL,
        isCorrect INTEGER NOT NULL,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (questionId) REFERENCES questions (id)
      )
    ''');
  }

  // 題目相關操作
  Future<int> insertQuestion(Question question) async {
    final db = await database;
    return await db.insert('questions', question.toMap());
  }

  Future<List<Question>> getAllQuestions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('questions');
    return List.generate(maps.length, (i) => Question.fromMap(maps[i]));
  }

  Future<Question?> getQuestionById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'questions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Question.fromMap(maps.first);
  }

  Future<List<Question>> getQuestionsByCategory(String category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'questions',
      where: 'category = ?',
      whereArgs: [category],
    );
    return List.generate(maps.length, (i) => Question.fromMap(maps[i]));
  }

  Future<int> deleteQuestion(int id) async {
    final db = await database;
    // 先刪除相關的練習記錄
    await db.delete(
      'practice_records',
      where: 'questionId = ?',
      whereArgs: [id],
    );
    // 再刪除題目
    return await db.delete(
      'questions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllQuestions() async {
    final db = await database;
    return await db.delete('questions');
  }

  // 練習記錄相關操作
  Future<int> insertPracticeRecord(PracticeRecord record) async {
    final db = await database;
    return await db.insert('practice_records', record.toMap());
  }

  Future<List<PracticeRecord>> getAllPracticeRecords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('practice_records');
    return List.generate(maps.length, (i) => PracticeRecord.fromMap(maps[i]));
  }

  Future<List<PracticeRecord>> getWrongRecords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'practice_records',
      where: 'isCorrect = ?',
      whereArgs: [0],
    );
    return List.generate(maps.length, (i) => PracticeRecord.fromMap(maps[i]));
  }

  Future<List<int>> getWrongQuestionIds() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT DISTINCT questionId 
      FROM practice_records 
      WHERE isCorrect = 0
      ORDER BY timestamp DESC
    ''');
    return maps.map((m) => m['questionId'] as int).toList();
  }

  Future<Map<String, dynamic>> getStatistics() async {
    final db = await database;
    
    final totalQuestionsResult = await db.rawQuery('SELECT COUNT(*) as count FROM questions');
    final totalQuestions = totalQuestionsResult.first['count'] as int;
    
    final totalPracticeResult = await db.rawQuery('SELECT COUNT(*) as count FROM practice_records');
    final totalPractice = totalPracticeResult.first['count'] as int;
    
    final correctResult = await db.rawQuery('SELECT COUNT(*) as count FROM practice_records WHERE isCorrect = 1');
    final correctCount = correctResult.first['count'] as int;
    
    final wrongResult = await db.rawQuery('SELECT COUNT(*) as count FROM practice_records WHERE isCorrect = 0');
    final wrongCount = wrongResult.first['count'] as int;
    
    return {
      'totalQuestions': totalQuestions,
      'totalPractice': totalPractice,
      'correctCount': correctCount,
      'wrongCount': wrongCount,
      'accuracy': totalPractice > 0 ? (correctCount / totalPractice * 100) : 0.0,
    };
  }

  Future<void> clearPracticeRecords() async {
    final db = await database;
    await db.delete('practice_records');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
