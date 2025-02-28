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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
        });
      }
    });
  }

  Future<void> _refreshCart() async {
    final authModel = Provider.of<AuthModel>(context, listen: false);
    setState(() {
      _cartFuture = CartApi().fetchCart(authModel.token!);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: Text("Carrito de Compras")),
        body: Center(child: Text("Debes iniciar sesión para ver el carrito")),
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
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text("El carrito está vacío"));
            } else {
              final cartItems = snapshot.data!;
              return ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return _buildCartItem(context, item);
                },
              );
            }
          },
        ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem item) {
    if (item == null) {
      return Center(child: Text("Error: Item no válido"));
    }

    return Card(
      margin: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            item.urlImagenPrincipal,
            fit: BoxFit.cover,
            height: 150,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return Center(child: Icon(Icons.image_not_supported));
            },
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
                          onPressed: () {
                            _updateQuantity(item.idCarrito, item.cantidad - 1);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            _updateQuantity(item.idCarrito, item.cantidad + 1);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total: \$${item.total}",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _deleteItem(item.idCarrito);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/renta-form',
                        arguments: item, // Enviar el objeto completo
                      );
                    },
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
