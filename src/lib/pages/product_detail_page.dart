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

  Future<void> _shareProduct(Product product) async {
    if (!Platform.isAndroid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Compartir solo está disponible en Android'),
          backgroundColor: Colors.red,
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
🏷️ Categoría: ${product.categoria}
🛠️ Material: ${product.material}
💰 Precio: \$${product.precio}${product.esPromocion ? '\n🔥 ¡En promoción!: \$${product.precioPromocion}' : ''}
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
          backgroundColor: Colors.red,
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
                  color: Colors.grey[100],
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
                          color: Colors.grey[400],
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
                dotColor: Colors.grey[300]!,
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
      future: productApi.fetchProductDetails(widget.productId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Color(0xFF00345E),
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.white),
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
              backgroundColor: Color(0xFF00345E),
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    "Error al cargar el producto",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Color(0xFF00345E),
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Center(
              child: Text(
                "No se encontraron detalles del producto",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ),
          );
        }

        final product = snapshot.data!;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Color(0xFF00345E),
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: _isSharing
                    ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  ),
                )
                    : Icon(Icons.share_outlined, color: Colors.white),
                onPressed: _isSharing
                    ? null
                    : () => _shareProduct(product),
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
                                      color: AppTheme.primaryColor,
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
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "\$${product.esPromocion && product.precioPromocion != null ? product.precioPromocion : product.precio}",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Descripción",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              product.descripcion,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
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
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: cantidad > 1
                                ? () => setState(() => cantidad--)
                                : null,
                            color: AppTheme.primaryColor,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              cantidad.toString(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () => setState(() => cantidad++),
                            color: AppTheme.primaryColor,
                          ),
                        ],
                      ),
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
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.red,
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
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          } catch (e) {
                            setState(() => isLoading = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Error: $e",
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.red,
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
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                            : Text(
                          "Añadir al carrito",
                          style: TextStyle(
                            fontSize: 16,
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