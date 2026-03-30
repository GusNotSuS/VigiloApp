import 'package:flutter/material.dart';
import '../models/message_model.dart';

class MessageCard extends StatelessWidget {
  final MessageModel message;

  const MessageCard({
    super.key,
    required this.message,
  });

  String _statusText() {
    if (message.isSafe == true) return 'Segura';
    if (message.isPhishing == true) return 'Possível phishing';
    if (message.hasSocialEngineering == true) {
      return 'Possível engenharia social';
    }
    return 'Em análise / sem classificação';
  }

  IconData _statusIcon() {
    if (message.isSafe == true) return Icons.verified_user;
    if (message.isPhishing == true) return Icons.warning_amber_rounded;
    if (message.hasSocialEngineering == true) return Icons.report_problem;
    return Icons.help_outline;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(_statusIcon()),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _statusText(),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            if (message.resultLink != null && message.resultLink!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Link detectado: ${message.resultLink}',
                style: const TextStyle(fontSize: 13),
              ),
            ],
            if (message.createdAt != null) ...[
              const SizedBox(height: 8),
              Text(
                'Criado em: ${message.createdAt}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }
}