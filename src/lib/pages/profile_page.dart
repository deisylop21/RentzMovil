import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../api/auth_api.dart';
import '../models/auth_model.dart';
import '../models/profile_model.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_navigation_bar_widget.dart'; //import del widget
//revisar colores

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  // Variables para almacenar los datos originales
  String _originalNombre = '';
  String _originalApellidos = '';
  String _originalCorreo = '';
  String _originalTelefono = '';
  String _originalUrlPerfil = '';

  bool _isLoading = false;
  bool _isEditing = false;
  String? _errorMessage;
  String? _telefonoError; // Variable para el mensaje de error del teléfono

  File? _selectedImage; // Para almacenar la imagen seleccionada

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

  void _restoreOriginalData() {
    _nombreController.text = _originalNombre;
    _apellidosController.text = _originalApellidos;
    _correoController.text = _originalCorreo;
    _telefonoController.text = _originalTelefono;
    _telefonoError = null; // Limpiar el mensaje de error del teléfono
  }

  Future<void> _updateProfile() async {
    // Validar que el número telefónico tenga exactamente 10 dígitos
    if (_telefonoController.text.trim().length != 10) {
      setState(() {
        _telefonoError = "El número de teléfono debe tener exactamente 10 dígitos.";
      });
      return;
    } else {
      setState(() {
        _telefonoError = null; // Limpiar el mensaje de error si es válido
      });
    }

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
      };

      await AuthApi().updateProfile(authModel.token!, profileData);

      // Actualizamos los datos originales después de una actualización exitosa
      _originalNombre = _nombreController.text.trim();
      _originalApellidos = _apellidosController.text.trim();
      _originalCorreo = _correoController.text.trim();
      _originalTelefono = _telefonoController.text.trim();

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
    Navigator.pushNamed(context, '/direcciones');
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });

      // Subir la imagen al servidor
      await _uploadImage(_selectedImage!);
    }
  }

  Future<void> _uploadImage(File image) async {
    final authModel = Provider.of<AuthModel>(context, listen: false);
    final url = Uri.parse('https://rentzmx.com/api/api/v1/cliente/perfil/imagen');
    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer ${authModel.token}'
      ..files.add(await http.MultipartFile.fromPath('imagen', image.path));

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = json.decode(await response.stream.bytesToString());
        setState(() {
          _originalUrlPerfil = responseData['url'];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Imagen actualizada exitosamente")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al subir la imagen")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Widget _buildProfileImage() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.2),
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 60,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            backgroundImage: _selectedImage != null
                ? FileImage(_selectedImage!)
                : NetworkImage(_originalUrlPerfil.isNotEmpty
                ? _originalUrlPerfil
                : 'https://via.placeholder.com/150') as ImageProvider,
            onBackgroundImageError: (_, __) {
              setState(() {
                _originalUrlPerfil = '';
              });
            },
          ),
        ),
        if (_isEditing)
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Cambiar Imagen de Perfil"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: Icon(Icons.photo_library),
                          title: Text("Subir Foto"),
                          onTap: () async {
                            Navigator.pop(context);
                            await _pickImage(ImageSource.gallery);
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.camera_alt),
                          title: Text("Tomar Foto"),
                          onTap: () async {
                            Navigator.pop(context);
                            await _pickImage(ImageSource.camera);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppTheme.primaryColor.withOpacity(0.1),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon, {
        TextInputType? keyboardType,
        String? errorText,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: AppTheme.primaryColor),
            filled: true,
            fillColor: Colors.white,
            labelStyle: TextStyle(color: Colors.grey[600]),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppTheme.primaryColor.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppTheme.errorColor),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppTheme.errorColor, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            errorText: errorText,
          ),
        ),
        if (errorText != null) SizedBox(height: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor,
                AppTheme.darkTurquoise,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          "Mi Perfil",
          style: AppTheme.titleStyle.copyWith(color: Colors.white),//1
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
              color: Colors.white,
            ),
        ],
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(AppTheme.primaryColor),
        ),
      )
          : _errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorColor,
            ),
            SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.errorColor),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: Text("Reintentar"),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.darkTurquoise,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  _buildProfileImage(),
                  SizedBox(height: 16),
                  if (!_isEditing) ...[
                    Text(
                      "${_nombreController.text} ${_apellidosController.text}",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _correoController.text,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: _isEditing
                  ? _buildEditForm()
                  : Column(
                children: [
                  _buildInfoCard(
                    Icons.phone,
                    "Teléfono",
                    _telefonoController.text,
                  ),
                  SizedBox(height: 12),
                  _buildInfoCard(
                    Icons.email,
                    "Correo",
                    _correoController.text,
                  ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _navegarADirecciones,
                    icon: Icon(Icons.location_on),
                    label: Text("Mis Direcciones"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _logout,
                    icon: Icon(Icons.logout),
                    label: Text("Cerrar Sesión"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.errorColor,
                      side: BorderSide(
                        color: AppTheme.errorColor,
                      ),
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomNavigationBar(
          context,
          Provider.of<AuthModel>(context),
          currentIndex: 3
      ),
    );
  }

  Widget _buildEditForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTextField(
          _nombreController,
          "Nombre",
          Icons.person,
        ),
        SizedBox(height: 16),
        _buildTextField(
          _apellidosController,
          "Apellidos",
          Icons.person_outline,
        ),
        SizedBox(height: 16),
        _buildTextField(
          _correoController,
          "Correo Electrónico",
          Icons.email,
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 16),
        _buildTextField(
          _telefonoController,
          "Número de Teléfono",
          Icons.phone,
          keyboardType: TextInputType.phone,
          errorText: _telefonoError,
        ),
        SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _restoreOriginalData();
                  setState(() => _isEditing = false);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[800],
                  side: BorderSide(color: Colors.grey[400]!),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text("Cancelar"),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                    strokeWidth: 2,
                  ),
                )
                    : Text("Guardar Cambios"),
              ),
            ),
          ],
        ),
      ],
    );
  }
}