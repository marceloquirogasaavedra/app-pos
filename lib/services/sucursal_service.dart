import 'dart:convert';
import 'package:http/http.dart' as http;

class SucursalService {
  final String baseUrl = "http://localhost:8080/pos/sucursal";

  Future<List<dynamic>> fetchSucursales(String token) async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    } else {
      throw Exception('Error al obtener sucursales: ${response.body}');
    }
  }
}
