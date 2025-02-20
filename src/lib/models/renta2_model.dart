class Renta2 {
  final int idProducto;
  final int idDireccion;
  final String fechaInicio;
  final String fechaFinal;
  final double costoEnvio;
  final double total;

  Renta2({
    required this.idProducto,
    required this.idDireccion,
    required this.fechaInicio,
    required this.fechaFinal,
    required this.costoEnvio,
    required this.total,
  });

  Map<String, dynamic> toJson() {
    return {
      "id_producto": idProducto,
      "id_direccion": idDireccion,
      "fecha_inicio": fechaInicio,
      "fecha_final": fechaFinal,
      "costo_envio": costoEnvio,
      "total": total,
    };
  }
}