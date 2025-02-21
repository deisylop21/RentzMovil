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

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final products = await productApi.fetchProducts();
      setState(() {
        _products = products;
        _filteredProducts = products;
      });
    } catch (e) {
      // Manejar el error si es necesario
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filteredProducts = _products
          .where((product) =>
          product.nombreProducto.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    });
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

  Widget _buildProductList() {
    if (_filteredProducts.isEmpty) {
      return Center(child: Text("No hay productos disponibles"));
    } else {
      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
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
      );
    }
  }
}