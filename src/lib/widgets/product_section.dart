import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../widgets/product_card.dart';
import '../theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math';

class ProductSection extends StatelessWidget {
  final List<Product> products;

  const ProductSection({
    required this.products,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mezclar los productos
    final shuffledProducts = List<Product>.from(products)..shuffle(Random());

    return ListView.builder(
      shrinkWrap: true, // Limita la altura del ListView al contenido
      physics: NeverScrollableScrollPhysics(), // Desactiva el scroll interno del ListView
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: shuffledProducts.length,
      itemBuilder: (context, index) {
        final product = shuffledProducts[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: CachedNetworkImage(
                  imageUrl: product.urlImagenPrincipal,
                  fit: BoxFit.cover,
                  height: 180,
                  width: double.infinity,
                  placeholder: (context, url) => Container(
                    height: 180,
                    color: AppTheme.grey,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 180,
                    color: AppTheme.grey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                        const SizedBox(height: 8),
                        Text(
                          "Imagen no disponible",
                          style: TextStyle(color: AppTheme.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            product.nombreProducto,
                            style: AppTheme.titleStyle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.favorite_border),
                          onPressed: () {
                            // Implementar llamada a la API para agregar a favoritos
                            // Ruta de la API
                          },
                          tooltip: "Añadir a favoritos",
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Precio: \$${product.precio}",
                      style: AppTheme.priceStyle,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/product-detail',
                            arguments: product.idProducto,
                          );
                        },
                        style: AppTheme.primaryButtonStyle,
                        child: const Text("Ver detalles"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}