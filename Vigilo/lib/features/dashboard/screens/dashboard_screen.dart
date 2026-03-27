import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 200,
            color: Colors.blue,
            child: const Center(
              child: Text(
                "Vigilo\nOlá, Bem vindo!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
          ),

          const SizedBox(height: 30),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(child: Text("Dashboard")),
          ),

          const SizedBox(height: 30),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.messages);
                },
                child: const Text("Mensagens"),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {},
                child: const Text("Configurações"),
              ),
            ],
          )
        ],
      ),
    );
  }
}

