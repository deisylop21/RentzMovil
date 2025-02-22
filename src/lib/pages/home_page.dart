import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/product_api.dart';
import '../widgets/product_card.dart';
import '../models/auth_model.dart';
import '../models/product_model.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/bottom_navigation_bar_widget.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ProductApi productApi = ProductApi();
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  String _searchQuery = '';
  bool _isLoading = true; // Nuevo estado para controlar la carga
  String? _error; // Nuevo estado para manejar errores

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final products = await productApi.fetchProducts();

      // Verifica si el widget sigue montado antes de actualizar el estado
      if (mounted) {
        setState(() {
          _products = products;
          _filteredProducts = products;
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
      print('Error fetching products: $e'); // Log del error
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filteredProducts = _products.where((product) {
        final nombre = product.nombreProducto ?? ''; // Evitar null
        return nombre.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    });
  }

  Widget _buildProductList() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error'),
            ElevatedButton(
              onPressed: _fetchProducts,
              child: Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_filteredProducts.isEmpty) {
      return Center(
        child: Text(
            _searchQuery.isEmpty
                ? "No hay productos disponibles"
                : "No se encontraron productos que coincidan con la búsqueda"
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchProducts,
      child: GridView.builder(
        padding: EdgeInsets.all(16.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: _filteredProducts.length,
        itemBuilder: (context, index) {
          final product = _filteredProducts[index];
          return ProductCard(
            product: product,
            onTap: () {
              Navigator.pushNamed(
                context,
                '/product-detail',
                arguments: product.idProducto,
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authModel = Provider.of<AuthModel>(context);

    return Scaffold(
      appBar: buildAppBar(context, authModel, _onSearchChanged),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (authModel.isAuthenticated)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Bienvenido, ${authModel.user?.nombre ?? ''}",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          Expanded(
            child: _buildProductList(),
          ),
        ],
      ),
      bottomNavigationBar: buildBottomNavigationBar(context, authModel),
    );
  }
}
