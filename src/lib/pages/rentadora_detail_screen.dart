import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../api/rentadora_api.dart';
import '../api/product_api.dart';
import '../models/rentadora_model.dart';
import '../models/product_model.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/error_state.dart';
import 'product_detail_page.dart';
import '../widgets/product_section.dart';

// Widget para texto expandible
class ExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;
  final TextStyle? style;

  const ExpandableText({
    Key? key,
    required this.text,
    this.maxLines = 3,
    this.style,
  }) : super(key: key);

  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedCrossFade(
          firstChild: Text(
            widget.text,
            style: widget.style ?? TextStyle(
              fontSize: 15,
              color: Colors.grey[800],
              height: 1.4,
            ),
            maxLines: widget.maxLines,
            overflow: TextOverflow.ellipsis,
          ),
          secondChild: Text(
            widget.text,
            style: widget.style ?? TextStyle(
              fontSize: 15,
              color: Colors.grey[800],
              height: 1.4,
            ),
          ),
          crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
        if (widget.text.length > 100)
          TextButton(
            onPressed: () => setState(() => _expanded = !_expanded),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _expanded ? 'Ver menos' : 'Ver más',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: AppTheme.primaryColor,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class RentadoraDetailScreen extends StatefulWidget {
  final int idRentadora;
  final String rentadoraNombre;

  const RentadoraDetailScreen({
    Key? key,
    required this.idRentadora,
    required this.rentadoraNombre,
  }) : super(key: key);

  @override
  _RentadoraDetailScreenState createState() => _RentadoraDetailScreenState();
}

class _RentadoraDetailScreenState extends State<RentadoraDetailScreen> {
  final RentadoraApi _rentadoraApi = RentadoraApi();
  final ProductApi _productApi = ProductApi();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  String? _error;
  Rentadora? _rentadoraDetail;
  bool _showBackToTop = false;
  double _titleOpacity = 1.0;

  @override
  void initState() {
    super.initState();
    _fetchRentadoraDetail();
    _scrollController.addListener(_onScroll);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  void _onScroll() {
    // Control del botón "volver arriba"
    if (_scrollController.offset > 200 && !_showBackToTop) {
      setState(() => _showBackToTop = true);
    } else if (_scrollController.offset <= 200 && _showBackToTop) {
      setState(() => _showBackToTop = false);
    }

    // Control de la opacidad del título
    final double offset = _scrollController.offset;
    final double opacity = 1 - (offset / 150).clamp(0.0, 1.0);
    if (_titleOpacity != opacity) {
      setState(() => _titleOpacity = opacity);
    }
  }
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchRentadoraDetail() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final rentadora = await _rentadoraApi.fetchRentadoraDetail(widget.idRentadora);

      if (mounted) {
        setState(() {
          _rentadoraDetail = rentadora;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
      print('Error fetching rentadora detail: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _showBackToTop ? _buildFloatingActionButton() : null,
      body: _isLoading
          ? const LoadingShimmer()
          : _error != null
          ? ErrorState(
        errorMessage: _error ?? 'No se pudo cargar la información',
        onRetry: _fetchRentadoraDetail,
      )
          : _buildContent(),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      mini: true,
      backgroundColor: AppTheme.primaryColor,
      onPressed: () {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      },
      child: const Icon(Icons.arrow_upward, color: Colors.white),
    );
  }

  Widget _buildContent() {
    final rentadora = _rentadoraDetail!;

    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildAppBar(),
        SliverToBoxAdapter(
          child: _buildRentadoraHeader(rentadora),
        ),
        SliverToBoxAdapter(
          child: _buildRentadoraInfo(rentadora),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Productos disponibles',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${rentadora.productos?.length ?? 0} productos',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildProductsGrid(rentadora),
      ],
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 250.0,
      pinned: true,
      elevation: 0,
      backgroundColor: AppTheme.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true, // Centrar el título
        title: Opacity(
          opacity: _titleOpacity,
          child: Text(
            widget.rentadoraNombre,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              shadows: [
                Shadow(
                  blurRadius: 8.0,
                  color: Colors.black54,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            _rentadoraDetail?.urlBanner != null
                ? _buildBannerImage()
                : _buildDefaultBanner(),
            _buildGradientOverlay(),
          ],
        ),
      ),
    );
  }
  Widget _buildBannerImage() {
    return CachedNetworkImage(
      imageUrl: _rentadoraDetail!.urlBanner!,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey[300],
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Colors.white),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: AppTheme.primaryColor.withOpacity(0.3),
        child: const Icon(
          Icons.image_not_supported,
          size: 50,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDefaultBanner() {
    return Container(
      color: AppTheme.primaryColor.withOpacity(0.8),
      child: Center(
        child: Text(
          widget.rentadoraNombre.substring(0, 1).toUpperCase(),
          style: const TextStyle(
            fontSize: 60,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.5),
          ],
        ),
      ),
    );
  }

  Widget _buildRentadoraHeader(Rentadora rentadora) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildLogoContainer(rentadora),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rentadora.business,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.star,
                  '${rentadora.puntuacion?.toStringAsFixed(1) ?? "0.0"}',
                  Colors.amber,
                ),
                const SizedBox(height: 4),
                _buildInfoRow(
                  Icons.location_on,
                  'CP: ${rentadora.codigoPostal ?? 'No disponible'}',
                  Colors.grey[600]!,
                ),
                const SizedBox(height: 4),
                _buildInfoRow(
                  Icons.access_time,
                  '${rentadora.horarioAbre ?? '00:00'} - ${rentadora.horarioCierra ?? '00:00'}',
                  Colors.grey[600]!,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoContainer(Rentadora rentadora) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: rentadora.urlLogo,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[200],
            child: Icon(
              Icons.store,
              size: 40,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 16,
        ),
        const SizedBox(width: 4),
        Expanded(  // Añadido Expanded para manejar textos largos
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.2,  // Mejor espaciado vertical
            ),
            overflow: TextOverflow.ellipsis,  // Manejo de desbordamiento
          ),
        ),
      ],
    );
  }

  Widget _buildRentadoraInfo(Rentadora rentadora) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Acerca de',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ExpandableText(
            text: rentadora.descripcion ?? 'No hay descripción disponible',
            maxLines: 3,  // Ajustable según necesidades
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[800],
              height: 1.4,
              letterSpacing: 0.2,  // Mejor legibilidad
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsGrid(Rentadora rentadora) {
    final productos = rentadora.productos ?? [];

    if (productos.isEmpty) {
      return SliverToBoxAdapter(
        child: _buildEmptyProductsState(),
      );
    }

    // Organizamos los productos por categoría
    Map<String, List<dynamic>> categorizedProducts = {};
    for (var producto in productos) {
      if (!categorizedProducts.containsKey(producto.categoria)) {
        categorizedProducts[producto.categoria] = [];
      }
      categorizedProducts[producto.categoria]!.add(producto);
    }

    // Retornamos un SliverList que contiene ProductSection para cada categoría
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final category = categorizedProducts.keys.elementAt(index);
          final products = categorizedProducts[category]!.map((producto) {
            return Product(
              idProducto: producto.idProducto,
              nombreProducto: producto.nombreProducto,
              categoria: producto.categoria,
              cantidadActual: producto.cantidadActual,
              precio: producto.precio,
              descripcion: producto.descripcion,
              material: producto.material,
              urlImagenPrincipal: producto.urlImagenPrincipal,
              esPromocion: producto.esPromocion == 1,
              precioPromocion: producto.precioPromocion,
              imagenes: [],
            );
          }).toList();

          return ProductSection(
            category: category,
            products: products,
          );
        },
        childCount: categorizedProducts.length,
      ),
    );
  }

  Widget _buildEmptyProductsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay productos disponibles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vuelve más tarde para ver nuevos productos',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  int _calculateCrossAxisCount(double width) {
    // Lógica responsiva mejorada para diferentes tamaños de pantalla
    if (width > 1200) return 4;      // Desktop grande
    if (width > 900) return 3;       // Desktop/Tablet horizontal
    if (width > 600) return 2;       // Tablet vertical
    return 2;                        // Móvil
  }

  double _calculateAspectRatio(double width) {
    // Ajuste del aspect ratio según el dispositivo
    if (width > 1200) return 0.85;   // Desktop grande
    if (width > 900) return 0.80;    // Desktop/Tablet horizontal
    if (width > 600) return 0.75;    // Tablet vertical
    return 0.70;                     // Móvil - más alto para mejor visualización
  }

  Widget _buildProductItem(dynamic producto) {
    final product = Product(
      idProducto: producto.idProducto,
      nombreProducto: producto.nombreProducto,
      categoria: producto.categoria,
      cantidadActual: producto.cantidadActual,
      precio: producto.precio,
      descripcion: producto.descripcion,
      material: producto.material,
      urlImagenPrincipal: producto.urlImagenPrincipal,
      esPromocion: producto.esPromocion == 1,
      precioPromocion: producto.precioPromocion,
      imagenes: [],
    );

    return Hero(
      tag: 'product-${product.idProducto}',  // Animación Hero para transiciones suaves
      child: ProductCard(
        product: product,
        onTap: () => _navigateToProductDetail(product),
      ),
    );
  }

  Future<void> _navigateToProductDetail(Product product) async {
    // Mostramos un indicador de progreso en la parte inferior
    if (!mounted) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            const Text('Cargando producto...'),
          ],
        ),
        duration: const Duration(seconds: 0),
        behavior: SnackBarBehavior.floating,
      ),
    );

    try {
      final productDetails = await _productApi.fetchProductDetails(product.idProducto);

      if (!mounted) return;

      // Ocultamos el SnackBar si aún está visible
      scaffoldMessenger.hideCurrentSnackBar();

      // Navegamos a la página de detalles
      await Navigator.push(
        context,
        _createPageRoute(productDetails),
      );
    } catch (e) {
      if (!mounted) return;

      // Ocultamos el SnackBar de carga
      scaffoldMessenger.hideCurrentSnackBar();

      // Mostramos el error
      _showErrorSnackBar(e.toString(), product);
    }
  }

  Future<void> _showLoadingDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(AppTheme.primaryColor),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Cargando producto...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  PageRouteBuilder _createPageRoute(dynamic productDetails) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          ProductDetailPage(productId: productDetails.idProducto),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Transición suave y profesional
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }

  void _showErrorSnackBar(String error, Product product) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Error al cargar los detalles del producto: $error',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Reintentar',
          textColor: Colors.white,
          onPressed: () => _navigateToProductDetail(product),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('isLoading', _isLoading));
    properties.add(StringProperty('error', _error));
    properties.add(DiagnosticsProperty<bool>('showBackToTop', _showBackToTop));
    properties.add(DiagnosticsProperty<double>('titleOpacity', _titleOpacity));
    properties.add(DiagnosticsProperty<Rentadora?>('rentadoraDetail', _rentadoraDetail));
  }
}