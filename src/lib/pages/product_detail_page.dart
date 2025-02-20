import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/product_api.dart';
import '../api/cart_api.dart';
import '../models/product_model.dart';
import '../models/auth_model.dart';

class ProductDetailPage extends StatefulWidget {
  final int productId;

  const ProductDetailPage({required this.productId});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int cantidad = 1;
  bool isLoading = false;
  final CartApi cartApi = CartApi();

  @override
  Widget build(BuildContext context) {
    final ProductApi productApi = ProductApi();
    final authModel = Provider.of<AuthModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text("Detalles del Producto"),
        centerTitle: true,
      ),
      body: FutureBuilder<Product>(
        future: productApi.fetchProductDetails(widget.productId),
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
                  SizedBox(
                    height: 300,
                    child: PageView.builder(
                      itemCount: product.imagenes.isNotEmpty
                          ? product.imagenes.length + 1
                          : 1,
                      itemBuilder: (context, index) {
                        if (index == 0 || product.imagenes.isEmpty) {
                          return Image.network(
                            product.urlImagenPrincipal,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(child: Icon(Icons.image_not_supported));
                            },
                          );
                        } else {
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
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove),
                                  onPressed: () {
                                    if (cantidad > 1) {
                                      setState(() {
                                        cantidad--;
                                      });
                                    }
                                  },
                                ),
                                Text(
                                  cantidad.toString(),
                                  style: TextStyle(fontSize: 18),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: () {
                                    setState(() {
                                      cantidad++;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () async {
                            if (authModel.token == null) { // Validación del token
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Inicia sesión para usar el Carrito.")),
                              );
                              return;
                            }

                            try {
                              setState(() {
                                isLoading = true;
                              });

                              await cartApi.addToCart(
                                authModel.token!, // El token ya no será null aquí
                                product.idProducto,
                                cantidad,
                              );

                              setState(() {
                                isLoading = false;
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Producto añadido al carrito")),
                              );
                            } catch (e) {
                              setState(() {
                                isLoading = false;
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Error: $e")),
                              );
                            }
                          },
                          child: Text("Añadir al carrito"),
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