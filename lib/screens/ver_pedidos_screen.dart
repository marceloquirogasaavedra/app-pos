import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ver_pedidos_service.dart';
import '../providers/auth_provider.dart';

class VerPedidosScreen extends StatefulWidget {
  @override
  _VerPedidosScreenState createState() => _VerPedidosScreenState();
}

class _VerPedidosScreenState extends State<VerPedidosScreen> {
  final VerPedidosService _verPedidosService = VerPedidosService();
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
                        trailing: Icon(
                          pedido["estado"] ? Icons.check_circle : Icons.cancel,
                          color: pedido["estado"] ? Colors.green : Colors.red,
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
