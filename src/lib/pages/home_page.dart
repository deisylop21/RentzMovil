import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../api/product_api.dart';
import '../api/rentadora_api.dart';
import '../models/auth_model.dart';
import '../models/product_model.dart';
import '../models/rentadora_model.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/bottom_navigation_bar_widget.dart';
import '../theme/app_theme.dart';
import '../widgets/category_filters.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/error_state.dart';
import '../widgets/empty_state.dart';
import '../widgets/product_section.dart';
import '../widgets/rentadoras_carousel.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final ProductApi productApi = ProductApi();
  final RentadoraApi rentadoraApi = RentadoraApi();
  List<Product> _products = [];
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

      final productsResult = productApi.fetchProducts();
      final rentadorasResult = rentadoraApi.fetchRentadoras();

      final products = await productsResult;
      final rentadoras = await rentadorasResult;

      if (mounted) {
        setState(() {
          _products = products;
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

  List<Product> _filterProducts(String query, String? category) {
    List<Product> filtered = _products;

    if (category != null) {
      filtered = filtered.where((product) =>
      product.categoria == category
      ).toList();
    }

    if (query.isNotEmpty) {
      final searchLower = query.toLowerCase();
      filtered = filtered.where((product) =>
      product.nombreProducto.toLowerCase().contains(searchLower) ||
          product.categoria.toLowerCase().contains(searchLower) ||
          product.descripcion.toLowerCase().contains(searchLower)
      ).toList();
    }

    return filtered;
  }

  Set<String> _getCategories() {
    return _products.map((product) => product.categoria).toSet();
  }
  @override
  Widget build(BuildContext context) {
    final authModel = Provider.of<AuthModel>(context);
    final theme = Theme.of(context);
    final filteredProducts = _filterProducts(_searchQuery, _selectedCategory);
    final categories = _getCategories();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: buildAppBar(
        context,
        authModel,
            (query) {
          setState(() {
            _searchQuery = query;
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
              // Category filters
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Categorías',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.text,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      FilterChip(
                        label: Text('Todos'),
                        selected: _selectedCategory == null,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = null;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      ...categories.map((category) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: _selectedCategory == category,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = selected ? category : null;
                            });
                          },
                        ),
                      )).toList(),
                    ],
                  ),
                ),
              ),

              // Rentadoras section
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
                            color: AppTheme.text,
                          ),
                        ),
                      ),
                      RentadorasCarousel(rentadoras: _rentadoras),
                    ],
                  ),
                ),

              // Products section title
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text(
                    'Productos disponibles',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.text,
                    ),
                  ),
                ),
              ),

              // Products list
              SliverToBoxAdapter(
                child: ProductSection(products: filteredProducts),
              ),

              // Bottom padding
              const SliverToBoxAdapter(
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
        child: Icon(Icons.arrow_upward, color: AppTheme.backgroundColor),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      )
          : null,
      bottomNavigationBar: buildBottomNavigationBar(context, authModel),
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