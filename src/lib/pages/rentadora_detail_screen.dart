import 'package:flutter/material.dart';
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
  bool _isLoading = true;
  String? _error;
  Rentadora? _rentadoraDetail;

  @override
  void initState() {
    super.initState();
    _fetchRentadoraDetail();
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

  Widget _buildContent() {
    final rentadora = _rentadoraDetail!;

    return CustomScrollView(
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
            child: Text(
              'Productos disponibles',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ),
        _buildProductsGrid(rentadora),
      ],
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200.0,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.rentadoraNombre,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 8.0,
                color: Colors.black54,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        background: _rentadoraDetail?.urlBanner != null
            ? CachedNetworkImage(
          imageUrl: _rentadoraDetail!.urlBanner!,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[300],
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: AppTheme.primaryColor.withOpacity(0.3),
            child: const Icon(Icons.image_not_supported, size: 50, color: Colors.white),
          ),
        )
            : Container(
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
        ),
      ),
    );
  }

  Widget _buildRentadoraHeader(Rentadora rentadora) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
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
          ),
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
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${rentadora.puntuacion ?? 0.0}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.location_on,
                      color: Colors.grey[600],
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'CP: ${rentadora.codigoPostal ?? 'No disponible'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: Colors.grey[600],
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${rentadora.horarioAbre ?? '00:00'} - ${rentadora.horarioCierra ?? '00:00'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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
          const Text(
            'Acerca de',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            rentadora.descripcion ?? 'No hay descripción disponible',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[800],
              height: 1.4,
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
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
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            final producto = productos[index];
            // Convertir ProductoRentadora a Product
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
              imagenes: [], // Aquí puedes agregar las imágenes si las tienes
            );

            return ProductCard(
              product: product,
              onTap: () {
                _navigateToProductDetail(product);
              },
            );
          },
          childCount: productos.length,
        ),
      ),
    );
  }

  Future _navigateToProductDetail(Product product) async {
    try {
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppTheme.primaryColor),
            ),
          );
        },
      );

      // Obtener los detalles del producto
      final productDetails = await _productApi.fetchProductDetails(product.idProducto);

      // Cerrar el indicador de carga
      Navigator.of(context, rootNavigator: true).pop();

      // Navegar a la página de detalles
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailPage(productId: productDetails.idProducto),
        ),
      );
    } catch (e) {
      // Cerrar el indicador de carga en caso de error
      Navigator.of(context, rootNavigator: true).pop();

      // Mostrar mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar los detalles del producto: $e'),
          backgroundColor: Colors.red,
        ),
      );
      print('Error al cargar los detalles del producto: $e');
    }
  }
}