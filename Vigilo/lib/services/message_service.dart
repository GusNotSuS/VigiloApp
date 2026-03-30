import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message_model.dart';

class MessageService {
  // Troque pela URL real da sua API
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1/messages';

  Future<List<MessageModel>> fetchMessages() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar mensagens');
    }

    final body = jsonDecode(response.body);

    if (body is List) {
      return body.map((item) => MessageModel.fromJson(item)).toList();
    }

    if (body is Map && body['items'] is List) {
      return (body['items'] as List)
          .map((item) => MessageModel.fromJson(item))
          .toList();
    }

    return [];
  }

  Future<MessageModel> createMessage(String content) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'content': content}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erro ao enviar mensagem');
    }

    final body = jsonDecode(response.body);
    return MessageModel.fromJson(body);
  }
}