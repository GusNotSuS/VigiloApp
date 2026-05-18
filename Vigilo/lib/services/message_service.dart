import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message_model.dart';

class MessageService {
  // Endereço da API REST real [cite: 22, 49]
  static const String baseUrl = 'http://10.10.2.130:8080/api/v1/messages/';

  // Implementação de paginação para evitar gargalos [cite: 24, 63]
  Future<List<MessageModel>> fetchMessages({int page = 1, int limit = 20}) async {
    final response = await http.get(
      Uri.parse('$baseUrl?page=$page&limit=$limit'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return (data['items'] as List)
          .map((e) => MessageModel.fromJson(e))
          .toList();
    } else {
      throw Exception('Erro ao buscar histórico de mensagens [cite: 53]');
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
      throw Exception('Erro ao enviar mensagem para análise [cite: 51]');
    }
  }
}