import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/favorite_model.dart';
import '../theme/app_theme.dart';

class FavoriteCard extends StatelessWidget {
  final FavoriteProduct favorite;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const FavoriteCard({
    Key? key,
    required this.favorite,
    required this.onDelete,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      color: AppTheme.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.grey.withOpacity(0.3)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Hero(
              tag: 'favorite_${favorite.idFavorito}',
              child: CachedNetworkImage(
                imageUrl: favorite.urlImagenPrincipal,
                fit: BoxFit.cover,
                placeholder: (context, url) => const _ImagePlaceholder(),
                errorWidget: (context, url, error) => const _ImageError(),
              ),
            ),
          ),
        ),
        if (favorite.esPromocion)
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'PROMOCIÓN',
                style: TextStyle(
                  color: AppTheme.White,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            favorite.nombreProducto,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.text,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (favorite.esPromocion && favorite.precioPromocion != null)
                    Text(
                      '\$${favorite.precio}',
                      style: AppTheme.oldPriceStyle,
                    ),
                  Text(
                    '\$${favorite.esPromocion ? favorite.precioPromocion : favorite.precio}',
                    style: favorite.esPromocion
                        ? AppTheme.promotionalPriceStyle
                        : AppTheme.priceStyle,
                  ),
                ],
              ),
              FilledButton.tonalIcon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Eliminar'),
                style: FilledButton.styleFrom(
                  foregroundColor: AppTheme.errorColor,
                  backgroundColor: AppTheme.errorColor.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.lightTurquoise,
      child: Center(
        child: CircularProgressIndicator(
          color: AppTheme.accentColor,
        ),
      ),
    );
  }
}

class _ImageError extends StatelessWidget {
  const _ImageError();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.lightTurquoise,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
              Icons.error_outline,
              size: 40,
              color: AppTheme.errorColor
          ),
          const SizedBox(height: 8),
          Text(
            'Error al cargar la imagen',
            style: TextStyle(color: AppTheme.errorColor),
          ),
        ],
      ),
    );
  }
}