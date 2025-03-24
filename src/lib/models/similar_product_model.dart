class SimilarProduct {
  final int idProducto;
  final String nombreProducto;
  final String precio;
  final String urlImagenPrincipal;

  SimilarProduct({
    required this.idProducto,
    required this.nombreProducto,
    required this.precio,
    required this.urlImagenPrincipal,
  });

  factory SimilarProduct.fromJson(Map<String, dynamic> json) {
    return SimilarProduct(
      idProducto: json['Id_producto'] ?? 0,
      nombreProducto: json['nombre_producto'] ?? 'Sin nombre',
      precio: json['precio'] ?? '0.00',
      urlImagenPrincipal: json['url_imagenprincipal'] ?? '',
    );
  }
}