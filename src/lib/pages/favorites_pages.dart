import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/auth_model.dart';
import '../models/favorite_model.dart';
import '../api/favorite_api.dart';
import '../widgets/favorite_card_widget.dart';
import '../widgets/empty_favorites_widget.dart';
import '../theme/app_theme.dart'; // Add import for AppTheme

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final FavoriteApi _favoriteApi = FavoriteApi();
  List<FavoriteProduct> _favorites = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final authModel = Provider.of<AuthModel>(context, listen: false);
    if (!authModel.isAuthenticated) {
      setState(() {
        _isLoading = false;
        _error = 'Debes iniciar sesión para ver tus favoritos';
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final favorites = await _favoriteApi.getFavorites(authModel.token!);
      setState(() {
        _favorites = favorites;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteFavorite(FavoriteProduct favorite) async {
    final authModel = Provider.of<AuthModel>(context, listen: false);

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar de favoritos', style: AppTheme.titleStyle),
          content: Text(
            '¿Estás seguro de que deseas eliminar "${favorite.nombreProducto}" de tus favoritos?',
            style: TextStyle(color: AppTheme.text),
          ),
          backgroundColor: AppTheme.backgroundColor,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancelar', style: TextStyle(color: AppTheme.text2)),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Eliminar'),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
                foregroundColor: AppTheme.White,
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      setState(() => _favorites.remove(favorite));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Eliminando de favoritos...',
            style: TextStyle(color: AppTheme.White),
          ),
          backgroundColor: AppTheme.primaryColor,
          duration: Duration(seconds: 1),
        ),
      );

      await _favoriteApi.deleteFavorite(authModel.token!, favorite.idFavorito);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eliminado de favoritos',
              style: TextStyle(color: AppTheme.White),
            ),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _favorites.add(favorite));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: $e',
              style: TextStyle(color: AppTheme.White),
            ),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Favoritos',  style: TextStyle(
          color: AppTheme.White,
          fontWeight: FontWeight.bold,
        ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Container(
        color: AppTheme.backgroundColor,
        child: RefreshIndicator(
          onRefresh: _loadFavorites,
          color: AppTheme.accentColor,
          backgroundColor: AppTheme.lightTurquoise,
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppTheme.accentColor,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(color: AppTheme.errorColor),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _loadFavorites,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                foregroundColor: AppTheme.White,
              ),
            ),
          ],
        ),
      );
    }

    if (_favorites.isEmpty) {
      return EmptyFavorites(
        onExplore: () => Navigator.pushNamed(context, '/'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _favorites.length,
      itemBuilder: (context, index) {
        final favorite = _favorites[index];
        return FavoriteCard(
          favorite: favorite,
          onDelete: () => _deleteFavorite(favorite),
          onTap: () => Navigator.pushNamed(
            context,
            '/product-detail',
            arguments: favorite.idProducto,
          ),
        );
      },
    );
  }
}