import 'package:flutter/material.dart';
import '../models/message_model.dart';

class MessageDetailsScreen extends StatelessWidget {
  final MessageModel message;

  const MessageDetailsScreen({
    super.key,
    required this.message,
  });

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
    final status = _getStatus(message);

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
                            Navigator.pop(context);
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
                          'Detalhes da Mensagem',
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD9D9D9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(message).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _getStatusColor(message),
                                  ),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _getStatusColor(message),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'Conteúdo da mensagem',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                message.content,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (message.createdAt != null &&
                                  message.createdAt!.isNotEmpty) ...[
                                const Text(
                                  'Recebida em',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  message.createdAt!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                              const Text(
                                'Análise',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Phishing: ${message.isPhishing == null ? "Não analisado" : message.isPhishing! ? "Sim" : "Não"}',
                                style: const TextStyle(fontSize: 13),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Engenharia social: ${message.hasSocialEngineering == null ? "Não analisado" : message.hasSocialEngineering! ? "Sim" : "Não"}',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Image.asset(
                          'assets/icon.png',
                          width: 56,
                          height: 56,
                          errorBuilder: (_, __, ___) {
                            return const SizedBox.shrink();
                          },
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