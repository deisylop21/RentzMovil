// lib/api/product_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ProductApi {
  final String apiUrl = "https://darkred-donkey-427653.hostingersite.com/api/v1/cliente/productos";

  Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> productsJson = data['data'];
        return productsJson.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar los productos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al cargar los productos: $e');
    }
  }
}