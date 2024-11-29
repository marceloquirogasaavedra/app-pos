import 'dart:convert';
import 'package:http/http.dart' as http;

class EditarPedidoService {
  final String baseUrl = "http://localhost:8080/pos/pos/pedido";

  /// Obtener los detalles del pedido
  Future<Map<String, dynamic>> fetchPedidoDetalle(
      int idPedido, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/detalle/$idPedido'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener detalles del pedido: ${response.body}');
    }
  }

  /// Actualizar el pedido
  Future<void> actualizarPedido(
    int idPedido,
    String descripcion,
    int idCliente,
    List<Map<String, dynamic>> detalle,
    String token,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$idPedido'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        "descripcion": descripcion,
        "id_cliente": idCliente,
        "detalle": detalle,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar el pedido: ${response.body}');
    }
  }
}
