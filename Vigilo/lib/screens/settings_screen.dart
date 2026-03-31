import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  double phishingPercentage = 80;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 🔹 HEADER (igual outras telas)
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
                      'Configurações',
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
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // 🔹 CARD PRINCIPAL
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// 🔹 SWITCH NOTIFICAÇÃO
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Deseja receber as notificações de captura em tempo real?',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                              Switch(
                                value: notificationsEnabled,
                                activeColor: const Color(0xFF3B8EDB),
                                onChanged: (value) {
                                  setState(() {
                                    notificationsEnabled = value;
                                  });
                                },
                              ),
                            ],
                          ),

                          const Divider(),

                          const SizedBox(height: 10),

                          /// 🔹 SLIDER
                          const Text(
                            'Porcentagem para notificação:',
                            style: TextStyle(fontSize: 15),
                          ),

                          Slider(
                            value: phishingPercentage,
                            min: 0,
                            max: 100,
                            divisions: 20,
                            label: "${phishingPercentage.round()}%",
                            activeColor: const Color(0xFF3B8EDB),
                            onChanged: (value) {
                              setState(() {
                                phishingPercentage = value;
                              });
                            },
                          ),

                          Text(
                            'Isso define a partir de quantos porcento de chance de ser phishing você receberá a notificação alertando phishing, recomendamos acima dos 80%.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade800,
                            ),
                          ),

                          const SizedBox(height: 18),

                          /// 🔹 PERMISSÕES
                          const Text(
                            'Permissões necessárias:',
                            style: TextStyle(fontSize: 15),
                          ),

                          const SizedBox(height: 10),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // FUTURO: abrir permissões do sistema
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3B8EDB),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Permissões',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            'Essa permissão é o que nos permite ver quem são as pessoas que estão te mandando mensagem, para que possamos pegar possíveis fraudadores.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// 🔹 BALÃO + PERSONAGEM
                    Column(
                      children: [
                        Image.asset(
                          'assets/Fala_Config.png',
                          height: 150,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}