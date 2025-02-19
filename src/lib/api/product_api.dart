// lib/api/product_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ProductApi {
  final String baseUrl = "https://darkred-donkey-427653.hostingersite.com/api/v1";

  // Obtener todos los productos
  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse("$baseUrl/cliente/productos"));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> productsJson = data['data'];
      return productsJson.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los productos: ${response.statusCode}');
    }
  }

  // Obtener detalles de un producto específico por ID
  Future<Product> fetchProductDetails(int productId) async {
    final response = await http.get(Uri.parse("$baseUrl/cliente/productos/$productId"));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Product.fromJson(data['data']);
    } else {
      throw Exception('Error al cargar los detalles del producto: ${response.statusCode}');
    }
  }
}