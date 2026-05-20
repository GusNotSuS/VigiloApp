import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message_model.dart';
import '../services/app_config.dart';

class MessageService {
  // CELULAR FÍSICO (troca pelo IP do seu PC):
  static const String baseUrl = AppConfig.baseUrl;

  Future<List<MessageModel>> fetchMessages() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return (data['items'] as List)
          .map((e) => MessageModel.fromJson(e))
          .toList();
    } else {
      throw Exception('Erro ao buscar mensagens');
    }
  }

  Future<MessageModel> createMessage(String content) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'content': content}),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return MessageModel.fromJson(data);
    } else {
      throw Exception('Erro ao criar mensagem');
    }
  }
}