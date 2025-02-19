// lib/pages/product_detail_page.dart
import 'package:flutter/material.dart';
import '../api/product_api.dart';
import '../models/product_model.dart';

class ProductDetailPage extends StatelessWidget {
  final int productId;

  const ProductDetailPage({required this.productId});

  @override
  Widget build(BuildContext context) {
    final ProductApi productApi = ProductApi();

    return Scaffold(
      appBar: AppBar(
        title: Text("Detalles del Producto"),
        centerTitle: true,
      ),
      body: FutureBuilder<Product>(
        future: productApi.fetchProductDetails(productId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return Center(child: Text("No se encontraron detalles del producto"));
          } else {
            final product = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mostrar las imágenes principales en un PageView
                  SizedBox(
                    height: 300,
                    child: PageView.builder(
                      itemCount: product.imagenes.isNotEmpty
                          ? product.imagenes.length + 1 // +1 para incluir la imagen principal
                          : 1, // Solo la imagen principal si no hay imágenes adicionales
                      itemBuilder: (context, index) {
                        if (index == 0 || product.imagenes.isEmpty) {
                          // Imagen principal
                          return Image.network(
                            product.urlImagenPrincipal,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(child: Icon(Icons.image_not_supported));
                            },
                          );
                        } else {
                          // Imágenes adicionales
                          return Image.network(
                            product.imagenes[index - 1],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(child: Icon(Icons.image_not_supported));
                            },
                          );
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.nombreProducto,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(product.descripcion),
                        SizedBox(height: 16),
                        Text(
                          "Categoría: ${product.categoria}",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "\$${product.precio}",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Aquí puedes agregar lógica para añadir el producto al carrito
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Producto añadido al carrito")),
                                );
                              },
                              child: Text("Añadir al Carrito"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}