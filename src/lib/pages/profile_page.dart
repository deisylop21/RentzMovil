import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/auth_api.dart';
import '../models/auth_model.dart';
import '../models/profile_model.dart';
import 'home_page.dart';

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

  // Variables para almacenar los datos originales
  String _originalNombre = '';
  String _originalApellidos = '';
  String _originalCorreo = '';
  String _originalTelefono = '';
  String _originalUrlPerfil = '';

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

      // Guardamos los datos originales
      _originalNombre = profile.nombre;
      _originalApellidos = profile.apellidos;
      _originalCorreo = profile.correo;
      _originalTelefono = profile.numeroTelefono;
      _originalUrlPerfil = profile.urlPerfil;

      // Actualizamos los controladores
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

  // Método para restaurar los datos originales
  void _restoreOriginalData() {
    _nombreController.text = _originalNombre;
    _apellidosController.text = _originalApellidos;
    _correoController.text = _originalCorreo;
    _telefonoController.text = _originalTelefono;
    _urlPerfilController.text = _originalUrlPerfil;
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

      // Actualizamos los datos originales después de una actualización exitosa
      _originalNombre = _nombreController.text.trim();
      _originalApellidos = _apellidosController.text.trim();
      _originalCorreo = _correoController.text.trim();
      _originalTelefono = _telefonoController.text.trim();
      _originalUrlPerfil = _urlPerfilController.text.trim();

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

  Future<void> _navegarADirecciones() async {
    final authModel = Provider.of<AuthModel>(context, listen: false);
    Navigator.pushNamed(context, '/direcciones');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mi Perfil"),
        centerTitle: true,
        backgroundColor: Color(0xFF013750),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : _errorMessage != null
            ? Text(_errorMessage!)
            : SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.symmetric(
                horizontal: 24.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                SizedBox(height: 24),
                Text(
                  "${_nombreController.text} ${_apellidosController.text}",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  _correoController.text,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                if (_isEditing)
                  _buildEditForm()
                else
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF00988D),
                          minimumSize: Size(200, 45),
                        ),
                        child: Text("Editar Perfil"),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _navegarADirecciones,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF013750),
                          minimumSize: Size(200, 45),
                        ),
                        child: Text("Direcciones"),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _logout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFF23E02),
                          minimumSize: Size(200, 45),
                        ),
                        child: Text("Cerrar Sesión"),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditForm() {
    return Container(
      constraints: BoxConstraints(maxWidth: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _restoreOriginalData(); // Restauramos los datos originales
                    setState(() {
                      _isEditing = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    minimumSize: Size(0, 45),
                  ),
                  child: Text(
                    "Cancelar",
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF00988D),
                    minimumSize: Size(0, 45),
                  ),
                  child: Text("Guardar Cambios"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}