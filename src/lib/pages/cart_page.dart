// lib/pages/cart_page.dart
import 'package:flutter/material.dart';

class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Carrito de Compras"),
      ),
      body: Center(
        child: Text("Aquí estará el contenido del carrito"),
      ),
    );
  }
}
