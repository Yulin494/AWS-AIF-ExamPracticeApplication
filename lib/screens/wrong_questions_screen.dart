import 'package:flutter/material.dart';
import '../services/database_service.dart';
import 'practice_screen.dart';

class WrongQuestionsScreen extends StatefulWidget {
  const WrongQuestionsScreen({super.key});

  @override
  State<WrongQuestionsScreen> createState() => _WrongQuestionsScreenState();
}

class _WrongQuestionsScreenState extends State<WrongQuestionsScreen> {
  List<int> _wrongQuestionIds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWrongQuestions();
  }

  Future<void> _loadWrongQuestions() async {
    setState(() => _isLoading = true);
    final ids = await DatabaseService.instance.getWrongQuestionIds();
    setState(() {
      _wrongQuestionIds = ids;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('錯題複習'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _wrongQuestionIds.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, size: 100, color: Colors.green),
                      SizedBox(height: 16),
                      Text(
                        '太棒了！目前沒有錯題記錄',
                        style: TextStyle(fontSize: 18),
                      ),
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
                        color: Colors.orange[50],
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 50,
                                color: Colors.orange,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '共有 ${_wrongQuestionIds.length} 道錯題',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '加油！重新練習這些題目，加深印象',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PracticeScreen(
                                questionIds: _wrongQuestionIds,
                              ),
                            ),
                          );
                          _loadWrongQuestions(); // 重新載入錯題列表
                        },
                        icon: const Icon(Icons.play_circle_filled, size: 28),
                        label: const Text(
                          '開始錯題練習',
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
                      const SizedBox(height: 16),
                      const Text(
                        '錯題清單',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Card(
                          child: ListView.builder(
                            itemCount: _wrongQuestionIds.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.orange,
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text('題目 ID: ${_wrongQuestionIds[index]}'),
                                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
