import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../widgets/product_card.dart';
import '../theme/app_theme.dart';

class ProductSection extends StatelessWidget {
  final String category;
  final List<Product> products;

  const ProductSection({
    required this.category,
    required this.products,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: AppTheme.backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _getCategoryIcon(category),
                      color: AppTheme.text,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.text,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    // Implementar navegación a la vista de categoría
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 280, // Altura fija para el contenedor
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Hero(
                  tag: 'product-${product.idProducto}',
                  child: ProductCard(
                    product: product,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/product-detail',
                        arguments: product.idProducto,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'accesorios':
        return Icons.watch;
      case 'muebles':
        return Icons.chair;
      case 'electronica':
        return Icons.devices;
      case 'decoracion':
        return Icons.home;
      case 'iluminacion':
        return Icons.light;
      case 'herramientas':
        return Icons.build;
      default:
        return Icons.category;
    }
  }
}