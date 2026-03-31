import 'dart:async';
import '../models/message_model.dart';

class MessageService {
  // 🔹 FUTURO: trocar por API real
  static const String baseUrl = 'http://SEU_BACKEND_AQUI';

  Future<List<MessageModel>> fetchMessages() async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      MessageModel(
        id: '1',
        content: 'Acesse http://banco-fake.com para atualizar seus dados',
        isPhishing: true,
        hasSocialEngineering: true,
        isSafe: false,
        resultLink: 'http://banco-fake.com',
        createdAt: '2026-03-31 20:10',
      ),
      MessageModel(
        id: '2',
        content: 'Sua encomenda chegou! Veja detalhes no app oficial.',
        isSafe: true,
        isPhishing: false,
        hasSocialEngineering: false,
        createdAt: '2026-03-31 19:00',
      ),
      MessageModel(
        id: '3',
        content: 'Promoção imperdível!!! Clique agora!',
        hasSocialEngineering: true,
        isSafe: false,
        isPhishing: false,
        createdAt: '2026-03-30 22:15',
      ),
    ];
  }

  Future<MessageModel> createMessage(String content) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return MessageModel(
      id: DateTime.now().toString(),
      content: content,
      isSafe: false,
      isPhishing: true,
      hasSocialEngineering: true,
      createdAt: DateTime.now().toString(),
    );
  }
}