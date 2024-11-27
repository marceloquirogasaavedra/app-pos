import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/sucursal_service.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final SucursalService _sucursalService = SucursalService();
  bool _isLoading = false;

  void _login(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    setState(() {
      _isLoading = true;
    });

    try {
      await authProvider.login(
        _emailController.text,
        _passwordController.text,
      );
      // Después de iniciar sesión, obtener las sucursales
      _selectSucursal(context, authProvider.token!);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _selectSucursal(BuildContext context, String token) async {
    try {
      final sucursales = await _sucursalService.fetchSucursales(token);

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Seleccionar Sucursal'),
            content: SingleChildScrollView(
              child: Column(
                children: sucursales.map((sucursal) {
                  return ListTile(
                    title: Text(sucursal['nombre']),
                    subtitle: Text(sucursal['direccion']),
                    onTap: () {
                      final authProvider =
                          Provider.of<AuthProvider>(context, listen: false);
                      authProvider.setSucursalId(sucursal['id']);
                      Navigator.of(context).pop(); // Cerrar el diálogo
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DashboardScreen()),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar sucursales: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inicio de Sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Correo electrónico'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () => _login(context),
                    child: Text('Iniciar Sesión'),
                  ),
          ],
        ),
      ),
    );
  }
}
