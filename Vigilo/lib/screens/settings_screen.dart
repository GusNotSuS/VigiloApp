import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Placeholder de Configurações',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                Text('Aqui depois você pode colocar:'),
                SizedBox(height: 8),
                Text('- ativar captura de mensagens'),
                Text('- ativar captura de e-mails'),
                Text('- URL do backend'),
                Text('- token/autenticação'),
                Text('- permissões do app'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}