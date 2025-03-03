import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CategoryFilters extends StatelessWidget {
  final Map<String, List> categorizedProducts;
  final String? selectedCategory;
  final Function(String?) onCategorySelected;

  const CategoryFilters({
    required this.categorizedProducts,
    required this.selectedCategory,
    required this.onCategorySelected,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categorizedProducts.length + 1,
        itemBuilder: (context, index) {
          final isAllCategory = index == 0;
          final category = isAllCategory ? "Todos" : categorizedProducts.keys.elementAt(index - 1);
          final isSelected = isAllCategory ? selectedCategory == null : category == selectedCategory;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onCategorySelected(isAllCategory ? null : category),
                  borderRadius: BorderRadius.circular(25),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
                      ),
                      boxShadow: isSelected
                          ? [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isAllCategory ? Icons.apps : _getCategoryIcon(category),
                          size: 20,
                          color: isSelected ? Colors.white : Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[600],
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
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