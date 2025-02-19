// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/product_api.dart';
import '../widgets/product_card.dart';
import '../models/auth_model.dart';
import '../models/product_model.dart';
import '../widgets/app_bar_widget.dart'; // Importa el AppBar modular
import '../widgets/search_bar_widget.dart'; // Importa la barra de búsqueda modular
import '../widgets/bottom_navigation_bar_widget.dart'; // Importa la barra de navegación inferior modular

class HomePage extends StatelessWidget {
  final ProductApi productApi = ProductApi();

  @override
  Widget build(BuildContext context) {
    final authModel = Provider.of<AuthModel>(context);

    return Scaffold(
      appBar: buildAppBar(context, authModel), // Usa el AppBar modular
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mostrar el saludo solo si el usuario está autenticado
          if (authModel.isAuthenticated)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Bienvenido, ${authModel.user?.nombre ?? ''}",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          // Mostrar los productos
          Expanded(
            child: _buildProductList(context),
          ),
        ],
      ),
      bottomNavigationBar: buildBottomNavigationBar(context, authModel), // Usa la barra de navegación inferior modular
    );
  }

  // Método para construir la lista de productos
  Widget _buildProductList(BuildContext context) {
    return FutureBuilder<List<Product>>(
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
              return ProductCard(
                product: product,
                onTap: () {
                  // Navegar a la pantalla de detalles del producto
                  Navigator.pushNamed(
                    context,
                    '/product-detail',
                    arguments: product.idProducto,
                  );
                },
              );
            },
          );
        }
      },
    );
  }
}