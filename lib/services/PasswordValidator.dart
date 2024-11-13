import 'dart:convert';
import 'package:http/http.dart' as http;

class PasswordValidator {
  Future<Map<String, dynamic>> validatePassword(String password) async {
    final url = Uri.parse('https://desafioflutter-api.modelviewlabs.com/validate');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'password': password}),
      );

      if (response.statusCode == 202) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 400) {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return {
          'message': errorData['message'] ?? 'Erro na validação',
          'errors': errorData['errors'] ?? []
        };
      } else if (response.statusCode == 503) {
        return {
          'message': 'Erro na requisição: Serviço temporariamente indisponível. Tente novamente',
          'errors': []
        };
      } else {
        throw Exception('Erro ao validar senha');
      }
    } catch (e) {
      print('Erro na requisição: $e');
      return {'message': 'Erro na requisição', 'erros': []};
    }

  }

}