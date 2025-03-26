import 'package:flutter/material.dart';
import '../api/direccion_api.dart';
import '../models/direccion_model.dart';
import 'package:provider/provider.dart';
import '../models/auth_model.dart';
import '../theme/app_theme.dart';
import '../widgets/maps_validation_dialog.dart';

class EditarDireccionPage extends StatefulWidget {
  final Direccion direccion;

  EditarDireccionPage({required this.direccion});

  @override
  _EditarDireccionPageState createState() => _EditarDireccionPageState();
}

class _EditarDireccionPageState extends State<EditarDireccionPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController calleController;
  late TextEditingController numeroExteriorController;
  late TextEditingController numeroInteriorController;
  late TextEditingController codigoPostalController;
  late TextEditingController coloniaController;
  late TextEditingController referenciaController;
  late TextEditingController numeroContactoController;
  bool direccionPrioritaria = false;
  bool _isLoading = false;
  bool _locationValidated = false;
  String? _googleMapsUrl;

  @override
  void initState() {
    super.initState();
    calleController = TextEditingController(text: widget.direccion.calle);
    numeroExteriorController = TextEditingController(text: widget.direccion.numeroExterior);
    numeroInteriorController = TextEditingController(text: widget.direccion.numeroInterior ?? "");
    codigoPostalController = TextEditingController(text: widget.direccion.codigoPostal);
    coloniaController = TextEditingController(text: widget.direccion.colonia);
    referenciaController = TextEditingController(text: widget.direccion.referencia ?? "");
    numeroContactoController = TextEditingController(text: widget.direccion.numeroContacto);
    direccionPrioritaria = widget.direccion.direccionPrioritaria;
    _googleMapsUrl = widget.direccion.googleMapsUrl;
    _locationValidated = widget.direccion.googleMapsUrl != null;
  }

  @override
  void dispose() {
    calleController.dispose();
    numeroExteriorController.dispose();
    numeroInteriorController.dispose();
    codigoPostalController.dispose();
    coloniaController.dispose();
    referenciaController.dispose();
    numeroContactoController.dispose();
    super.dispose();
  }
  bool _validarCamposRequeridos() {
    return calleController.text.isNotEmpty &&
        numeroExteriorController.text.isNotEmpty &&
        codigoPostalController.text.isNotEmpty &&
        coloniaController.text.isNotEmpty;
  }

  Future<void> _validarUbicacion() async {
    if (!_validarCamposRequeridos()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, complete los campos obligatorios primero'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final direccionQuery = '${calleController.text}+${numeroExteriorController.text}+${coloniaController.text}+${codigoPostalController.text}';

    final result = await showDialog<String>(
      context: context,
      builder: (context) => MapsValidationDialog(
        direccionQuery: direccionQuery,
      ),
    );

    if (result != null) {
      setState(() {
        _googleMapsUrl = result;
        _locationValidated = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ubicación validada correctamente'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _guardarCambios() async {
    if (!_locationValidated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, valide la ubicación primero'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authModel = Provider.of<AuthModel>(context, listen: false);
        final nuevaDireccion = Direccion(
          id: widget.direccion.id,
          calle: calleController.text,
          numeroExterior: numeroExteriorController.text,
          numeroInterior: numeroInteriorController.text.isEmpty ? null : numeroInteriorController.text,
          codigoPostal: codigoPostalController.text,
          colonia: coloniaController.text,
          referencia: referenciaController.text.isEmpty ? null : referenciaController.text,
          numeroContacto: numeroContactoController.text,
          direccionPrioritaria: direccionPrioritaria,
          googleMapsUrl: _googleMapsUrl,
        );

        await DireccionesApi().updateDireccion(authModel.token ?? "", widget.direccion.id!, nuevaDireccion);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Dirección actualizada correctamente"),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al actualizar la dirección: ${e.toString()}"),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    bool isOptional = false,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppTheme.primaryColor),
          suffixIcon: isOptional
              ? Tooltip(
            message: "Campo opcional",
            child: Icon(
              Icons.info_outline,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.primaryColor.withOpacity(0.2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.primaryColor.withOpacity(0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
          ),
          filled: true,
          fillColor: AppTheme.White,
        ),
        validator: validator,
        keyboardType: keyboardType,
      ),
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
        AppTheme.primaryColor,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
    ),
    ),
    ),
    title: Text(
    "Editar Dirección", style: TextStyle(
      color: AppTheme.White,
      fontWeight: FontWeight.bold,
    ),
    ),
          centerTitle: true,
          elevation: 0,
    leading: IconButton(
    icon: Icon(Icons.arrow_back_ios, color: AppTheme.White),
    onPressed: () => Navigator.pop(context),
    ),
    ),
    body: Container(
    decoration: BoxDecoration(
    gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
    AppTheme.White,
    AppTheme.White,
    ],
    ),
    ),
    child: SingleChildScrollView(
    padding: EdgeInsets.all(16.0),
    child: Form(
    key: _formKey,
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
    Card(
    elevation: 2,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildFormField(
              controller: calleController,
              label: "Calle",
              icon: Icons.add_road,
              validator: (value) => value!.isEmpty ? "Ingrese la calle" : null,
            ),
            Row(
              children: [
                Expanded(
                  child: _buildFormField(
                    controller: numeroExteriorController,
                    label: "Número Exterior",
                    icon: Icons.home_outlined,
                    validator: (value) =>
                    value!.isEmpty ? "Ingrese el número exterior" : null,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildFormField(
                    controller: numeroInteriorController,
                    label: "Número Interior",
                    icon: Icons.apartment_outlined,
                    isOptional: true,
                  ),
                ),
              ],
            ),
            _buildFormField(
              controller: codigoPostalController,
              label: "Código Postal",
              icon: Icons.local_post_office_outlined,
              validator: (value) =>
              value!.isEmpty ? "Ingrese el código postal" : null,
              keyboardType: TextInputType.number,
            ),
            _buildFormField(
              controller: coloniaController,
              label: "Colonia",
              icon: Icons.location_city_outlined,
              validator: (value) =>
              value!.isEmpty ? "Ingrese la colonia" : null,
            ),
            _buildFormField(
              controller: referenciaController,
              label: "Referencia",
              icon: Icons.info_outline,
              isOptional: true,
            ),
            _buildFormField(
              controller: numeroContactoController,
              label: "Número de Contacto",
              icon: Icons.phone_outlined,
              validator: (value) =>
              value!.isEmpty ? "Ingrese el número de contacto" : null,
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _validarUbicacion,
              icon: Icon(_locationValidated ? Icons.check_circle : Icons.map),
              label: Text(_locationValidated ? "Ubicación validada" : "Validar ubicación"),
              style: ElevatedButton.styleFrom(
                backgroundColor: _locationValidated ? AppTheme.successColor : AppTheme.darkTurquoise,
                foregroundColor: AppTheme.White,
                padding: EdgeInsets.symmetric(horizontal: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 16),
            SwitchListTile(
              title: Text(
                "Dirección Prioritaria",
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                "Esta será tu dirección principal",
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.primaryColor,
                ),
              ),
              value: direccionPrioritaria,
              onChanged: (value) {
                setState(() {
                  direccionPrioritaria = value;
                });
              },
              activeColor: AppTheme.secondaryColor,
            ),
          ],
        ),
      ),
    ),
      SizedBox(height: 24),
      ElevatedButton(
        onPressed: _isLoading ? null : _guardarCambios,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: AppTheme.White,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.White),
            strokeWidth: 2,
          ),
        )
            : Text(
          "Guardar Cambios",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
    ),
    ),
    ),
    ),
    );
  }
}