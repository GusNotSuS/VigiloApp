import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../services/message_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                          'assets/Banner_Home.png',
                          fit: BoxFit.fill,
                        ),
                      ),
                      const Center(
                        child: Text(
                          'Resumo',
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
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      children: [
                        const SizedBox(height: 18),
                        const Text(
                          'Última mensagem capturada',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        FutureBuilder<List<MessageModel>>(
                          future: MessageService().fetchMessages(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container(
                                height: 180,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD9D9D9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final messages = snapshot.data ?? [];

                            if (messages.isEmpty) {
                              return Container(
                                height: 180,
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD9D9D9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Text('Nenhuma mensagem capturada'),
                                ),
                              );
                            }

                            final msg = messages.first;

                            return Container(
                              height: 180,
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD9D9D9),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.black12,
                                ),
                              ),
                              child: Text(
                                msg.content,
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 28),
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
                          width: 160,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 10),
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
      height: 44,
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