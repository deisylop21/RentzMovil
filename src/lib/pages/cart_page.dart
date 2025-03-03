import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/cart_api.dart';
import '../models/auth_model.dart';
import '../models/cart_model.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late Future<List<CartItem>> _cartFuture;
  bool _isAuthenticated = true;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCart();
  }

  Future<void> _initializeCart() async {
    final authModel = Provider.of<AuthModel>(context, listen: false);

    if (authModel.token == null) {
      setState(() {
        _isAuthenticated = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Debes iniciar sesión para usar el carrito")),
        );
        Navigator.pop(context);
      });
    } else {
      setState(() {
        _cartFuture = CartApi().fetchCart(authModel.token!);
        _isInitialized = true;
      });
    }
  }

  Future<void> _refreshCart() async {
    final authModel = Provider.of<AuthModel>(context, listen: false);
    if (authModel.token != null) {
      setState(() {
        _cartFuture = CartApi().fetchCart(authModel.token!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: Text("Carrito de Compras")),
        body: Center(child: Text("Debes iniciar sesión para ver el carrito")),
      );
    }

    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(title: Text("Carrito de Compras")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Carrito de Compras"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshCart,
          ),
        ],
      ),
      body: FutureBuilder<List<CartItem>>(
        future: _cartFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Error: ${snapshot.error}"),
                  ElevatedButton(
                    onPressed: _refreshCart,
                    child: Text("Reintentar"),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("El carrito está vacío"),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/products'),
                    child: Text("Ver productos"),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final item = snapshot.data![index];
              return _buildCartItem(context, item);
            },
          );
        },
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem item) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
            child: Image.network(
              item.urlImagenPrincipal,
              fit: BoxFit.cover,
              height: 150,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 150,
                  color: Colors.grey[200],
                  child: Icon(Icons.image_not_supported, size: 50),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nombreProducto,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(item.descripcion),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Cantidad: ${item.cantidad}",
                      style: TextStyle(fontSize: 16),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: item.cantidad > 1
                              ? () => _updateQuantity(item.idCarrito, item.cantidad - 1)
                              : null,
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () => _updateQuantity(item.idCarrito, item.cantidad + 1),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.esPromocion && item.precioPromocion != null)
                          Text(
                            "Precio original: \$${item.precio}",
                            style: TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                            ),
                          ),
                        Text(
                          "Total: \$${item.total}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: item.esPromocion ? Colors.green : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteItem(item.idCarrito),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        '/renta-form',
                        arguments: item, // Donde item es un CartItem válido
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(200, 45),
                    ),
                    child: Text("Rentar"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateQuantity(int idCarrito, int newQuantity) async {
    if (newQuantity < 1) return;

    try {
      final authModel = Provider.of<AuthModel>(context, listen: false);
      if (authModel.token == null) {
        throw Exception("Token de autenticación no disponible");
      }
      await CartApi().updateCartItem(authModel.token!, idCarrito, newQuantity);
      _refreshCart();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al actualizar la cantidad: $e")),
      );
    }
  }

  Future<void> _deleteItem(int idCarrito) async {
    try {
      final authModel = Provider.of<AuthModel>(context, listen: false);
      if (authModel.token == null) {
        throw Exception("Token de autenticación no disponible");
      }
      await CartApi().deleteCartItem(authModel.token!, idCarrito);
      _refreshCart();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al eliminar el producto: $e")),
      );
    }
  }

}
