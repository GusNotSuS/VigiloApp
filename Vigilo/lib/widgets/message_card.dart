import 'package:flutter/material.dart';
import '../models/message_model.dart';

class MessageCard extends StatelessWidget {
  final MessageModel message;

  const MessageCard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUnsafe = message.isSafe == false;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message.content, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            // Explicação de classificação [cite: 59]
            if (isUnsafe && message.classificationReason != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: Colors.red.shade900),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Análise: ${message.classificationReason}", // Ex: "Link suspeito" [cite: 37]
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            // ... resto do código do card (ícones e datas)
          ],
        ),
      ),
    );
  }
}