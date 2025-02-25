import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../api/product_api.dart';
import '../widgets/product_card.dart';
import '../models/auth_model.dart';
import '../models/product_model.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/bottom_navigation_bar_widget.dart';
import '../theme/app_theme.dart';
import '../models/profile_model.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final ProductApi productApi = ProductApi();
  List<Product> _products = [];
  Map<String, List<Product>> _categorizedProducts = {};
  String _searchQuery = '';
  bool _isLoading = true;
  String? _error;
  late ScrollController _scrollController;
  bool _showScrollToTop = false;
  String? _selectedCategory;
  final _filterScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _fetchProducts();
  }

  void _scrollListener() {
    if (_scrollController.offset >= 400) {
      if (!_showScrollToTop) {
        setState(() => _showScrollToTop = true);
      }
    } else {
      if (_showScrollToTop) {
        setState(() => _showScrollToTop = false);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _filterScrollController.dispose();
    super.dispose();
  }

  Future<void> _scrollToTop() async {
    await _scrollController.animateTo(
      0,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _fetchProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final products = await productApi.fetchProducts();

      if (mounted) {
        setState(() {
          _products = products;
          _categorizedProducts = _groupByCategory(products);
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
      print('Error fetching products: $e');
    }
  }

  Map<String, List<Product>> _groupByCategory(List<Product> products) {
    Map<String, List<Product>> categorized = {};
    for (var product in products) {
      if (product.categoria.isEmpty) continue;
      if (!categorized.containsKey(product.categoria)) {
        categorized[product.categoria] = [];
      }
      categorized[product.categoria]!.add(product);
    }
    return Map.fromEntries(
        categorized.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key))
    );
  }

  Widget _buildWelcomeHeader(AuthModel authModel) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bienvenido,',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      authModel.user?.nombre ?? 'Usuario',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

            ],
          ),
          SizedBox(height: 16),

        ],
      ),
    );
  }
  Widget _buildAnimatedCategoryFilters() {
    return Container(
      height: 60,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        controller: _filterScrollController,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categorizedProducts.length + 1, // +1 for "Todos" option
        itemBuilder: (context, index) {
          final isAllCategory = index == 0;
          final category = isAllCategory ? "Todos" : _categorizedProducts.keys.elementAt(index - 1);
          final isSelected = isAllCategory ? _selectedCategory == null : category == _selectedCategory;

          return Padding(
            padding: EdgeInsets.only(right: 8),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedCategory = isAllCategory ? null : category;
                      // Filter products based on selection
                      if (!isAllCategory) {
                        _categorizedProducts = _groupByCategory(
                          _products.where((product) =>
                          product.categoria == category
                          ).toList(),
                        );
                      } else {
                        _categorizedProducts = _groupByCategory(_products);
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(25),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : Colors.grey[300]!,
                      ),
                      boxShadow: isSelected
                          ? [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.4),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        )
                      ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isAllCategory
                              ? Icons.apps
                              : _getCategoryIcon(category),
                          size: 20,
                          color: isSelected
                              ? Colors.white
                              : Colors.grey[600],
                        ),
                        SizedBox(width: 8),
                        Text(
                          category,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.grey[600],
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
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
  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Column(
          children: List.generate(3, (index) =>
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 150,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: NeverScrollableScrollPhysics(),
                      child: Row(
                        children: List.generate(3, (index) =>
                            Container(
                              width: 160,
                              height: 200,
                              margin: EdgeInsets.only(right: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(String category, List<Product> products) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _getCategoryIcon(category),
                      color: AppTheme.primaryColor,
                    ),
                    SizedBox(width: 8),
                    Text(
                      category,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    // Implementar navegación a la vista de categoría
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [


                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 8),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Hero(
                    tag: 'product-${product.idProducto}',
                    child: ProductCard(
                      product: product,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/product-detail',
                          arguments: product.idProducto,
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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

  @override
  Widget build(BuildContext context) {
    final authModel = Provider.of<AuthModel>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: buildAppBar(
        context,
        authModel,
            (query) {
          setState(() {
            _searchQuery = query;
            if (query.isEmpty) {
              _categorizedProducts = _groupByCategory(_products);
            } else {
              _categorizedProducts = _groupByCategory(
                _products.where((product) {
                  final searchLower = query.toLowerCase();
                  return product.nombreProducto.toLowerCase().contains(searchLower) ||
                      product.categoria.toLowerCase().contains(searchLower) ||
                      product.descripcion.toLowerCase().contains(searchLower);
                }).toList(),
              );
            }
          });
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (authModel.isAuthenticated) _buildWelcomeHeader(authModel),
            _buildAnimatedCategoryFilters(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchProducts,
                color: AppTheme.primaryColor,
                child: _isLoading
                    ? _buildLoadingShimmer()
                    : _error != null
                    ? _buildErrorState()
                    : _products.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.only(bottom: 16),
                  itemCount: _categorizedProducts.length,
                  itemBuilder: (context, index) {
                    final category = _categorizedProducts.keys.elementAt(index);
                    final products = _categorizedProducts[category]!;
                    return _buildCategorySection(category, products);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _showScrollToTop
          ? FloatingActionButton(
        mini: true,
        onPressed: _scrollToTop,
        backgroundColor: AppTheme.primaryColor,
        child: Icon(Icons.arrow_upward, color: Colors.white),
      )
          : null,
      bottomNavigationBar: buildBottomNavigationBar(context, authModel),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorColor,
            ),
            SizedBox(height: 16),
            Text(
              'Oops! Algo salió mal',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              _error ?? 'No se pudieron cargar los productos',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchProducts,
              icon: Icon(Icons.refresh),
              label: Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No hay productos disponibles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Intenta refrescar la página',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}