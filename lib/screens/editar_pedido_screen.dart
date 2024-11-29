import 'package:flutter/material.dart';
import '../services/editar_pedido_service.dart';
import '../services/product_service.dart';
import '../services/cliente_service.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'ver_pedidos_screen.dart';

class EditarPedidoScreen extends StatefulWidget {
  final int idPedido;

  const EditarPedidoScreen({required this.idPedido});

  @override
  _EditarPedidoScreenState createState() => _EditarPedidoScreenState();
}

class _EditarPedidoScreenState extends State<EditarPedidoScreen> {
  final EditarPedidoService _editarPedidoService = EditarPedidoService();
  final ProductService _productService = ProductService();
  final ClienteService _clienteService = ClienteService();
  Map<String, dynamic>? _pedidoDetalle;
  List<Map<String, dynamic>> _detalleProductos = [];
  List<dynamic> _productosDisponibles = [];
  bool _isLoading = true;
  String? _nitCliente; // Almacena el NIT del cliente
  Map<String, dynamic>? _clienteSeleccionado; // Datos del cliente seleccionado
  final TextEditingController _nitController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPedidoDetalle();
    _loadProductosDisponibles();
  }

  Future<void> _loadPedidoDetalle() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final detalle = await _editarPedidoService.fetchPedidoDetalle(
        widget.idPedido,
        authProvider.token!,
      );
      setState(() {
        _nitCliente = detalle["nit_cliente"];
        _nitController.text =
            detalle["nit_cliente"]; // Inicializa el controlador
        _pedidoDetalle = detalle["pedido"];
        _detalleProductos = List<Map<String, dynamic>>.from(detalle["detalle"]);
        _descripcionController.text = detalle["pedido"]["descripcion"];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar el pedido: ${e.toString()}')),
      );
    }
  }

  Future<void> _loadProductosDisponibles() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final idSucursal = authProvider.sucursalId!;
      final productos = await _productService.fetchProducts(
        authProvider.token!,
        idSucursal,
      );
      setState(() {
        _productosDisponibles = productos;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar productos: ${e.toString()}')),
      );
    }
  }

  Future<void> _buscarCliente() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final nit = _nitController.text.trim();

    if (nit.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, ingresa el NIT del cliente')),
      );
      return;
    }

    try {
      final cliente =
          await _clienteService.fetchCliente(authProvider.token!, nit);
      setState(() {
        _clienteSeleccionado = cliente;
        _nitCliente = nit;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cliente encontrado: ${cliente["nombre"]}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al buscar cliente: ${e.toString()}')),
      );
    }
  }

  void _updateCantidad(int index, int cantidad) {
    setState(() {
      _detalleProductos[index]["cantidad"] = cantidad;
      _detalleProductos[index]["subtotal"] =
          cantidad * _detalleProductos[index]["precio"];
    });
  }

  void _removeProducto(int index) {
    setState(() {
      _detalleProductos.removeAt(index);
    });
  }

  void _addProducto() {
    setState(() {
      _detalleProductos.add({
        "id_producto": null,
        "nombre": null,
        "cantidad": 1,
        "precio": 0.0,
        "subtotal": 0.0,
      });
    });
  }

  Future<void> _guardarCambios() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (_descripcionController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('La descripción no puede estar vacía')),
        );
        return;
      }

      if (_detalleProductos.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Debe agregar al menos un producto')),
        );
        return;
      }

      if (_detalleProductos.any((detalle) => detalle["id_producto"] == null)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Seleccione un producto para cada entrada')),
        );
        return;
      }

      if (_clienteSeleccionado == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Por favor, selecciona un cliente válido')),
        );
        return;
      }

      final detalle = _detalleProductos.map((producto) {
        return {
          "id_producto": producto["id_producto"],
          "cantidal": producto["cantidad"],
        };
      }).toList();

      await _editarPedidoService.actualizarPedido(
        widget.idPedido,
        _descripcionController.text,
        _clienteSeleccionado!["id"], // ID del cliente encontrado
        detalle,
        authProvider.token!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pedido actualizado exitosamente')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => VerPedidosScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar cambios: ${e.toString()}')),
      );
    }
  }

  void _cancelarEdicion() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => VerPedidosScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar Pedido')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pedido: ${_pedidoDetalle!["id"]}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                      'Fecha: ${_pedidoDetalle!["fecha"].split("T")[1].split(".")[0]} ${_pedidoDetalle!["fecha"].split("T")[0]}'),
                  SizedBox(height: 10),
                  TextField(
                    controller: _nitController,
                    decoration: InputDecoration(
                      labelText: 'NIT del Cliente',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: _buscarCliente,
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (_clienteSeleccionado != null) ...[
                    SizedBox(height: 10),
                    Text(
                        'Cliente seleccionado: ${_clienteSeleccionado!["nombre"]} ${_clienteSeleccionado!["apellido"]}'),
                  ],
                  SizedBox(height: 10),
                  TextField(
                    controller: _descripcionController,
                    decoration: InputDecoration(
                      labelText: 'Descripción',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  Divider(height: 20),
                  Text(
                    'Detalles del Pedido:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _detalleProductos.length,
                      itemBuilder: (context, index) {
                        final detalle = _detalleProductos[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DropdownButton<dynamic>(
                                  hint: Text('Selecciona un producto'),
                                  value: detalle["id_producto"],
                                  items: _productosDisponibles.map((producto) {
                                    return DropdownMenuItem<dynamic>(
                                      value: producto["id_producto"],
                                      child: Text(producto["nombre"]),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      detalle["id_producto"] = value;
                                      detalle["nombre"] = _productosDisponibles
                                          .firstWhere((p) =>
                                              p["id_producto"] ==
                                              value)["nombre"];
                                      detalle["precio"] = _productosDisponibles
                                          .firstWhere((p) =>
                                              p["id_producto"] ==
                                              value)["precioVenta"];
                                      detalle["subtotal"] =
                                          detalle["cantidad"] *
                                              detalle["precio"];
                                    });
                                  },
                                ),
                                SizedBox(height: 10),
                                Text('Precio: \$${detalle["precio"]}'),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Cantidad:'),
                                    IconButton(
                                      icon: Icon(Icons.remove),
                                      onPressed: detalle["cantidad"] > 1
                                          ? () => _updateCantidad(
                                              index, detalle["cantidad"] - 1)
                                          : null,
                                    ),
                                    Text('${detalle["cantidad"]}'),
                                    IconButton(
                                      icon: Icon(Icons.add),
                                      onPressed: () => _updateCantidad(
                                          index, detalle["cantidad"] + 1),
                                    ),
                                  ],
                                ),
                                Text('Subtotal: \$${detalle["subtotal"]}'),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _removeProducto(index),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _addProducto,
                    child: Text('Añadir producto'),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: _guardarCambios,
                        child: Text('Guardar'),
                      ),
                      ElevatedButton(
                        onPressed: _cancelarEdicion,
                        child: Text('Cancelar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
