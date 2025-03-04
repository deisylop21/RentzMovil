class Direccion {
  final int? id;
  final String calle;
  final String numeroExterior;
  final String? numeroInterior;
  final String codigoPostal;
  final String colonia;
  final String? referencia;
  final String numeroContacto;
  final bool direccionPrioritaria;
  final String? googleMapsUrl; // Nueva propiedad

  Direccion({
    this.id,
    required this.calle,
    required this.numeroExterior,
    this.numeroInterior,
    required this.codigoPostal,
    required this.colonia,
    this.referencia,
    required this.numeroContacto,
    required this.direccionPrioritaria,
    this.googleMapsUrl, // Nuevo campo opcional
  });

  factory Direccion.fromJson(Map<String, dynamic> json) {
    return Direccion(
      id: json['Id_direccion'],
      calle: json['Calle'],
      numeroExterior: json['Numero_exterior'],
      numeroInterior: json['Numero_interior'],
      codigoPostal: json['CodigoPostal'],
      colonia: json['Colonia'],
      referencia: json['Referencia'],
      numeroContacto: json['Numero_contacto'],
      direccionPrioritaria: json['Direccion_Prioritaria'] == 1,
      googleMapsUrl: json['googleMapsUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "Id_direccion": id,
      "Calle": calle,
      "Numero_exterior": numeroExterior,
      "Numero_interior": numeroInterior,
      "CodigoPostal": codigoPostal,
      "Colonia": colonia,
      "Referencia": referencia,
      "Numero_contacto": numeroContacto,
      "Direccion_Prioritaria": direccionPrioritaria,
      "googleMapsUrl": googleMapsUrl,
    };
  }
}