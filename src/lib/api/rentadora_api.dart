import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/rentadora_model.dart';

class RentadoraApi {
  final String baseUrl = 'https://rentzmx.com/api/api/v1';

  // Método para obtener lista de rentadoras
  Future<List<Rentadora>> fetchRentadoras() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/rentadoras/listar'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true && responseData['data'] != null) {
          return List<Rentadora>.from(
              responseData['data'].map((item) => Rentadora.fromJson(item))
          );
        } else {
          throw Exception('No se encontraron datos de rentadoras');
        }
      } else {
        throw Exception('Error al cargar rentadoras: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Nuevo método para obtener detalle de una rentadora específica
  Future<Rentadora> fetchRentadoraDetail(int idRentadora) async {
    try {
      final response = await http.get(
          Uri.parse('$baseUrl/rentadoras/listar/$idRentadora')
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true && responseData['data'] != null) {
          return Rentadora.fromDetailJson(responseData['data']);
        } else {
          throw Exception('No se encontraron datos de la rentadora');
        }
      } else {
        throw Exception('Error al cargar detalle de rentadora: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}