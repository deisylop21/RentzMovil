// lib/models/cart_model.dart
class CartItem {
  final int idCarrito;
  final int idUsuario;
  final int idProducto;
  final int cantidad;
  final String total;
  final String nombreProducto;
  final String precio;
  final bool esPromocion;
  final String? precioPromocion;
  final String descripcion;
  final String urlImagenPrincipal;

  CartItem({
    required this.idCarrito,
    required this.idUsuario,
    required this.idProducto,
    required this.cantidad,
    required this.total,
    required this.nombreProducto,
    required this.precio,
    required this.esPromocion,
    this.precioPromocion,
    required this.descripcion,
    required this.urlImagenPrincipal,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      idCarrito: json['Id_carrito'] ?? 0, // Valor predeterminado si es null
      idUsuario: json['Id_usuario'] ?? 0,
      idProducto: json['Id_producto'] ?? 0,
      cantidad: json['cantidad'] ?? 0,
      total: json['total'] ?? '0.00',
      nombreProducto: json['nombre_producto'] ?? '',
      precio: json['precio'] ?? '0.00',
      esPromocion: json['es_promocion'] == 1,
      precioPromocion: json['precio_promocion'],
      descripcion: json['descripcion'] ?? '',
      urlImagenPrincipal: json['url_imagenprincipal'] ?? '',
    );
  }
}