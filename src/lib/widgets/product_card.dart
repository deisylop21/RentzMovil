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
      child: Container(
        width: 160, // Ancho fijo para cada tarjeta
        child: Card(
          clipBehavior: Clip.antiAlias, // Asegura que nada se salga de los bordes de la tarjeta
          margin: EdgeInsets.all(8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Contenedor con altura fija para la imagen
              Container(
                height: 160, // Altura fija para todas las imágenes
                width: double.infinity,
                child: Image.network(
                  product.urlImagenPrincipal,
                  fit: BoxFit.cover, // Ajusta la imagen para cubrir el espacio
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey[400],
                        ),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Contenedor con altura fija para la información del producto
              Container(
                height: 100, // Altura fija para la sección de información2323
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.nombreProducto,
                      style: AppTheme.titleStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis, // Trunca el texto si es muy largo
                    ),
                    SizedBox(height: 4),
                    Text(
                      product.categoria,
                      style: AppTheme.subtitleStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Expanded(
                      child: Row(
                        children: [
                          if (product.esPromocion)
                            Text(
                              "\$${product.precioPromocion}",
                              style: AppTheme.promotionalPriceStyle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          if (product.esPromocion) SizedBox(width: 8),
                          if (product.esPromocion)
                            Expanded(
                              child: Text(
                                "\$${product.precio}",
                                style: AppTheme.oldPriceStyle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          else
                            Expanded(
                              child: Text(
                                "\$${product.precio}",
                                style: AppTheme.priceStyle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}