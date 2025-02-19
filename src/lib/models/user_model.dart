// lib/models/user_model.dart
class User {
  final int? idUsuario; // Puede ser nulo al registrar un nuevo usuario
  final String nombre;
  final String apellidos;
  final String correo;
  final String? numeroTelefono; // Campo opcional

  User({
    this.idUsuario,
    required this.nombre,
    required this.apellidos,
    required this.correo,
    this.numeroTelefono,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      idUsuario: json['id_usuario'],
      nombre: json['nombre'],
      apellidos: json['apellidos'],
      correo: json['correo'],
      numeroTelefono: json['numero_telefono'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_usuario': idUsuario,
      'nombre': nombre,
      'apellidos': apellidos,
      'correo': correo,
      'numero_telefono': numeroTelefono,
    };
  }
}