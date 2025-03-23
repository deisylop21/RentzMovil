class FavoriteProduct {
  final int idFavorito;
  final int idUsuario;
  final int idProducto;
  final String nombreProducto;
  final String precio;
  final bool esPromocion;
  final String? precioPromocion;
  final String descripcion;
  final String urlImagenPrincipal;

  FavoriteProduct({
    required this.idFavorito,
    required this.idUsuario,
    required this.idProducto,
    required this.nombreProducto,
    required this.precio,
    required this.esPromocion,
    this.precioPromocion,
    required this.descripcion,
    required this.urlImagenPrincipal,
  });

  factory FavoriteProduct.fromJson(Map<String, dynamic> json) {
    return FavoriteProduct(
      idFavorito: json['Id_favorito'],
      idUsuario: json['Id_usuario'],
      idProducto: json['Id_producto'],
      nombreProducto: json['nombre_producto'],
      precio: json['precio'],
      esPromocion: json['es_promocion'] == 1,
      precioPromocion: json['precio_promocion'],
      descripcion: json['descripcion'],
      urlImagenPrincipal: json['url_imagenprincipal'],
    );
  }
}

class FavoritesResponse {
  final bool success;
  final List<FavoriteProduct> data;
  final String message;

  FavoritesResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory FavoritesResponse.fromJson(Map<String, dynamic> json) {
    return FavoritesResponse(
      success: json['success'],
      data: (json['data'] as List)
          .map((item) => FavoriteProduct.fromJson(item))
          .toList(),
      message: json['message'],
    );
  }
}