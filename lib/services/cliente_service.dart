import 'dart:convert';
import 'package:http/http.dart' as http;

class ClienteService {
  final String baseUrl = "http://localhost:8080/pos/cliente/buscar-por-nit";

  Future<Map<String, dynamic>> fetchCliente(String token, String nit) async {
    final response = await http.get(
      Uri.parse('$baseUrl?nit=$nit'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al buscar cliente: ${response.body}');
    }
  }
}
