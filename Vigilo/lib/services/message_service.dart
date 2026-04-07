import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message_model.dart';

class MessageService {
  // ⚠️ IMPORTANTE: trocar dependendo do teste

  // EMULADOR:
  // static const String baseUrl = 'http://10.0.2.2:8080/api/v1/messages';

  // CELULAR FÍSICO (troca pelo IP do seu PC):
  static const String baseUrl = 'http://10.91.23.196:8080/api/v1/messages/';

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