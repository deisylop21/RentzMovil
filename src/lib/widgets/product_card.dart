// lib/widgets/product_card.dart
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../theme/app_theme.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Navegar a la pantalla de detalles
      child: Card(
        margin: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Image.network(
                product.urlImagenPrincipal,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(child: Icon(Icons.image_not_supported));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.nombreProducto,
                    style: AppTheme.titleStyle,
                  ),
                  SizedBox(height: 4),
                  Text(product.categoria, style: AppTheme.subtitleStyle),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      if (product.esPromocion)
                        Text(
                          "\$${product.precioPromocion}",
                          style: AppTheme.promotionalPriceStyle,
                        ),
                      if (product.esPromocion) SizedBox(width: 8),
                      if (product.esPromocion)
                        Text(
                          "\$${product.precio}",
                          style: AppTheme.oldPriceStyle,
                        )
                      else
                        Text(
                          "\$${product.precio}",
                          style: AppTheme.priceStyle,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}