import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ver_pedidos_service.dart';
import '../services/eliminar_pedido_service.dart';
import '../providers/auth_provider.dart';
import 'editar_pedido_screen.dart';

class VerPedidosScreen extends StatefulWidget {
  @override
  _VerPedidosScreenState createState() => _VerPedidosScreenState();
}

class _VerPedidosScreenState extends State<VerPedidosScreen> {
  final VerPedidosService _verPedidosService = VerPedidosService();
  final EliminarPedidoService _eliminarPedidoService = EliminarPedidoService();
  List<dynamic> _pedidos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPedidos();
  }

  Future<void> _loadPedidos() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final pedidos = await _verPedidosService.fetchPedidos(
        authProvider.email!,
        authProvider.token!,
      );
      setState(() {
        _pedidos = pedidos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar pedidos: ${e.toString()}')),
      );
    }
  }

  Future<void> _eliminarPedido(int idPedido) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await _eliminarPedidoService.eliminarPedido(
          idPedido, authProvider.token!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pedido eliminado exitosamente')),
      );
      _loadPedidos(); // Recargar la lista de pedidos
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar pedido: ${e.toString()}')),
      );
    }
  }

  void _confirmarEliminar(int idPedido) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmación'),
        content: Text('¿Está seguro que desea eliminar este pedido?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar el diálogo
              _eliminarPedido(idPedido); // Eliminar el pedido
            },
            child: Text('Sí'),
          ),
        ],
      ),
    );
  }

  void _irAEditarPedido(int idPedido) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarPedidoScreen(idPedido: idPedido),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Pedidos'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _pedidos.isEmpty
              ? Center(child: Text('No tienes pedidos registrados'))
              : ListView.builder(
                  itemCount: _pedidos.length,
                  itemBuilder: (context, index) {
                    final pedido = _pedidos[index];
                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: Icon(Icons.shopping_bag),
                        title: Text('Pedido: ${pedido["id"]}'),
                        subtitle: Text(
                          '${pedido["descripcion"]}\nFecha: ${pedido["fecha"]}\nTotal: \$${pedido["toal"]}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _irAEditarPedido(pedido["id"]),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmarEliminar(pedido["id"]),
                            ),
                            Icon(
                              pedido["estado"]
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color:
                                  pedido["estado"] ? Colors.green : Colors.red,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
