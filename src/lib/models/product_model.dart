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
      idProducto: json['id_producto'],
      nombreProducto: json['nombre_producto'],
      categoria: json['categoria'],
      cantidadActual: json['cantidad_actual'],
      precio: json['precio'],
      descripcion: json['descripcion'],
      material: json['material'],
      urlImagenPrincipal: json['url_imagenprincipal'],
      esPromocion: json['es_promocion'] == 1,
      precioPromocion: json['precio_promocion'],
      imagenes: json['imagenes'] != null
          ? List<String>.from(json['imagenes']) // Convertimos la lista de imágenes
          : [], // Asignamos una lista vacía si es null
    );
  }
}