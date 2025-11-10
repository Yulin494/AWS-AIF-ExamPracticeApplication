import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:file_picker/file_picker.dart';
// import 'dart:io';
import '../models/question.dart';
import '../services/database_service.dart';

class ImportQuestionsScreen extends StatefulWidget {
  const ImportQuestionsScreen({super.key});

  @override
  State<ImportQuestionsScreen> createState() => _ImportQuestionsScreenState();
}

class _ImportQuestionsScreenState extends State<ImportQuestionsScreen> {
  bool _isImporting = false;

  Future<void> _pickAndImportFile() async {
    _showMessage('檔案匯入功能暫時停用，請使用範例題目', isError: true);
    // TODO: 等 file_picker 套件更新後再啟用
    /*
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        setState(() => _isImporting = true);
        
        File file = File(result.files.single.path!);
        String content = await file.readAsString();
        
        await _importQuestions(content);
      }
    } catch (e) {
      _showMessage('匯入失敗: $e', isError: true);
    } finally {
      setState(() => _isImporting = false);
    }
    */
  }

  Future<void> _importQuestions(String jsonContent) async {
    try {
      final data = jsonDecode(jsonContent);
      List<dynamic> questionsJson;
      
      if (data is List) {
        questionsJson = data;
      } else if (data is Map && data.containsKey('questions')) {
        questionsJson = data['questions'];
      } else {
        throw Exception('無效的 JSON 格式');
      }

      int successCount = 0;
      int failCount = 0;
      for (int i = 0; i < questionsJson.length; i++) {
        try {
          final questionJson = questionsJson[i];
          final question = Question.fromJson(questionJson);
          await DatabaseService.instance.insertQuestion(question);
          successCount++;
        } catch (e) {
          failCount++;
          print('匯入第 ${i + 1} 題失敗: $e');
          print('問題資料: ${questionsJson[i]}');
        }
      }

      if (mounted) {
        if (failCount > 0) {
          _showMessage('匯入完成：成功 $successCount 題，失敗 $failCount 題', isError: true);
        } else {
          _showMessage('成功匯入 $successCount 道題目');
        }
        Navigator.pop(context);
      }
    } catch (e) {
      _showMessage('解析 JSON 失敗: $e', isError: true);
    }
  }

  Future<void> _importAwsQuestions() async {
    setState(() => _isImporting = true);
    
    try {
      final String jsonContent = await rootBundle.loadString('aws_ai_exam_questions.json');
      await _importQuestions(jsonContent);
    } catch (e) {
      _showMessage('匯入 AWS AI 考題失敗: $e', isError: true);
      setState(() => _isImporting = false);
    }
  }

  Future<void> _importMockExam2() async {
    setState(() => _isImporting = true);
    
    try {
      final String jsonContent = await rootBundle.loadString('mock_exam_2.json');
      await _importQuestions(jsonContent);
    } catch (e) {
      _showMessage('匯入模擬考二失敗: $e', isError: true);
      setState(() => _isImporting = false);
    }
  }

  Future<void> _importMockExam3() async {
    setState(() => _isImporting = true);
    
    try {
      final String jsonContent = await rootBundle.loadString('mock_exam_3.json');
      await _importQuestions(jsonContent);
    } catch (e) {
      _showMessage('匯入模擬考三失敗: $e', isError: true);
      setState(() => _isImporting = false);
    }
  }

