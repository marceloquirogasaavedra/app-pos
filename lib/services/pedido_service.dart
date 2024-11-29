import 'dart:convert';
import 'package:http/http.dart' as http;

class PedidoService {
  final String baseUrl = "http://localhost:8080/pos/pos/pedido";

  Future<void> enviarPedido(String email, String descripcion, int idCliente,
      List<Map<String, dynamic>> detalle, String token) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        "email": email,
        "descripcion": descripcion,
        "id_cliente": idCliente,
        "detalle": detalle,
      }),
    );

    if (response.statusCode == 200) {
      print("Pedido enviado exitosamente");
    } else {
      throw Exception('Error al enviar el pedido: ${response.body}');
    }
  }
}
