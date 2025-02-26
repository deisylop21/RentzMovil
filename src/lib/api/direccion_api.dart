import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/direccion_model.dart';

class DireccionesApi {
  final String baseUrl = "https://rentzmx.com/api/api/v1";

  // Obtener direcciones
  Future<List<Direccion>> fetchDirecciones(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/direcciones"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      List<dynamic> direccionesJson = responseData['data'];
      return direccionesJson.map((json) => Direccion.fromJson(json)).toList();
    } else {
      throw Exception("Error al obtener direcciones: ${response.statusCode}");
    }
  }

  // Agregar nueva dirección
  Future<void> addDireccion(String token, Direccion direccion) async {
    final url = Uri.parse("https://darkred-donkey-427653.hostingersite.com/api/v1/direcciones");

    final Map<String, dynamic> data = {
      "Calle": direccion.calle,
      "Numero_exterior": direccion.numeroExterior,
      "Numero_interior": direccion.numeroInterior ?? "",
      "CodigoPostal": direccion.codigoPostal,
      "Colonia": direccion.colonia,
      "Referencia": direccion.referencia ?? "",
      "Numero_contacto": direccion.numeroContacto,
      "Direccion_Prioritaria": direccion.direccionPrioritaria ?? false, // ← Si es null, lo pone en false
    };

    print("📡 Enviando datos: ${data}");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(data),
    );

    print("🔄 Respuesta del servidor: ${response.statusCode} - ${response.body}");

    if (response.statusCode != 201) {
      throw Exception("Error al agregar dirección: ${response.statusCode}");
    }
  }

  // Editar dirección
  Future<void> updateDireccion(String token, int id, Direccion direccion) async {
    final response = await http.put(
      Uri.parse("$baseUrl/direcciones/$id"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: json.encode(direccion.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception("Error al actualizar dirección: ${response.statusCode}");
    }
  }

  // Eliminar dirección
  Future<void> deleteDireccion(String token, int id) async {
    final url = Uri.parse("https://darkred-donkey-427653.hostingersite.com/api/v1/direcciones/$id");

    try {
      final response = await http.delete(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // Si es necesario
        },
      );

      if (response.statusCode == 200) {
        print("✅ Dirección eliminada con éxito");
      } else {
        print("❌ Error al eliminar: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("🔥 Error al eliminar dirección: $e");
    }
  }
}
