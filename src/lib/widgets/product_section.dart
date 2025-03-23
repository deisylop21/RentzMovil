import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../api/favorite_api.dart';
import '../theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:provider/provider.dart';
import '../models/auth_model.dart';

class ProductSection extends StatefulWidget {
  final List<Product> products;

  const ProductSection({
    required this.products,
    Key? key,
  }) : super(key: key);

  @override
  State<ProductSection> createState() => _ProductSectionState();
}

class HeartbeatIconButton extends StatefulWidget {
  final bool isActive;
  final VoidCallback onPressed;
  final Color? activeColor;

  const HeartbeatIconButton({
    Key? key,
    required this.isActive,
    required this.onPressed,
    this.activeColor,
  }) : super(key: key);

  @override
  State<HeartbeatIconButton> createState() => _HeartbeatIconButtonState();
}

class _HeartbeatIconButtonState extends State<HeartbeatIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.4)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.4, end: 0.9)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.9, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30.0,
      ),
    ]).animate(_controller);

    _rotationAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 0.1)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.1, end: -0.1)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.1, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30.0,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _triggerAnimation() {
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: IconButton(
              icon: Icon(
                widget.isActive ? Icons.favorite : Icons.favorite_border,
                color: widget.isActive
                    ? widget.activeColor ?? Colors.red
                    : Colors.grey[600],
              ),
              onPressed: () {
                _triggerAnimation();
                widget.onPressed();
              },
              tooltip: "Añadir a favoritos",
            ),
          ),
        );
      },
    );
  }
}

class _ProductSectionState extends State<ProductSection> {
  final FavoriteApi _favoriteApi = FavoriteApi();
  Map<int, bool> _favoriteStates = {};

  Future<void> _addToFavorites(Product product, BuildContext context) async {
    final authModel = Provider.of<AuthModel>(context, listen: false);
    final token = authModel.token;

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Text('Debes iniciar sesión para agregar a favoritos '),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: const Text(
                  'Iniciar sesión',
                  style: TextStyle(
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    try {
      // Indicador de carga
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Text('Agregando a favoritos...'),
              ],
            ),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.blue,
          ),
        );
      }

      final response = await _favoriteApi.addToFavorite(token, product.idProducto);

      if (response['success'] == true) {
        setState(() {
          _favoriteStates[product.idProducto] = true;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Producto agregado a favoritos'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al agregar a favoritos: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: widget.products.length,
      itemBuilder: (context, index) {
        final product = widget.products[index];
        final PageController _pageController = PageController();
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: 180,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: product.imagenes.isNotEmpty
                          ? product.imagenes.length + 1
                          : 1,
                      itemBuilder: (context, imageIndex) {
                        final imageUrl = imageIndex == 0
                            ? product.urlImagenPrincipal
                            : product.imagenes[imageIndex - 1];
                        return ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            placeholder: (context, url) => Container(
                              color: AppTheme.grey,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppTheme.grey,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.image_not_supported,
                                      size: 50, color: Colors.grey),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Imagen no disponible",
                                    style: TextStyle(color: AppTheme.grey),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: SmoothPageIndicator(
                        controller: _pageController,
                        count: product.imagenes.isNotEmpty
                            ? product.imagenes.length + 1
                            : 1,
                        effect: WormEffect(
                          dotColor: AppTheme.grey,
                          activeDotColor: AppTheme.primaryColor,
                          dotHeight: 6,
                          dotWidth: 6,
                        ),
                      ),
                    ),
                  ),
                ],
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
                        HeartbeatIconButton(
                          isActive: _favoriteStates[product.idProducto] == true,
                          onPressed: () => _addToFavorites(product, context),
                          activeColor: Colors.red,
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