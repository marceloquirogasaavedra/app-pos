import 'package:http/http.dart' as http;

class EliminarPedidoService {
  final String baseUrl = "http://98.85.18.243:8080/pos/pos/pedido";

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
