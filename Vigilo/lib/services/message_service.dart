import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message_model.dart';

class MessageService {
  Future<List<MessageModel>> fetchMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final String serverIp = prefs.getString('server_ip') ?? '172.16.220.249';
    final String deviceId = prefs.getString('device_id') ?? 'default_device';

    final url = Uri.parse('http://$serverIp:8080/api/v1/messages/');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-Device-ID': deviceId,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> items = data['items'] ?? [];
        return items.map((json) => MessageModel.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao carregar mensagens');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }
}