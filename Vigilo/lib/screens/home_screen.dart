import 'package:flutter/material.dart';
import '../services/message_service.dart';
import '../models/message_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                      'Resumo',
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
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  const Text('Última mensagem capturada'),

                  const SizedBox(height: 12),

                  // 🔹 CARD COM DADOS
                  FutureBuilder<List<MessageModel>>(
                    future: MessageService().fetchMessages(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          height: 220,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final msg = snapshot.data!.first;

                      return Container(
                        width: double.infinity,
                        height: 220,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(msg.content),
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  // 🔹 BOTÕES
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/messages');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B8EDB),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Mensagens'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/settings');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B8EDB),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Configurações'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // 🔹 ICON
                  Image.asset(
                    'assets/Fala_Home.png',
                    height: 150,
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}