// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/product_api.dart';
import '../widgets/product_card.dart';
import '../models/auth_model.dart';
import '../models/product_model.dart';

class HomePage extends StatelessWidget {
  final ProductApi productApi = ProductApi();

  @override
  Widget build(BuildContext context) {
    // Accedemos al modelo global
    final authModel = Provider.of<AuthModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(authModel.isAuthenticated
            ? "Bienvenido, ${authModel.user?.nombre ?? ''}"
            : "Renta de Mobiliario"),
        centerTitle: true,
        actions: [
          if (authModel.isAuthenticated)
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                // Cerramos sesión
                authModel.logout();
              },
            )
          else
            IconButton(
              icon: Icon(Icons.login),
              onPressed: () {
                // Navegamos a la pantalla de login
                Navigator.pushNamed(context, '/login');
              },
            ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: productApi.fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No hay productos disponibles"));
          } else {
            final products = snapshot.data!;
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductCard(product: product);
              },
            );
          }
        },
      ),
    );
  }
}