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
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/Background.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 70,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          'assets/banner.png',
                          fit: BoxFit.fill,
                        ),
                      ),
                      Positioned(
                        left: 8,
                        top: 0,
                        bottom: 0,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/',
                              (route) => false,
                            );
                          },
                          icon: Image.asset(
                            'assets/Return_Button.png',
                            width: 24,
                            height: 24,
                          ),
                        ),
                      ),
                      const Center(
                        child: Text(
                          'Caixa de Entrada',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        const Text(
                          'Mensagens capturadas',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: FutureBuilder<List<MessageModel>>(
                            future: _futureMessages,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              if (snapshot.hasError) {
                                return Center(
                                  child: Text('Erro: ${snapshot.error}'),
                                );
                              }

                              final messages = snapshot.data ?? [];

                              if (messages.isEmpty) {
                                return const Center(
                                  child: Text('Nenhuma mensagem encontrada'),
                                );
                              }

                              return ListView.separated(
                                padding: const EdgeInsets.only(
                                  top: 4,
                                  bottom: 12,
                                ),
                                itemCount: messages.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 14),
                                itemBuilder: (_, index) {
                                  final msg = messages[index];

                                  return Container(
                                    height: 105,
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD9D9D9),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: Colors.black12,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'Dados da mensagem',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _getStatus(msg),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Image.asset(
                            'assets/icon.png',
                            width: 48,
                            height: 48,
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}