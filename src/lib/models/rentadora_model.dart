class Rentadora {
  final int idRentadoraLocal;
  final String business;
  final String urlLogo;

  // Campos adicionales para el detalle
  final String? estado;
  final String? codigoPostal;
  final String? descripcion;
  final double? puntuacion;
  final String? horarioAbre;
  final String? horarioCierra;
  final String? urlBanner;
  final List<ProductoRentadora>? productos;

  Rentadora({
    required this.idRentadoraLocal,
    required this.business,
    required this.urlLogo,
    this.estado,
    this.codigoPostal,
    this.descripcion,
    this.puntuacion,
    this.horarioAbre,
    this.horarioCierra,
    this.urlBanner,
    this.productos,
  });

  factory Rentadora.fromJson(Map<String, dynamic> json) {
    return Rentadora(
      idRentadoraLocal: json['Id_RentadoraLocal'],
      business: json['Business'],
      urlLogo: json['url_logo'],
    );
  }

  factory Rentadora.fromDetailJson(Map<String, dynamic> json) {
    List<ProductoRentadora> productos = [];

    if (json['productos'] != null) {
      productos = List<ProductoRentadora>.from(
          (json['productos'] as List).map((item) => ProductoRentadora.fromJson(item))
      );
    }

    return Rentadora(
      idRentadoraLocal: json['id_rentadora'],
      business: json['Business'],
      urlLogo: json['url_logo'],
      estado: json['estado'],
      codigoPostal: json['codigo_postal'],
      descripcion: json['descripcion'],
      puntuacion: json['puntuacion']?.toDouble() ?? 0.0,
      horarioAbre: json['horario_abre'],
      horarioCierra: json['horario_cierra'],
      urlBanner: json['url_banner'],
      productos: productos,
    );
  }
}

class ProductoRentadora {
  final int idProducto;
  final String nombreProducto;
  final String categoria;
  final int cantidadActual;
  final String precio;
  final String descripcion;
  final String material;
  final String urlImagenPrincipal;
  final int esPromocion;
  final String? precioPromocion;

  ProductoRentadora({
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
  });

  factory ProductoRentadora.fromJson(Map<String, dynamic> json) {
    return ProductoRentadora(
      idProducto: json['Id_producto'],
      nombreProducto: json['nombre_producto'],
      categoria: json['Categoria'],
      cantidadActual: json['cantidad_actual'],
      precio: json['precio'],
      descripcion: json['descripcion'],
      material: json['material'],
      urlImagenPrincipal: json['url_imagenprincipal'],
      esPromocion: json['es_promocion'],
      precioPromocion: json['precio_promocion'],
    );
  }
}