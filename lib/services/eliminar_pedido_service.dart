import 'package:http/http.dart' as http;

class EliminarPedidoService {
  final String baseUrl = "http://localhost:8080/pos/pedido";

  Future<void> eliminarPedido(int idPedido, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$idPedido'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar el pedido: ${response.body}');
    }
  }
}
