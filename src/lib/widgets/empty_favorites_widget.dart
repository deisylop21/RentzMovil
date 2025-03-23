import 'package:flutter/material.dart';

class EmptyFavorites extends StatelessWidget {
  final VoidCallback onExplore;

  const EmptyFavorites({
    Key? key,
    required this.onExplore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_outline,
            size: 80,
            color: colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes favoritos guardados',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Explora productos y guarda tus favoritos',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onExplore,
            icon: const Icon(Icons.shopping_bag_outlined),
            label: const Text('Explorar productos'),
          ),
        ],
      ),
    );
  }
}