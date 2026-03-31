import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../services/message_service.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final MessageService _service = MessageService();
  late Future<List<MessageModel>> _futureMessages;

  @override
  void initState() {
    super.initState();
    _futureMessages = _service.fetchMessages();
  }

  String _getStatus(MessageModel message) {
    if (message.isSafe == true) return 'Segura';
    if (message.isPhishing == true) return 'Phishing';
    if (message.hasSocialEngineering == true) {
      return 'Engenharia social';
    }
    return 'Sem classificação';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 🔹 HEADER
          Container(
            width: double.infinity,
            height: 90,
            color: const Color(0xFF3B8EDB),
            child: const Row(
              children: [
                SizedBox(width: 16),
                Icon(Icons.menu, color: Colors.white),
                Expanded(
                  child: Center(
                    child: Text(
                      'Caixa de Entrada',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 40),
              ],
            ),
          ),

          // 🔹 BODY
          Expanded(
            child: Container(
              width: double.infinity,
              color: const Color(0xFFE5E5E5),
              child: FutureBuilder<List<MessageModel>>(
                future: _futureMessages,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Erro: ${snapshot.error}'),
                    );
                  }

                  final messages = snapshot.data ?? [];

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 16),
                    itemBuilder: (_, index) {
                      final msg = messages[index];

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(msg.content),
                            const SizedBox(height: 8),
                            Text(
                              _getStatus(msg),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}