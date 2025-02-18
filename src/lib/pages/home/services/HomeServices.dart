// lib/home/services/HomeServices.dart
class HomeServices {
  // Ejemplo de un método para obtener datos
  Future<List<String>> fetchHomeData() async {
    // Simulación de una llamada a una API o base de datos
    await Future.delayed(Duration(seconds: 2)); // Simula una demora
    return [
      'Item 1',
      'Item 2',
      'Item 3',
    ];
  }
}