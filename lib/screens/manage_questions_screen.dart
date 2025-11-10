import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/database_service.dart';

class ManageQuestionsScreen extends StatefulWidget {
  const ManageQuestionsScreen({super.key});

  @override
  State<ManageQuestionsScreen> createState() => _ManageQuestionsScreenState();
}

class _ManageQuestionsScreenState extends State<ManageQuestionsScreen> {
  List<Question> _questions = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedCategory = '全部';
  Set<int> _selectedQuestionIds = {};
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final questions = await DatabaseService.instance.getAllQuestions();
      if (mounted) {
        setState(() {
          _questions = questions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '載入題目失敗: $e';
          _isLoading = false;
        });
      }
    }
  }

  List<String> get _categories {
    final categories = _questions.map((q) => q.category).toSet().toList();
    categories.sort();
    return ['全部', ...categories];
  }

  List<Question> get _filteredQuestions {
    if (_selectedCategory == '全部') {
      return _questions;
    }
    return _questions.where((q) => q.category == _selectedCategory).toList();
  }

  bool get _isAllSelected {
    if (_filteredQuestions.isEmpty) return false;
    final filteredIds = _filteredQuestions
        .where((q) => q.id != null)
        .map((q) => q.id!)
        .toSet();
    return filteredIds.isNotEmpty && filteredIds.every((id) => _selectedQuestionIds.contains(id));
  }

  void _toggleSelectAll() {
    setState(() {
      if (_isAllSelected) {
        // 取消全選：移除當前分類的所有題目
        final filteredIds = _filteredQuestions
            .where((q) => q.id != null)
            .map((q) => q.id!)
            .toSet();
        _selectedQuestionIds.removeAll(filteredIds);
      } else {
        // 全選：添加當前分類的所有題目
        final filteredIds = _filteredQuestions
            .where((q) => q.id != null)
            .map((q) => q.id!)
            .toSet();
        _selectedQuestionIds.addAll(filteredIds);
      }
    });
  }

  Future<void> _deleteQuestion(Question question) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認刪除'),
        content: Text('確定要刪除這道題目嗎？\n\n${question.questionText}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              '刪除',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && question.id != null) {
      try {
        await DatabaseService.instance.deleteQuestion(question.id!);
        _showMessage('題目已刪除');
        _loadQuestions();
      } catch (e) {
        _showMessage('刪除失敗: $e', isError: true);
      }
    }
  }

  Future<void> _deleteSelectedQuestions() async {
    if (_selectedQuestionIds.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認批次刪除'),
        content: Text('確定要刪除選中的 ${_selectedQuestionIds.length} 道題目嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              '刪除',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        for (final id in _selectedQuestionIds) {
          await DatabaseService.instance.deleteQuestion(id);
        }
        _showMessage('已刪除 ${_selectedQuestionIds.length} 道題目');
        setState(() {
          _selectedQuestionIds.clear();
          _isSelectionMode = false;
        });
        _loadQuestions();
      } catch (e) {
        _showMessage('批次刪除失敗: $e', isError: true);
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSelectionMode ? '已選擇 ${_selectedQuestionIds.length} 題' : '管理題目'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.select_all),
              onPressed: _toggleSelectAll,
              tooltip: _isAllSelected ? '取消全選' : '全選當前分類',
            ),
          if (_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _selectedQuestionIds.isNotEmpty ? _deleteSelectedQuestions : null,
              tooltip: '刪除選中的題目',
            ),
          IconButton(
            icon: Icon(_isSelectionMode ? Icons.close : Icons.checklist),
            onPressed: () {
              setState(() {
                _isSelectionMode = !_isSelectionMode;
                if (!_isSelectionMode) {
                  _selectedQuestionIds.clear();
                }
              });
            },
            tooltip: _isSelectionMode ? '取消選擇' : '批次選擇',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadQuestions,
            tooltip: '重新載入',
          ),
        ],
      ),
      body: Column(
        children: [
          // 類別篩選
          Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // 題目列表
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(_errorMessage!),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadQuestions,
                              child: const Text('重試'),
                            ),
                          ],
                        ),
                      )
                    : _filteredQuestions.isEmpty
                        ? const Center(
                            child: Text('沒有題目'),
                          )
                        : ListView.builder(
                            itemCount: _filteredQuestions.length,
                            itemBuilder: (context, index) {
                              final question = _filteredQuestions[index];
                              final isSelected = question.id != null && 
                                  _selectedQuestionIds.contains(question.id);
                              
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: ListTile(
                                  leading: _isSelectionMode
                                      ? Checkbox(
                                          value: isSelected,
                                          onChanged: question.id != null
                                              ? (checked) {
                                                  setState(() {
                                                    if (checked == true) {
                                                      _selectedQuestionIds.add(question.id!);
                                                    } else {
                                                      _selectedQuestionIds.remove(question.id!);
                                                    }
                                                  });
                                                }
                                              : null,
                                        )
                                      : CircleAvatar(
                                          child: Text('${index + 1}'),
                                        ),
                                  title: Text(
                                    question.questionText,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(
                                        '類別: ${question.category}',
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.primary,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        '選項: ${question.options.length} 個',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  trailing: _isSelectionMode
                                      ? null
                                      : IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => _deleteQuestion(question),
                                        ),
                                  onTap: _isSelectionMode && question.id != null
                                      ? () {
                                          setState(() {
                                            if (isSelected) {
                                              _selectedQuestionIds.remove(question.id!);
                                            } else {
                                              _selectedQuestionIds.add(question.id!);
                                            }
                                          });
                                        }
                                      : () => _showQuestionDetail(question),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  void _showQuestionDetail(Question question) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('題目詳情'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '類別: ${question.category}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '題目:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(question.questionText),
              const SizedBox(height: 16),
              const Text(
                '選項:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...question.options.asMap().entries.map((entry) {
                final index = entry.key;
                final option = entry.value;
                final isCorrect = index == question.correctAnswer;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${String.fromCharCode(65 + index)}. ',
                        style: TextStyle(
                          fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
                          color: isCorrect ? Colors.green : null,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
                            color: isCorrect ? Colors.green : null,
                          ),
                        ),
                      ),
                      if (isCorrect)
                        const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    ],
                  ),
                );
              }),
              if (question.explanation != null && question.explanation!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  '解析:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(question.explanation!),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('關閉'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteQuestion(question);
            },
            child: const Text(
              '刪除',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
