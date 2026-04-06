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
                    'Resumo de monitoramento',
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
                        return _statusBox(
                          title: 'Carregando monitoramento',
                          description:
                              'Aguarde enquanto verificamos as mensagens capturadas.',
                          titleColor: Colors.black87,
                          icon: Icons.hourglass_top_rounded,
                        );
                      }

                      if (snapshot.hasError) {
                        return _statusBox(
                          title: 'Falha ao consultar mensagens',
                          description:
                              'Não foi possível carregar o resumo no momento.',
                          titleColor: Colors.red.shade700,
                          icon: Icons.error_outline_rounded,
                        );
                      }

                      final messages = snapshot.data ?? [];

                      if (messages.isEmpty) {
                        return _statusBox(
                          title: 'Nenhuma mensagem capturada',
                          description:
                              'O Vigilio ainda não identificou mensagens para análise.',
                          titleColor: Colors.black87,
                          icon: Icons.inbox_outlined,
                        );
                      }

                      final suspiciousMessages = messages.where((msg) {
                        return msg.isSafe == false ||
                            msg.isPhishing == true ||
                            msg.hasSocialEngineering == true;
                      }).toList();

                      if (suspiciousMessages.isEmpty) {
                        return _statusBox(
                          title: 'Mensagens monitoradas sem risco',
                          description:
                              'Foram identificadas mensagens, mas nenhuma apresentou sinais de phishing ou engenharia social.',
                          titleColor: Colors.green.shade700,
                          icon: Icons.verified_user_outlined,
                        );
                      }

                      if (suspiciousMessages.length == 1) {
                        return _statusBox(
                          title: '1 mensagem suspeita encontrada',
                          description:
                              'Foi identificado um conteúdo com indícios de risco. Consulte a caixa de entrada para análise detalhada.',
                          titleColor: Colors.red.shade700,
                          icon: Icons.warning_amber_rounded,
                        );
                      }

                      return _statusBox(
                        title:
                            '${suspiciousMessages.length} mensagens suspeitas encontradas',
                        description:
                            'Foram detectadas mensagens com possíveis indícios de phishing ou engenharia social. Revise a caixa de entrada para mais detalhes.',
                        titleColor: Colors.red.shade700,
                        icon: Icons.warning_amber_rounded,
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

  Widget _statusBox({
    required String title,
    required String description,
    required Color titleColor,
    required IconData icon,
  }) {
    return Container(
      height: 185,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: titleColor,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              height: 1.4,
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