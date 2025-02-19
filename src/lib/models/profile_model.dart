// lib/models/profile_model.dart
class Profile {
  final int idUsuario;
  final String nombre;
  final String apellidos;
  final String correo;
  final String numeroTelefono;
  final String urlPerfil; // Este campo podría ser null

  Profile({
    required this.idUsuario,
    required this.nombre,
    required this.apellidos,
    required this.correo,
    required this.numeroTelefono,
    required this.urlPerfil,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      idUsuario: json['id_usuario'],
      nombre: json['Nombre'] ?? '', // Asigna una cadena vacía si es null
      apellidos: json['apellidos'] ?? '',
      correo: json['correo'] ?? '',
      numeroTelefono: json['numero_telefono'] ?? '',
      urlPerfil: json['url_perfil'] ?? 'https://www.pngall.com/wp-content/uploads/5/Profile.png', // URL predeterminada si es null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_usuario': idUsuario,
      'nombre': nombre,
      'apellidos': apellidos,
      'correo': correo,
      'numero_telefono': numeroTelefono,
      'url_perfil': urlPerfil,
    };
  }
}