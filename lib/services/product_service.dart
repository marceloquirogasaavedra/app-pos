import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductService {
  final String baseUrl = "http://localhost:8080/pos/producto";

  Future<List<dynamic>> fetchProducts(String token) async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return jsonData['data'];
    } else {
      throw Exception('Error al obtener productos');
    }
  }
}
