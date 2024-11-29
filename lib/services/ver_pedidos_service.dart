import 'dart:convert';
import 'package:http/http.dart' as http;

class VerPedidosService {
  final String baseUrl = "http://98.85.18.243:8080/pos/pos/pedido";

  Future<List<dynamic>> fetchPedidos(String email, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl?email=$email'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener pedidos: ${response.body}');
    }
  }
}
