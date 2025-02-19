// lib/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/auth_api.dart';
import '../models/auth_model.dart';
import '../models/profile_model.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mi Perfil"),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(labelText: "Nombre"),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _apellidosController,
              decoration: InputDecoration(labelText: "Apellidos"),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _correoController,
              decoration: InputDecoration(labelText: "Correo Electrónico"),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _telefonoController,
              decoration: InputDecoration(labelText: "Número de Teléfono"),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _urlPerfilController,
              decoration: InputDecoration(labelText: "URL de Imagen de Perfil"),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _updateProfile,
              child: Text("Guardar Cambios"),
            ),
          ],
        ),
      ),
    );
  }
}