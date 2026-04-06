import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../services/Message_Service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = MessageService();

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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 130,
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Image.asset(
                            'assets/Banner_Home.png',
                            height: 90,
                            fit: BoxFit.fill,
                            errorBuilder: (_, __, ___) {
                              return Container(
                                height: 90,
                                color: const Color(0xFF2E97F2),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          top: 50,
                          child: Image.asset(
                            'assets/icon.png',
                            width: 58,
                            height: 58,
                            errorBuilder: (_, __, ___) {
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Última mensagem capturada',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  FutureBuilder<List<MessageModel>>(
                    future: service.fetchMessages(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _messageBox(
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return _messageBox(
                          child: Center(
                            child: Text('Erro: ${snapshot.error}'),
                          ),
                        );
                      }

                      final messages = snapshot.data ?? [];

                      if (messages.isEmpty) {
                        return _messageBox(
                          child: const Center(
                            child: Text('Nenhuma mensagem capturada'),
                          ),
                        );
                      }

                      final msg = messages.first;

                      return _messageBox(
                        child: Text(
                          msg.content,
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 36),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          label: 'Mensagens',
                          onTap: () {
                            Navigator.pushNamed(context, '/messages');
                          },
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _ActionButton(
                          label: 'Configurações',
                          onTap: () {
                            Navigator.pushNamed(context, '/settings');
                          },
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Image.asset(
                    'assets/Fala_Home.png',
                    width: 170,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) {
                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageBox({required Widget child}) {
    return Container(
      height: 185,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      child: child,
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E97F2),
          foregroundColor: Colors.black,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}