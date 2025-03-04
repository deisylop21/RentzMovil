import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/direccion_model.dart';
import '../models/auth_model.dart';
import '../theme/app_theme.dart';
import '../api/direccion_api.dart';

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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
        Icon(Icons.location_on, color: AppTheme.primaryColor),
        SizedBox(width: 8),
        Text(
          "Nueva Dirección",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
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
      ),
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
      validator: (value) => value!.isEmpty ? "Ingrese el número de contacto" : null,
    );
  }

  Widget _buildPrioritariaSwitch() {
    return SwitchListTile(
      title: Text("Dirección Prioritaria"),
      subtitle: Text(
        "Esta será tu dirección principal",
        style: TextStyle(fontSize: 12),
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
            child: Text("Cancelar"),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _guardarDireccion,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text("Guardar"),
          ),
        ),
      ],
    );
  }

  void _guardarDireccion() async {
    if (_formKey.currentState!.validate()) {
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
      }
    }
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