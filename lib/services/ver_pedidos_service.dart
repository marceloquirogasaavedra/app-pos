import 'dart:convert';
import 'package:http/http.dart' as http;

class VerPedidosService {
  final String baseUrl = "http://localhost:8080/pos/pedido";

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
