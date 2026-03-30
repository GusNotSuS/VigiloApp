import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../services/message_service.dart';
import '../widgets/message_card.dart';

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

  void _reload() {
    setState(() {
      _futureMessages = _service.fetchMessages();
    });
  }

  Future<void> _sendMockMessage() async {
    try {
      await _service.createMessage(
        'Oi! Acesse http://exemplo.com para mais informações.',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mensagem enviada para análise')),
      );

      _reload();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar mensagem: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mensagens'),
        actions: [
          IconButton(
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendMockMessage,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<MessageModel>>(
        future: _futureMessages,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text('Erro ao carregar mensagens:\n${snapshot.error}'),
              ),
            );
          }

          final messages = snapshot.data ?? [];

          if (messages.isEmpty) {
            return const Center(
              child: Text('Nenhuma mensagem encontrada'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: messages.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, index) {
              return MessageCard(message: messages[index]);
            },
          );
        },
      ),
    );
  }
}