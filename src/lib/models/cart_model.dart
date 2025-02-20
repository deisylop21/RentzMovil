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
      idCarrito: json['Id_carrito'],
      idUsuario: json['Id_usuario'],
      idProducto: json['Id_producto'],
      cantidad: json['cantidad'],
      total: json['total'],
      nombreProducto: json['nombre_producto'],
      precio: json['precio'],
      esPromocion: json['es_promocion'] == 1,
      precioPromocion: json['precio_promocion'],
      descripcion: json['descripcion'],
      urlImagenPrincipal: json['url_imagenprincipal'],
    );
  }
}