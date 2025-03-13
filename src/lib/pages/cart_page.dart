import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../api/cart_api.dart';
import '../models/auth_model.dart';
import '../models/cart_model.dart';
import '../widgets/bottom_navigation_bar_widget.dart';
import '../theme/app_theme.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> with SingleTickerProviderStateMixin {
  late Future<List<CartItem>> _cartFuture;
  List<CartItem> _cartItems = [];
  bool _isAuthenticated = true;
  bool _isInitialized = false;
  bool _isLoading = false;
  double _totalPrice = 0;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _initializeCart();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeCart() async {
    final authModel = Provider.of<AuthModel>(context, listen: false);

    if (authModel.token == null) {
      setState(() {
        _isAuthenticated = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Debes iniciar sesión para usar el carrito"),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        Navigator.pop(context);
      });
    } else {
      setState(() {
        _isLoading = true;
      });

      try {
        final items = await CartApi().fetchCart(authModel.token!);
        setState(() {
          _cartItems = items;
          _calculateTotal();
          _isInitialized = true;
          _isLoading = false;
        });
        _controller.forward();
      } catch (e) {
        setState(() {
          _isLoading = false;
          _isInitialized = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al cargar el carrito: $e"),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _calculateTotal() {
    _totalPrice = _cartItems.fold(0, (sum, item) => sum + double.parse(item.total));
  }

  Future<void> _refreshCart() async {
    setState(() {
      _isLoading = true;
    });

    final authModel = Provider.of<AuthModel>(context, listen: false);
    if (authModel.token != null) {
      try {
        final items = await CartApi().fetchCart(authModel.token!);
        setState(() {
          _cartItems = items;
          _calculateTotal();
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al actualizar el carrito: $e"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _updateQuantity(int idCarrito, int newQuantity, int index) async {
    if (newQuantity < 1) return;

    // Optimistic UI update
    final previousQuantity = _cartItems[index].cantidad;
    final double itemPrice = double.parse(_cartItems[index].total) / previousQuantity;

    setState(() {
      _cartItems[index].cantidad = newQuantity;
      _cartItems[index].total = (itemPrice * newQuantity).toStringAsFixed(2);
      _calculateTotal();
    });

    try {
      final authModel = Provider.of<AuthModel>(context, listen: false);
      if (authModel.token == null) {
        throw Exception("Token de autenticación no disponible");
      }
      await CartApi().updateCartItem(authModel.token!, idCarrito, newQuantity);
      // No need to refresh the entire cart
    } catch (e) {
      // Revert the optimistic update on error
      setState(() {
        _cartItems[index].cantidad = previousQuantity;
        _cartItems[index].total = (itemPrice * previousQuantity).toStringAsFixed(2);
        _calculateTotal();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al actualizar la cantidad: $e"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _deleteItem(int idCarrito, int index) async {
    // Optimistic UI update
    final removedItem = _cartItems[index];

    setState(() {
      _cartItems.removeAt(index);
      _calculateTotal();
    });

    try {
      final authModel = Provider.of<AuthModel>(context, listen: false);
      if (authModel.token == null) {
        throw Exception("Token de autenticación no disponible");
      }
      await CartApi().deleteCartItem(authModel.token!, idCarrito);
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Producto eliminado del carrito"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.successColor,
          action: SnackBarAction(
            label: 'DESHACER',
            textColor: Colors.white,
            onPressed: () {
              // Functionality to add item back would go here
              // This would require an API call to re-add the item
              _refreshCart();
            },
          ),
        ),
      );
    } catch (e) {
      // Revert the optimistic update on error
      setState(() {
        _cartItems.insert(index, removedItem);
        _calculateTotal();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al eliminar el producto: $e"),
          behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.errorColor
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!_isAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,//
          title: Text("Carrito de Compras", style: AppTheme.titleStyle.copyWith(color: Colors.white)),
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                "Debes iniciar sesión para ver el carrito",
                style: AppTheme.titleStyle,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                style: AppTheme.primaryButtonStyle,
                child: Text("Iniciar Sesión"),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,//
          title: Text("Carrito de Compras", style: AppTheme.titleStyle.copyWith(color: Colors.white)),
          elevation: 0,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,//
        title: Text("Carrito de Compras", style: AppTheme.titleStyle.copyWith(color: Colors.white)),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _isLoading ? null : _refreshCart,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _cartItems.isEmpty
          ? _buildEmptyCart()
          : _buildCartContent(),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_cartItems.isNotEmpty) _buildBottomCheckout(),
          buildBottomNavigationBar(
              context,
              Provider.of<AuthModel>(context),
              currentIndex: 2
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: FadeTransition(
        opacity: _animation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
            ),
            SizedBox(height: 24),
            Text(
              "Tu carrito está vacío",
              style: AppTheme.titleStyle,
            ),
            SizedBox(height: 16),
            Text(
              "Parece que aún no has añadido productos a tu carrito",
              textAlign: TextAlign.center,
              style: AppTheme.titleStyle,
            ),
            SizedBox(height: 32),
            ElevatedButton.icon(
              icon: Icon(Icons.shopping_bag_outlined),
              label: Text("Explorar Productos"),
              onPressed: () => Navigator.pushNamed(context, '/products'),
              style: AppTheme.primaryButtonStyle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartContent() {
    return Column(
      children: [
        if (_isLoading)
          LinearProgressIndicator(
              backgroundColor: AppTheme.errorColor
          ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 8),
            itemCount: _cartItems.length,
            itemBuilder: (context, index) {
              return FadeTransition(
                opacity: _animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(1, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _controller,
                      curve: Interval(
                        index * 0.1,
                        0.6 + index * 0.1,
                        curve: Curves.easeOutQuart,
                      ),
                    ),
                  ),
                  child: _buildCartItem(context, _cartItems[index], index),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem item, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Slidable(
      key: Key(item.idCarrito.toString()),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _deleteItem(item.idCarrito, index),
            backgroundColor: AppTheme.errorColor,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Eliminar',
            borderRadius: BorderRadius.horizontal(right: Radius.circular(12)),
          ),
        ],
      ),
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: CachedNetworkImage(
                imageUrl: item.urlImagenPrincipal,
                fit: BoxFit.cover,
                height: 180,
                width: double.infinity,
                placeholder: (context, url) => Container(
                  height: 180,
                  color: Colors.grey[200],
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 180,
                  color: Colors.grey[200],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                      SizedBox(height: 8),
                      Text("Imagen no disponible", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.nombreProducto,
                              style: AppTheme.titleStyle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text(
                              item.descripcion,
                              style: AppTheme.titleStyle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                        onPressed: () => _deleteItem(item.idCarrito, index),
                        tooltip: "Eliminar",
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.esPromocion && item.precioPromocion != null) ...[
                            Text(
                              "Precio original: \$${item.precio}",
                                style: AppTheme.priceStyle,
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    "OFERTA",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  "\$${item.precioPromocion}",
                                  style: AppTheme.promotionalPriceStyle,
                                ),
                              ],
                            ),
                          ] else
                            Text(
                              "\$${item.precio}",
                              style: AppTheme.priceStyle,
                            ),
                        ],
                      ),
                      Row(
                        children: [
                          _buildQuantityButton(
                            icon: Icons.remove,
                            onPressed: item.cantidad > 1
                                ? () => _updateQuantity(item.idCarrito, item.cantidad - 1, index)
                                : null,
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 8),
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "${item.cantidad}",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _buildQuantityButton(
                            icon: Icons.add,
                            onPressed: () => _updateQuantity(item.idCarrito, item.cantidad + 1, index),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total: ",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        "\$${item.total}",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: item.esPromocion ? AppTheme.secondaryColor : AppTheme.primaryColor, //antes era secundary
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.shopping_bag_outlined),
                      label: Text("Rentar Ahora"),
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          '/renta-form',
                          arguments: item,
                        );
                      },
                      style: AppTheme.primaryButtonStyle,
                      ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton({required IconData icon, VoidCallback? onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: onPressed == null ? Colors.grey.shade200 : Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: onPressed == null ? Colors.grey : Theme.of(context).colorScheme.primary,
          size: 18,
        ),
        onPressed: onPressed,
        constraints: BoxConstraints(
          minWidth: 36,
          minHeight: 36,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildBottomCheckout() {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Subtotal (${_cartItems.length} productos):",
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  "\$${_totalPrice.toStringAsFixed(2)}",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Redirigir a la página de checkout
                  Navigator.of(context).pushNamed('/checkout');
                },
                style: AppTheme.primaryButtonStyle,
                child: Text(
                  "Proceder al Pago",
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
    );
  }
}