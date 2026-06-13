import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/app_constants.dart';

class ChatbotService {
  Future<Map<String, dynamic>> sendMessage(String message, List<String> history) async {
    try {
      final baseUrl = AppConstants.baseUrl;
      final response = await http.post(
        Uri.parse('$baseUrl/chatbot'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'message': message, 'history': history}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'reply': data['reply'] ?? 'Tidak ada balasan dari server.',
          'products': data['products'] ?? [],
        };
      } else {
        return {'reply': 'Maaf, terjadi kesalahan saat menghubungi server.', 'products': []};
      }
    } catch (e) {
      return {'reply': 'Maaf, gagal terhubung ke server. Periksa koneksi internet Anda.', 'products': []};
    }
  }
}
