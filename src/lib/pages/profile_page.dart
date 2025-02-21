import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/auth_api.dart';
import '../models/auth_model.dart';
import '../models/profile_model.dart';
import 'home_page.dart'; // Importa la página de inicio

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _urlPerfilController = TextEditingController();
  bool _isLoading = false;
  bool _isEditing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authModel = Provider.of<AuthModel>(context, listen: false);
      final profile = await AuthApi().fetchProfile(authModel.token!);

      // Cargar los datos del perfil en los controladores
      _nombreController.text = profile.nombre;
      _apellidosController.text = profile.apellidos;
      _correoController.text = profile.correo;
      _telefonoController.text = profile.numeroTelefono;
      _urlPerfilController.text = profile.urlPerfil;
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authModel = Provider.of<AuthModel>(context, listen: false);
      final profileData = {
        "nombre": _nombreController.text.trim(),
        "apellidos": _apellidosController.text.trim(),
        "correo": _correoController.text.trim(),
        "numero_telefono": _telefonoController.text.trim(),
        "url_perfil": _urlPerfilController.text.trim(),
      };

      await AuthApi().updateProfile(authModel.token!, profileData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Perfil actualizado exitosamente")),
      );

      setState(() {
        _isEditing = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    final authModel = Provider.of<AuthModel>(context, listen: false);
    authModel.logout();
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mi Perfil"),
        centerTitle: true,
        backgroundColor: Color(0xFF013750),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                  _urlPerfilController.text.isNotEmpty
                      ? _urlPerfilController.text
                      : 'https://via.placeholder.com/150',
                ),
              ),
              SizedBox(height: 16),
              Text(
                "${_nombreController.text} ${_apellidosController.text}",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _correoController.text,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 16),
              _isEditing
                  ? _buildEditForm()
                  : ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF00988D),
                ),
                child: Text("Editar Perfil"),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF23E02),
                ),
                child: Text("Cerrar Sesión"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _nombreController,
          decoration: InputDecoration(
            labelText: "Nombre",
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF2C6B74)),
              borderRadius: BorderRadius.circular(8.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF00988D)),
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        SizedBox(height: 16),
        TextField(
          controller: _apellidosController,
          decoration: InputDecoration(
            labelText: "Apellidos",
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF2C6B74)),
              borderRadius: BorderRadius.circular(8.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF00988D)),
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        SizedBox(height: 16),
        TextField(
          controller: _correoController,
          decoration: InputDecoration(
            labelText: "Correo Electrónico",
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF2C6B74)),
              borderRadius: BorderRadius.circular(8.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF00988D)),
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 16),
        TextField(
          controller: _telefonoController,
          decoration: InputDecoration(
            labelText: "Número de Teléfono",
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF2C6B74)),
              borderRadius: BorderRadius.circular(8.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF00988D)),
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          keyboardType: TextInputType.phone,
        ),
        SizedBox(height: 16),
        TextField(
          controller: _urlPerfilController,
          decoration: InputDecoration(
            labelText: "URL de Imagen de Perfil",
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF2C6B74)),
              borderRadius: BorderRadius.circular(8.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF00988D)),
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF00988D),
          ),
          child: Text("Guardar Cambios"),
        ),
      ],
    );
  }
}