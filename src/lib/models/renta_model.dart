class Renta {
  final int idRentaProducto;
  final DateTime fechaInicio;
  final DateTime fechaFinal;
  final String costoEnvio;
  final String total;
  final String estado;
  final int idProducto;
  final String nombreProducto;
  final String categoria;
  final String precio;
  final String descripcion;
  final String material;
  final String urlImagenPrincipal;
  final bool esPromocion;
  final String? precioPromocion;
  final int idDireccion;
  final String calle;
  final String numeroExterior;
  final String? numeroInterior;
  final String codigoPostal;
  final String colonia;
  final String referencia;
  final String numeroContacto;
  final bool direccionPrioritaria;

  Renta({
    required this.idRentaProducto,
    required this.fechaInicio,
    required this.fechaFinal,
    required this.costoEnvio,
    required this.total,
    required this.estado,
    required this.idProducto,
    required this.nombreProducto,
    required this.categoria,
    required this.precio,
    required this.descripcion,
    required this.material,
    required this.urlImagenPrincipal,
    required this.esPromocion,
    this.precioPromocion,
    required this.idDireccion,
    required this.calle,
    required this.numeroExterior,
    this.numeroInterior,
    required this.codigoPostal,
    required this.colonia,
    required this.referencia,
    required this.numeroContacto,
    required this.direccionPrioritaria,
  });

  factory Renta.fromJson(Map<String, dynamic> json) {
    return Renta(
      idRentaProducto: json['Id_renta_producto'] ?? 0,
      fechaInicio: json['Fecha_inicio'] != null ? DateTime.parse(json['Fecha_inicio']) : DateTime.now(),
      fechaFinal: json['Fecha_final'] != null ? DateTime.parse(json['Fecha_final']) : DateTime.now(),
      costoEnvio: json['Costo_Envio'] ?? "0.00",
      total: json['Total'] ?? "0.00",
      estado: json['Estado'] ?? "Desconocido",
      idProducto: json['Id_producto'] ?? 0,
      nombreProducto: json['nombre_producto'] ?? "Sin nombre",
      categoria: json['Categoria'] ?? "Sin categoría",
      precio: json['precio'] ?? "0.00",
      descripcion: json['descripcion'] ?? "Sin descripción",
      material: json['material'] ?? "Desconocido",
      urlImagenPrincipal: json['url_imagenprincipal'] ?? "",
      esPromocion: json['es_promocion'] == 1,
      precioPromocion: json['precio_promocion'], // Puede ser null
      idDireccion: json['Id_direccion'] ?? 0,
      calle: json['Calle'] ?? "Sin calle",
      numeroExterior: json['Numero_exterior'] ?? "S/N",
      numeroInterior: json['Numero_interior'], // Puede ser null
      codigoPostal: json['CodigoPostal'] ?? "00000",
      colonia: json['Colonia'] ?? "Sin colonia",
      referencia: json['Referencia'] ?? "Sin referencia",
      numeroContacto: json['Numero_contacto'] ?? "0000000000",
      direccionPrioritaria: json['Direccion_Prioritaria'] == 1,
    );
  }
}
