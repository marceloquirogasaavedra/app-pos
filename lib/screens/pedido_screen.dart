import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/product_service.dart';
import '../services/pedido_service.dart';
import '../services/cliente_service.dart';
import '../providers/auth_provider.dart';

class PedidoScreen extends StatefulWidget {
  @override
  _PedidoScreenState createState() => _PedidoScreenState();
}

class _PedidoScreenState extends State<PedidoScreen> {
  final ProductService _productService = ProductService();
  final PedidoService _pedidoService = PedidoService();
  final ClienteService _clienteService = ClienteService();
  List<dynamic> _products = [];
  List<Map<String, dynamic>> _selectedProducts = [];
  bool _isLoading = true;
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _nitController = TextEditingController();
  Map<String, dynamic>? _clienteSeleccionado;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token!;
      final idSucursal = authProvider.sucursalId!;

      final products = await _productService.fetchProducts(token, idSucursal);
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar productos: ${e.toString()}')),
      );
    }
  }

  Future<void> _buscarCliente() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token!;
    final nit = _nitController.text.trim();

    if (nit.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor ingresa el NIT del cliente')),
      );
      return;
    }

    try {
      final cliente = await _clienteService.fetchCliente(token, nit);
      setState(() {
        _clienteSeleccionado = cliente;
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

  void _addNewProduct() {
    setState(() {
      _selectedProducts.add({
        "product": null,
        "quantity": 1,
        "precio": 0.0,
        "subtotal": 0.0,
      });
    });
  }

  void _updateProduct(int index, dynamic product) {
    setState(() {
      _selectedProducts[index]["product"] = product;
      _selectedProducts[index]["precio"] = product["precioVenta"];
      _selectedProducts[index]["subtotal"] =
          _selectedProducts[index]["quantity"] * product["precioVenta"];
    });
  }

  void _updateQuantity(int index, int quantity) {
    setState(() {
      _selectedProducts[index]["quantity"] = quantity;
      _selectedProducts[index]["subtotal"] =
          quantity * _selectedProducts[index]["precio"];
    });
  }

  void _removeProduct(int index) {
    setState(() {
      _selectedProducts.removeAt(index);
    });
  }

  Future<void> _submitPedido() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (_descripcionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('La descripción es obligatoria')),
      );
      return;
    }

    if (_selectedProducts.any((p) => p["product"] == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Selecciona todos los productos antes de enviar')),
      );
      return;
    }

    if (_clienteSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Por favor selecciona un cliente antes de enviar')),
      );
      return;
    }

    // Crear el detalle del pedido
    final detalle = _selectedProducts.map((p) {
      return {
        "id_producto": p["product"]["id_producto"],
        "cantidal": p["quantity"],
      };
    }).toList();

    try {
      await _pedidoService.enviarPedido(
        authProvider.email!,
        _descripcionController.text,
        _clienteSeleccionado!["id"], // Aquí se pasa el id_cliente
        detalle,
        authProvider.token!,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pedido enviado exitosamente')),
      );
      Navigator.pop(context); // Regresar al Dashboard
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar pedido: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Pedido'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _nitController,
                      decoration: InputDecoration(
                        labelText: 'Buscar Cliente por NIT',
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
                    SizedBox(height: 20),
                    TextField(
                      controller: _descripcionController,
                      decoration: InputDecoration(
                        labelText: 'Descripción del pedido',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    ..._selectedProducts.asMap().entries.map((entry) {
                      final index = entry.key;
                      final selectedProduct = entry.value;
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownButton<dynamic>(
                                hint: Text('Selecciona un producto'),
                                value: selectedProduct["product"],
                                items: _products.map((product) {
                                  return DropdownMenuItem<dynamic>(
                                    value: product,
                                    child: Text(product["nombre"]),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  _updateProduct(index, value);
                                },
                              ),
                              SizedBox(height: 10),
                              Text('Precio: \$${selectedProduct["precio"]}'),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Cantidad:'),
                                  IconButton(
                                    icon: Icon(Icons.remove),
                                    onPressed: () {
                                      if (selectedProduct["quantity"] > 1) {
                                        _updateQuantity(index,
                                            selectedProduct["quantity"] - 1);
                                      }
                                    },
                                  ),
                                  Text('${selectedProduct["quantity"]}'),
                                  IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: () {
                                      _updateQuantity(index,
                                          selectedProduct["quantity"] + 1);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _removeProduct(index),
                                  ),
                                ],
                              ),
                              Text(
                                  'Subtotal: \$${selectedProduct["subtotal"]}'),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _addNewProduct,
                      child: Text('Añadir producto'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitPedido,
                      child: Text('Enviar Pedido'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
