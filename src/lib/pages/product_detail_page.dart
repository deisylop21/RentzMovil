import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/product_api.dart';
import '../api/cart_api.dart';
import '../models/product_model.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import '../models/auth_model.dart';
import '../theme/app_theme.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../widgets/quantity_selector2.dart';

class ProductDetailPage extends StatefulWidget {
  final int productId;

  const ProductDetailPage({required this.productId});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}


class _ProductDetailPageState extends State<ProductDetailPage> {
  bool _isSharing = false;
  int cantidad = 1;
  bool isLoading = false;
  final CartApi cartApi = CartApi();
  final PageController _pageController = PageController();
  final ProductApi productApi = ProductApi();
  Future<Product>? _productFuture;

  @override
  void initState() {
    super.initState();
    _productFuture = productApi.fetchProductDetails(widget.productId);
  }

  Future<void> _shareProduct(Product product) async {
    if (!Platform.isAndroid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Compartir solo está disponible en Android'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }
    setState(() => _isSharing = true);
    try {
      // Crear el deep link
      final productUrl = 'https://rentzmx.com/producto/${product.idProducto}';
      final shareText = '''
¡Mira este increíble producto en Rentz!
📦 ${product.nombreProducto}
📝 ${product.descripcion}
💰 Precio: \$${product.precio}${product.esPromocion ? '🔥 ¡En promoción!: \$${product.precioPromocion}' : ''}
    📦 Cantidad disponible: ${product.cantidadActual}
    Ver producto: $productUrl
    ¡Renta sin estrés con Rentz!
    ''';
      await const MethodChannel('app.channel.shared.data').invokeMethod('shareText', {
        'text': shareText,
        'title': 'Compartir producto',
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al compartir: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      setState(() => _isSharing = false);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Método para actualizar la cantidad sin recargar toda la página
  void _updateQuantity(int value) {
    // Asegurar que no exceda la cantidad disponible
    setState(() {
      cantidad = value;
    });
  }

  Widget _buildImageSlider(Product product) {
    return Stack(
      children: [
        Container(
          height: 350,
          child: PageView.builder(
            controller: _pageController,
            itemCount: product.imagenes.isNotEmpty
                ? product.imagenes.length + 1
                : 1,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor, // Adaptado para modo oscuro
                ),
                child: Hero(
                  tag: 'product-${product.idProducto}',
                  child: Image.network(
                    index == 0 || product.imagenes.isEmpty
                        ? product.urlImagenPrincipal
                        : product.imagenes[index - 1],
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 64,
                          color: AppTheme.primaryColor,
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Center(
            child: SmoothPageIndicator(
              controller: _pageController,
              count: product.imagenes.isNotEmpty ? product.imagenes.length + 1 : 1,
              effect: WormEffect(
                dotColor: AppTheme.grey, // Usar color dinámico
                activeDotColor: AppTheme.primaryColor,
                dotHeight: 8,
                dotWidth: 8,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authModel = Provider.of<AuthModel>(context, listen: false);
    return FutureBuilder<Product>(
      future: _productFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppTheme.primaryColor,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: AppTheme.White),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
            ),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppTheme.primaryColor,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: AppTheme.White),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: AppTheme.errorColor),
                  SizedBox(height: 16),
                  Text(
                    "Error al cargar el producto",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.text),
                  ),
                  SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.grey),
                  ),
                ],
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppTheme.primaryColor,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: AppTheme.White),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Center(
              child: Text(
                "No se encontraron detalles del producto",
                style: TextStyle(fontSize: 16, color: AppTheme.grey),
              ),
            ),
          );
        }
        final product = snapshot.data!;
        return Scaffold(
          backgroundColor: AppTheme.backgroundColor, // Adaptado para modo oscuro
          appBar: AppBar(
            backgroundColor: AppTheme.primaryColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: AppTheme.White),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: _isSharing
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.White),
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(Icons.share_outlined, color: AppTheme.White),
                onPressed: _isSharing ? null : () => _shareProduct(product),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImageSlider(product),
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    product.categoria,
                                    style: TextStyle(
                                      color: AppTheme.text,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Text(
                              product.nombreProducto,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.text, // Adaptado para modo oscuro
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "\$${product.esPromocion && product.precioPromocion != null ? product.precioPromocion : product.precio}",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.text,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Descripción",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.text, // Adaptado para modo oscuro
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              product.descripcion,
                              style: TextStyle(
                                fontSize: 16,
                                color: AppTheme.text, // Adaptado para modo oscuro
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor, // Adaptado para modo oscuro
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.black.withOpacity(0.05), // Sombra sutil
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    QuantitySelector(
                      initialValue: cantidad,
                      onQuantityChanged: (value) {
                        if (product.cantidadActual >= value) {
                          _updateQuantity(value);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Solo hay ${product.cantidadActual} unidades disponibles",
                                style: TextStyle(color: AppTheme.White),
                              ),
                              backgroundColor: AppTheme.errorColor,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          _updateQuantity(product.cantidadActual);
                        }
                      },
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                if (authModel.token == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Inicia sesión para usar el Carrito",
                                        style: TextStyle(color: AppTheme.White),
                                      ),
                                      backgroundColor: AppTheme.errorColor,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  return;
                                }
                                try {
                                  setState(() => isLoading = true);
                                  await cartApi.addToCart(
                                    authModel.token!,
                                    product.idProducto,
                                    cantidad,
                                  );
                                  setState(() => isLoading = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "¡Producto añadido al carrito!",
                                        style: TextStyle(color: AppTheme.White),
                                      ),
                                      backgroundColor: AppTheme.successColor,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                } catch (e) {
                                  setState(() => isLoading = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Error: $e",
                                        style: TextStyle(color: AppTheme.White),
                                      ),
                                      backgroundColor: AppTheme.errorColor,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.White),
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                "Añadir al carrito",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppTheme.text,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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