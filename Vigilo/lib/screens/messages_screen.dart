import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../services/Message_Service.dart';
import 'message_details_screen.dart';

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

  Color _getStatusColor(MessageModel message) {
    if (message.isSafe == true) return Colors.green.shade700;
    if (message.isPhishing == true) return Colors.red.shade700;
    if (message.hasSocialEngineering == true) return Colors.orange.shade700;
    return Colors.grey.shade700;
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
                            errorBuilder: (_, __, ___) {
                              return const Icon(
                                Icons.arrow_back_ios,
                                color: Colors.white,
                                size: 20,
                              );
                            },
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
                    child: Stack(
                      children: [
                        Column(
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
                                      bottom: 70,
                                    ),
                                    itemCount: messages.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 14),
                                    itemBuilder: (_, index) {
                                      final msg = messages[index];

                                      return Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(6),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    MessageDetailsScreen(
                                                  message: msg,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(14),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFD9D9D9),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                color: Colors.black12,
                                              ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  msg.content,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 10,
                                                    vertical: 5,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: _getStatusColor(msg)
                                                        .withValues(alpha: 0.15),
                                                    borderRadius:
                                                        BorderRadius.circular(20),
                                                    border: Border.all(
                                                      color: _getStatusColor(msg),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    _getStatus(msg),
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          _getStatusColor(msg),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          right: 6,
                          bottom: 8,
                          child: Image.asset(
                            'assets/icon.png',
                            width: 46,
                            height: 46,
                            errorBuilder: (_, __, ___) {
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
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