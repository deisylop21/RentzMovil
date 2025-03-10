import 'dart:convert';

class CartItem {
  final int idCarrito;
  final int idUsuario;
  final int idProducto;
  int _cantidad; // Ahora es privado para usar getter/setter
  final String nombreProducto;
  final String descripcion;
  final String urlImagenPrincipal;
  final String precio;
  final bool esPromocion;
  final String? precioPromocion;
  String _total; // Ahora es privado para usar getter/setter

  // Getters
  int get cantidad => _cantidad;
  String get total => _total;

  // Setters
  set cantidad(int value) {
    _cantidad = value;
  }

  set total(String value) {
    _total = value;
  }

  CartItem({
    required this.idCarrito,
    required this.idUsuario,
    required this.idProducto,
    required int cantidad,
    required this.nombreProducto,
    required this.descripcion,
    required this.urlImagenPrincipal,
    required this.precio,
    required this.esPromocion,
    this.precioPromocion,
    required String total,
  }) : _cantidad = cantidad, _total = total;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      idCarrito: json['Id_carrito'] ?? 0, // Valor predeterminado si es null
      idUsuario: json['Id_usuario'] ?? 0,
      idProducto: json['Id_producto'] ?? 0,
      cantidad: json['cantidad'] ?? 0,
      nombreProducto: json['nombre_producto'] ?? '',
      descripcion: json['descripcion'] ?? '',
      urlImagenPrincipal: json['url_imagenprincipal'] ?? '',
      precio: json['precio'] ?? '0.00',
      esPromocion: json['es_promocion'] == 1,
      precioPromocion: json['precio_promocion'],
      total: json['total'] ?? '0.00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idCarrito': idCarrito,
      'idUsuario': idUsuario,
      'idProducto': idProducto,
      'cantidad': _cantidad,
      'nombreProducto': nombreProducto,
      'descripcion': descripcion,
      'urlImagenPrincipal': urlImagenPrincipal,
      'precio': precio,
      'esPromocion': esPromocion,
      'precioPromocion': precioPromocion,
      'total': _total,
    };
  }
}

// Método para analizar la lista de elementos del carrito desde JSON
List<CartItem> parseCartItems(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<CartItem>((json) => CartItem.fromJson(json)).toList();
}
