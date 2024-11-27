import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductService {
  final String baseUrl = "http://localhost:8080/pos/producto/por-sucursal";

  Future<List<dynamic>> fetchProducts(String token, int idSucursal) async {
    final response = await http.get(
      Uri.parse('$baseUrl?idSucursal=$idSucursal'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener productos: ${response.body}');
    }
  }
}
