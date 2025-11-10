import 'package:flutter/material.dart';
import '../services/database_service.dart';
import 'practice_screen.dart';
import 'wrong_questions_screen.dart';
import 'import_questions_screen.dart';
import 'manage_questions_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic> _statistics = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final stats = await DatabaseService.instance.getStatistics();
      setState(() {
        _statistics = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '載入統計資料失敗: $e';
        _isLoading = false;
      });
      print('Error loading statistics: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('證照題庫練習系統'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatistics,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 80,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _loadStatistics,
                          icon: const Icon(Icons.refresh),
                          label: const Text('重試'),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 統計資訊卡片
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '學習統計',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildStatRow(
                            '題庫總數',
                            '${_statistics['totalQuestions'] ?? 0}',
                            Icons.library_books,
                          ),
                          _buildStatRow(
                            '練習次數',
                            '${_statistics['totalPractice'] ?? 0}',
                            Icons.edit_note,
                          ),
                          _buildStatRow(
                            '答對題數',
                            '${_statistics['correctCount'] ?? 0}',
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          _buildStatRow(
                            '答錯題數',
                            '${_statistics['wrongCount'] ?? 0}',
                            Icons.cancel,
                            color: Colors.red,
                          ),
                          _buildStatRow(
                            '正確率',
                            '${(_statistics['accuracy'] ?? 0).toStringAsFixed(1)}%',
                            Icons.trending_up,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // 功能按鈕
                  _buildActionButton(
                    context,
                    '開始練習',
                    Icons.play_circle_filled,
                    Colors.blue,
                    () async {
                      if (_statistics['totalQuestions'] == 0) {
                        _showMessage('請先匯入題庫');
                        return;
                      }
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PracticeScreen(),
                        ),
                      );
                      _loadStatistics();
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    context,
                    '錯題複習',
                    Icons.error_outline,
                    Colors.orange,
                    () async {
                      if (_statistics['wrongCount'] == 0) {
                        _showMessage('目前沒有錯題記錄');
                        return;
                      }
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WrongQuestionsScreen(),
                        ),
                      );
                      _loadStatistics();
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    context,
                    '匯入題庫',
                    Icons.upload_file,
                    Colors.green,
                    () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ImportQuestionsScreen(),
                        ),
                      );
                      _loadStatistics();
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    context,
                    '題庫管理',
                    Icons.manage_search,
                    Colors.purple,
                    () async {
                      if (_statistics['totalQuestions'] == 0) {
                        _showMessage('目前沒有題目可以管理');
                        return;
                      }
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ManageQuestionsScreen(),
                        ),
                      );
                      _loadStatistics();
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    context,
                    '清除練習記錄',
                    Icons.delete_outline,
                    Colors.red,
                    () => _showClearConfirmDialog(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color ?? Colors.grey[700], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 28),
      label: Text(
        label,
        style: const TextStyle(fontSize: 18),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showClearConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認清除'),
        content: const Text('確定要清除所有練習記錄嗎？此操作無法復原。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              await DatabaseService.instance.clearPracticeRecords();
              if (mounted) {
                Navigator.pop(context);
                _showMessage('已清除所有練習記錄');
                _loadStatistics();
              }
            },
            child: const Text('確定', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