  Future<void> _importSampleQuestions() async {
    setState(() => _isImporting = true);
    
    final sampleQuestions = [
      Question(
        questionText: 'Flutter 是由哪家公司開發的？',
        options: ['Apple', 'Google', 'Microsoft', 'Facebook'],
        correctAnswer: 1,
        explanation: 'Flutter 是由 Google 開發的跨平台 UI 框架。',
        category: 'Flutter 基礎',
      ),
      Question(
        questionText: 'Dart 語言中，哪個關鍵字用於宣告常數？',
        options: ['var', 'let', 'const', 'final'],
        correctAnswer: 2,
        explanation: 'const 用於宣告編譯時常數，final 用於宣告執行時常數。',
        category: 'Dart 語法',
      ),
      Question(
        questionText: 'StatefulWidget 和 StatelessWidget 的主要區別是什麼？',
        options: [
          '性能差異',
          '是否可以重建',
          '是否有內部狀態',
          '是否支援動畫'
        ],
        correctAnswer: 2,
        explanation: 'StatefulWidget 可以維護內部狀態，StatelessWidget 則不行。',
        category: 'Flutter Widget',
      ),
      Question(
        questionText: '在 Flutter 中，pubspec.yaml 檔案的主要用途是什麼？',
        options: [
          '定義路由',
          '管理依賴套件',
          '配置主題',
          '定義資料模型'
        ],
        correctAnswer: 1,
        explanation: 'pubspec.yaml 用於管理專案的依賴套件、資源和元資料。',
        category: 'Flutter 專案',
      ),
      Question(
        questionText: '以下哪個不是 Flutter 的佈局 Widget？',
        options: ['Column', 'Row', 'Stack', 'Provider'],
        correctAnswer: 3,
        explanation: 'Provider 是狀態管理套件，不是佈局 Widget。',
        category: 'Flutter Widget',
      ),
    ];

    try {
      for (var question in sampleQuestions) {
        await DatabaseService.instance.insertQuestion(question);
      }
      if (mounted) {
        _showMessage('成功匯入 ${sampleQuestions.length} 道範例題目');
        Navigator.pop(context);
      }
    } catch (e) {
      _showMessage('匯入範例題目失敗: $e', isError: true);
    } finally {
      setState(() => _isImporting = false);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  void _showJsonFormatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('JSON 格式說明'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '題庫 JSON 檔案應該包含題目陣列，每個題目需要以下欄位：',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '''[
  {
    "questionText": "題目內容",
    "options": [
      "選項1",
      "選項2",
      "選項3",
      "選項4"
    ],
    "correctAnswer": 0,
    "explanation": "解析說明（選填）",
    "category": "類別名稱"
  }
]''',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text('• correctAnswer: 正確答案的索引 (0, 1, 2, 3)'),
              const Text('• options: 至少要有 2 個選項'),
              const Text('• explanation: 可選欄位'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('關閉'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('匯入題庫'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showJsonFormatDialog,
          ),
        ],
      ),
      body: _isImporting
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('正在匯入題目...'),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.blue),
                              SizedBox(width: 8),
                              Text(
                                '匯入說明',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text('1. 準備 JSON 格式的題庫檔案'),
                          const Text('2. 點擊「從檔案匯入」選擇檔案'),
                          const Text('3. 系統會自動解析並匯入題目'),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: _showJsonFormatDialog,
                            icon: const Icon(Icons.code),
                            label: const Text('查看 JSON 格式範例'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _pickAndImportFile,
                    icon: const Icon(Icons.upload_file, size: 28),
                    label: const Text(
                      '從檔案匯入',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _importAwsQuestions,
                    icon: const Icon(Icons.cloud, size: 28),
                    label: const Text(
                      '匯入 AWS AI 考題 (65題)',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _importMockExam2,
                    icon: const Icon(Icons.quiz, size: 28),
                    label: const Text(
                      '匯入模擬考二 (70題)',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _importMockExam3,
                    icon: const Icon(Icons.school, size: 28),
                    label: const Text(
                      '匯入模擬考三 (80題)',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _importSampleQuestions,
                    icon: const Icon(Icons.lightbulb, size: 28),
                    label: const Text(
                      '匯入範例題目 (5題)',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('確認刪除'),
                          content: const Text('確定要刪除所有題目嗎？此操作無法復原。'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('取消'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text(
                                '確定',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        await DatabaseService.instance.deleteAllQuestions();
                        if (mounted) {
                          _showMessage('已刪除所有題目');
                        }
                      }
                    },
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('清空題庫'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
