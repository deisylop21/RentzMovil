import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/direccion_model.dart';
import '../models/auth_model.dart';
import '../theme/app_theme.dart';
import '../api/direccion_api.dart';
import 'maps_validation_dialog.dart';

class NuevaDireccionForm extends StatefulWidget {
  final VoidCallback onDireccionAgregada;

  const NuevaDireccionForm({
    Key? key,
    required this.onDireccionAgregada,
  }) : super(key: key);

  @override
  _NuevaDireccionFormState createState() => _NuevaDireccionFormState();
}

class _NuevaDireccionFormState extends State<NuevaDireccionForm> {
  final _formKey = GlobalKey<FormState>();
  final _calleController = TextEditingController();
  final _numeroExteriorController = TextEditingController();
  final _numeroInteriorController = TextEditingController();
  final _codigoPostalController = TextEditingController();
  final _coloniaController = TextEditingController();
  final _referenciaController = TextEditingController();
  final _numeroContactoController = TextEditingController();
  bool _direccionPrioritaria = false;
  String? _googleMapsUrl;
  bool _locationValidated = false;
  bool _isLoading = false;

  Future<void> _validarUbicacion() async {
    if (!_validarCamposRequeridos()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, complete los campos obligatorios primero'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final direccionQuery = '${_calleController.text}+${_numeroExteriorController.text}+${_coloniaController.text}+${_codigoPostalController.text}';

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
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  bool _validarCamposRequeridos() {
    return _calleController.text.isNotEmpty &&
        _numeroExteriorController.text.isNotEmpty &&
        _codigoPostalController.text.isNotEmpty &&
        _coloniaController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              SizedBox(height: 20),
              _buildCalleField(),
              SizedBox(height: 16),
              _buildNumeroFields(),
              SizedBox(height: 16),
              _buildCodigoPostalField(),
              SizedBox(height: 16),
              _buildColoniaField(),
              SizedBox(height: 16),
              _buildReferenciaField(),
              SizedBox(height: 16),
              _buildNumeroContactoField(),
              SizedBox(height: 16),
              _buildPrioritariaSwitch(),
              SizedBox(height: 24),
              _buildValidationButton(),
              SizedBox(height: 16),
              _buildButtons(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.location_on, color: AppTheme.text),
        SizedBox(width: 8),
        Text(
          "Nueva Dirección",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.text,
          ),
        ),
        Spacer(),
        IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
          color: Colors.grey[600],
        ),
      ],
    );
  }

  Widget _buildValidationButton() {
    return ElevatedButton.icon(
      onPressed: _validarUbicacion,
      icon: Icon(_locationValidated ? Icons.check_circle : Icons.map),
      label: Text(_locationValidated ? "Ubicación validada" : "Validar ubicación"),
      style: ElevatedButton.styleFrom(
        backgroundColor: _locationValidated ? Colors.green : AppTheme.accentColor,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildCalleField() {
    return TextFormField(
      controller: _calleController,
      decoration: InputDecoration(
        labelText: "Calle",
        prefixIcon: Icon(Icons.add_road),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) => value!.isEmpty ? "Ingrese la calle" : null,
    );
  }

  Widget _buildNumeroFields() {
    return Row(
      children: [
    Expanded(
    child: TextFormField(
    controller: _numeroExteriorController,
      decoration: InputDecoration(
        labelText: "Número Exterior",
        prefixIcon: Icon(Icons.home),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) =>
      value!.isEmpty ? "Ingrese el número exterior" : null,
    ),
    ),
        SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            controller: _numeroInteriorController,
            decoration: InputDecoration(
              labelText: "Número Interior",
              prefixIcon: Icon(Icons.apartment),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCodigoPostalField() {
    return TextFormField(
      controller: _codigoPostalController,
      decoration: InputDecoration(
        labelText: "Código Postal",
        prefixIcon: Icon(Icons.local_post_office),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      keyboardType: TextInputType.number,
      validator: (value) => value!.isEmpty ? "Ingrese el código postal" : null,
      onChanged: (value) {
        if (value.length == 5) {
          // Aquí podrías agregar lógica adicional para autocompletar la colonia
          FocusScope.of(context).nextFocus();
        }
      },
      maxLength: 5,
      buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
    );
  }

  Widget _buildColoniaField() {
    return TextFormField(
      controller: _coloniaController,
      decoration: InputDecoration(
        labelText: "Colonia",
        prefixIcon: Icon(Icons.location_city),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) => value!.isEmpty ? "Ingrese la colonia" : null,
      textCapitalization: TextCapitalization.words,
    );
  }

  Widget _buildReferenciaField() {
    return TextFormField(
      controller: _referenciaController,
      decoration: InputDecoration(
        labelText: "Referencia",
        prefixIcon: Icon(Icons.info_outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        helperText: "Ejemplo: Casa color azul, frente al parque",
      ),
      maxLines: 2,
      textCapitalization: TextCapitalization.sentences,
    );
  }

  Widget _buildNumeroContactoField() {
    return TextFormField(
      controller: _numeroContactoController,
      decoration: InputDecoration(
        labelText: "Número de Contacto",
        prefixIcon: Icon(Icons.phone),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value!.isEmpty) {
          return "Ingrese el número de contacto";
        }
        if (value.length < 10) {
          return "El número debe tener 10 dígitos";
        }
        return null;
      },
      maxLength: 10,
      buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
    );
  }

  Widget _buildPrioritariaSwitch() {
    return SwitchListTile(
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
          color: Colors.grey[600],
        ),
      ),
      value: _direccionPrioritaria,
      onChanged: (value) {
        setState(() {
          _direccionPrioritaria = value;
        });
      },
      activeColor: AppTheme.secondaryColor,
    );
  }
  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text("Cancelar", style: TextStyle(color: AppTheme.text),),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _locationValidated ? _guardarDireccion : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: Colors.grey[300],
            ),
            child: _isLoading
                ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2,
              ),
            )
                : Text(
              "Guardar",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _guardarDireccion() async {
    if (!_locationValidated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, valide la ubicación primero'),
          backgroundColor: Colors.orange,
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
        final nuevaDireccion = Direccion(
          calle: _calleController.text,
          numeroExterior: _numeroExteriorController.text,
          numeroInterior: _numeroInteriorController.text.isNotEmpty
              ? _numeroInteriorController.text
              : null,
          codigoPostal: _codigoPostalController.text,
          colonia: _coloniaController.text,
          referencia: _referenciaController.text.isNotEmpty
              ? _referenciaController.text
              : null,
          numeroContacto: _numeroContactoController.text,
          direccionPrioritaria: _direccionPrioritaria,
          googleMapsUrl: _googleMapsUrl,
        );

        final authModel = Provider.of<AuthModel>(context, listen: false);
        await DireccionesApi().addDireccion(authModel.token ?? "", nuevaDireccion);

        Navigator.pop(context);
        widget.onDireccionAgregada();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Dirección agregada correctamente"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al agregar la dirección: ${e.toString()}"),
            backgroundColor: Colors.red,
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
  String _formatearDireccion() {
    List<String> partes = [
      _calleController.text,
      "No. ${_numeroExteriorController.text}",
      if (_numeroInteriorController.text.isNotEmpty)
        "Int. ${_numeroInteriorController.text}",
      "Col. ${_coloniaController.text}",
      "C.P. ${_codigoPostalController.text}",
    ];
    return partes.join(", ");
  }

  void _mostrarPreviewDireccion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.location_on, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text("Confirmar Ubicación"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "¿La dirección es correcta?",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(_formatearDireccion()),
            if (_referenciaController.text.isNotEmpty) ...[
              SizedBox(height: 8),
              Text(
                "Referencia:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(_referenciaController.text),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Editar"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _guardarDireccion();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: Text("Confirmar"),
          ),
        ],
      ),
    );
  }

  void _limpiarFormulario() {
    _calleController.clear();
    _numeroExteriorController.clear();
    _numeroInteriorController.clear();
    _codigoPostalController.clear();
    _coloniaController.clear();
    _referenciaController.clear();
    _numeroContactoController.clear();
    setState(() {
      _direccionPrioritaria = false;
      _locationValidated = false;
      _googleMapsUrl = null;
    });
  }

  @override
  void dispose() {
    _calleController.dispose();
    _numeroExteriorController.dispose();
    _numeroInteriorController.dispose();
    _codigoPostalController.dispose();
    _coloniaController.dispose();
    _referenciaController.dispose();
    _numeroContactoController.dispose();
    super.dispose();
  }
}