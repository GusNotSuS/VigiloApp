import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 🔹 Topo azul com o pinguim
          Container(
            width: double.infinity,
            height: 220,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(
              child: Image.asset(
                'assets/icon.png', // seu pinguim
                height: 110,
              ),
            ),
          ),

          // 🔹 Espaço central (cinza claro)
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.grey.shade300,
            ),
          ),

          // 🔹 Botões
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: const Color(0xFF4A90E2),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/messages');
                    },
                    child: const Text(
                      'Mensagens',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: const Color(0xFF4A90E2),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/settings');
                    },
                    child: const Text(
                      'Configurações',
                      style: TextStyle(fontSize: 16),
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