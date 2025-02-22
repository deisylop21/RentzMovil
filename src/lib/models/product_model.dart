// lib/models/product_model.dart
class Product {
  final int idProducto;
  final String nombreProducto;
  final String categoria;
  final int cantidadActual;
  final String precio;
  final String descripcion;
  final String material;
  final String urlImagenPrincipal;
  final bool esPromocion;
  final String? precioPromocion;
  final List<String> imagenes; // Nueva propiedad para las imágenes adicionales

  Product({
    required this.idProducto,
    required this.nombreProducto,
    required this.categoria,
    required this.cantidadActual,
    required this.precio,
    required this.descripcion,
    required this.material,
    required this.urlImagenPrincipal,
    required this.esPromocion,
    this.precioPromocion,
    required this.imagenes, // Incluimos la lista de imágenes
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      idProducto: json['id_producto'] ?? 0, // Evitar null en int
      nombreProducto: json['nombre_producto'] ?? 'Sin nombre',
      categoria: json['categoria'] ?? 'Desconocida',
      cantidadActual: json['cantidad_actual'] ?? 0,
      precio: json['precio'] ?? '0.00',
      descripcion: json['descripcion'] ?? 'Sin descripción',
      material: json['material'] ?? 'Desconocido',
      urlImagenPrincipal: json['url_imagenprincipal'] ?? '',
      esPromocion: json['es_promocion'] == 1,
      precioPromocion: json['precio_promocion'], // Se mantiene como String?
      imagenes: json['imagenes'] != null ? List<String>.from(json['imagenes']) : [],
    );
  }
}