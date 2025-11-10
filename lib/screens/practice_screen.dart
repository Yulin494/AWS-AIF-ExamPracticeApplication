import 'package:flutter/material.dart';
import '../models/question.dart';
import '../models/practice_record.dart';
import '../services/database_service.dart';

class PracticeScreen extends StatefulWidget {
  final List<int>? questionIds; // 如果提供，只練習這些題目

  const PracticeScreen({super.key, this.questionIds});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  List<Question> _questions = [];
  int _currentIndex = 0;
  int? _selectedAnswer;
  bool _showResult = false;
  bool _isLoading = true;
  int _correctCount = 0;
  int _wrongCount = 0;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoading = true);
    
    List<Question> questions;
    if (widget.questionIds != null) {
      // 載入特定題目
      questions = [];
      for (int id in widget.questionIds!) {
        final question = await DatabaseService.instance.getQuestionById(id);
        if (question != null) {
          questions.add(question);
        }
      }
    } else {
      // 載入所有題目
      questions = await DatabaseService.instance.getAllQuestions();
    }
    
    // 隨機打亂題目順序
    questions.shuffle();
    
    setState(() {
      _questions = questions;
      _isLoading = false;
    });
  }

  void _submitAnswer() {
    if (_selectedAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請選擇一個答案')),
      );
      return;
    }

    final currentQuestion = _questions[_currentIndex];
    final isCorrect = _selectedAnswer == currentQuestion.correctAnswer;

    // 儲存練習記錄
    DatabaseService.instance.insertPracticeRecord(
      PracticeRecord(
        questionId: currentQuestion.id!,
        userAnswer: _selectedAnswer!,
        isCorrect: isCorrect,
        timestamp: DateTime.now(),
      ),
    );

    setState(() {
      _showResult = true;
      if (isCorrect) {
        _correctCount++;
      } else {
        _wrongCount++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _showResult = false;
      });
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('練習完成！'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('總題數：${_questions.length}'),
            Text('答對：$_correctCount 題', style: const TextStyle(color: Colors.green)),
            Text('答錯：$_wrongCount 題', style: const TextStyle(color: Colors.red)),
            Text(
              '正確率：${(_correctCount / _questions.length * 100).toStringAsFixed(1)}%',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 關閉對話框
              Navigator.pop(context); // 返回首頁
            },
            child: const Text('返回首頁'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _restartPractice();
            },
            child: const Text('重新練習'),
          ),
        ],
      ),
    );
  }

  void _restartPractice() {
    setState(() {
      _currentIndex = 0;
      _selectedAnswer = null;
      _showResult = false;
      _correctCount = 0;
      _wrongCount = 0;
      _questions.shuffle();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('題目練習')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('題目練習')),
        body: const Center(child: Text('沒有可練習的題目')),
      );
    }

    final currentQuestion = _questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('題目 ${_currentIndex + 1}/${_questions.length}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 進度指示器
            LinearProgressIndicator(
              value: (_currentIndex + 1) / _questions.length,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 16),
            
            // 統計資訊
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatChip('答對', _correctCount, Colors.green),
                _buildStatChip('答錯', _wrongCount, Colors.red),
                _buildStatChip('類別', currentQuestion.category, Colors.blue),
              ],
            ),
            const SizedBox(height: 24),
            
            // 題目
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  currentQuestion.questionText,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // 選項
            Expanded(
              child: ListView.builder(
                itemCount: currentQuestion.options.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedAnswer == index;
                  final isCorrect = index == currentQuestion.correctAnswer;
                  Color? backgroundColor;
                  
                  if (_showResult) {
                    if (isCorrect) {
                      backgroundColor = Colors.green[100];
                    } else if (isSelected && !isCorrect) {
                      backgroundColor = Colors.red[100];
                    }
                  } else if (isSelected) {
                    backgroundColor = Colors.blue[100];
                  }
                  
                  return Card(
                    color: backgroundColor,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: RadioListTile<int>(
                      title: Text(
                        currentQuestion.options[index],
                        style: const TextStyle(fontSize: 16),
                      ),
                      value: index,
                      groupValue: _selectedAnswer,
                      onChanged: _showResult
                          ? null
                          : (value) {
                              setState(() {
                                _selectedAnswer = value;
                              });
                            },
                      activeColor: _showResult
                          ? (isCorrect ? Colors.green : Colors.red)
                          : Colors.blue,
                    ),
                  );
                },
              ),
            ),
            
            // 解析
            if (_showResult && currentQuestion.explanation != null)
              Card(
                color: Colors.amber[50],
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.lightbulb, color: Colors.orange),
                          SizedBox(width: 8),
                          Text(
                            '解析',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(currentQuestion.explanation!),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 16),
            
            // 按鈕
            ElevatedButton(
              onPressed: _showResult ? _nextQuestion : _submitAnswer,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: _showResult ? Colors.blue : Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text(
                _showResult
                    ? (_currentIndex < _questions.length - 1 ? '下一題' : '完成')
                    : '提交答案',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, dynamic value, Color color) {
    return Chip(
      label: Text('$label: $value'),
      backgroundColor: color.withOpacity(0.2),
      labelStyle: TextStyle(
        color: Color.lerp(color, Colors.black, 0.3),
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
