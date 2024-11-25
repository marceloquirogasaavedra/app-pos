import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'pedido_screen.dart';
import 'ver_pedidos_screen.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PedidoScreen()),
                );
              },
              child: Text('Pedido'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 50), // Ancho y alto del botón
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VerPedidosScreen()),
                );
              },
              child: Text('Ver Pedidos'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 50), // Ancho y alto del botón
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Regresa al login eliminando la pila de navegación.
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false,
                );
              },
              child: Text('Salir'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 50), // Ancho y alto del botón
                backgroundColor: Colors.red, // Color del botón de salir
              ),
            ),
          ],
        ),
      ),
    );
  }
}
