import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../api/product_api.dart';
import '../api/rentadora_api.dart';
import '../widgets/product_card.dart';
import '../models/auth_model.dart';
import '../models/product_model.dart';
import '../models/rentadora_model.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/bottom_navigation_bar_widget.dart';
import '../theme/app_theme.dart';
import '../widgets/category_filters.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/error_state.dart';
import '../widgets/empty_state.dart';
import '../widgets/product_section.dart';
import '../widgets/rentadoras_carousel.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final ProductApi productApi = ProductApi();
  final RentadoraApi rentadoraApi = RentadoraApi();
  List<Product> _products = [];
  Map<String, List<Product>> _categorizedProducts = {};
  String _searchQuery = '';
  bool _isLoading = true;
  String? _error;
  late ScrollController _scrollController;
  bool _showScrollToTop = false;
  String? _selectedCategory;
  List<Rentadora> _rentadoras = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _fetchData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _scrollToTop() async {
    await _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _fetchData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Fetch products and rentadoras in parallel for better performance
      final productsResult = productApi.fetchProducts();
      final rentadorasResult = rentadoraApi.fetchRentadoras();

      final products = await productsResult;
      final rentadoras = await rentadorasResult;

      if (mounted) {
        setState(() {
          _products = products;
          _categorizedProducts = _groupByCategory(products);
          _rentadoras = rentadoras;
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
      print('Error fetching data: $e');
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
      categorized.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authModel = Provider.of<AuthModel>(context);
    final theme = Theme.of(context);

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
        child: _isLoading
            ? const LoadingShimmer()
            : _error != null
            ? ErrorState(
          errorMessage: _error ?? 'No se pudieron cargar los datos',
          onRetry: _fetchData,
        )
            : _products.isEmpty
            ? const EmptyState()
            : RefreshIndicator(
          onRefresh: _fetchData,
          color: AppTheme.primaryColor,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Welcome header (if authenticated)
              if (authModel.isAuthenticated)
                SliverToBoxAdapter(
                  child: _buildWelcomeHeader(authModel),
                ),

              // Category filters
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Categorías',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: CategoryFilters(
                  categorizedProducts: _categorizedProducts,
                  selectedCategory: _selectedCategory,
                  onCategorySelected: (category) {
                    setState(() {
                      _selectedCategory = category;
                      if (category == null) {
                        _categorizedProducts = _groupByCategory(_products);
                      } else {
                        _categorizedProducts = _groupByCategory(
                          _products.where((product) => product.categoria == category).toList(),
                        );
                      }
                    });
                  },
                ),
              ),

              // Rentadoras carousel (moved below categories)
              if (_rentadoras.isNotEmpty)
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                        child: Text(
                          'Rentadoras destacadas',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      RentadorasCarousel(rentadoras: _rentadoras),
                    ],
                  ),
                ),

              // Products by category
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text(
                    'Productos disponibles',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final category = _categorizedProducts.keys.elementAt(index);
                    final products = _categorizedProducts[category]!;
                    return ProductSection(category: category, products: products);
                  },
                  childCount: _categorizedProducts.length,
                ),
              ),
              // Add some padding at the bottom
              SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _showScrollToTop
          ? FloatingActionButton(
        mini: true,
        onPressed: _scrollToTop,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.arrow_upward, color: Colors.white),
        // Add elevation and shape for better visibility
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      )
          : null,
      bottomNavigationBar: buildBottomNavigationBar(context, authModel),
    );
  }

  Widget _buildWelcomeHeader(AuthModel authModel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          // User avatar or icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              color: AppTheme.primaryColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
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
    );
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
}