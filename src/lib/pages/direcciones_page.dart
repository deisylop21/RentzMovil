import 'package:flutter/material.dart';
import '../api/direccion_api.dart';
import '../models/direccion_model.dart';
import 'package:provider/provider.dart';
import '../models/auth_model.dart';
import '../theme/app_theme.dart';
import 'editar_direccion_page.dart';

class DireccionesPage extends StatefulWidget {
  @override
  _DireccionesPageState createState() => _DireccionesPageState();
}

class _DireccionesPageState extends State<DireccionesPage> {
  late Future<List<Direccion>> futureDirecciones;

  @override
  void initState() {
    super.initState();
    _cargarDirecciones();
  }

  void _cargarDirecciones() {
    final authModel = Provider.of<AuthModel>(context, listen: false);
    setState(() {
      futureDirecciones = DireccionesApi().fetchDirecciones(authModel.token ?? "");
    });
  }

  void _editarDireccion(Direccion direccion) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarDireccionPage(direccion: direccion),
      ),
    );
    if (result == true) {
      _cargarDirecciones();
    }
  }

  void _eliminarDireccion(int id) async {
    try {
      final authModel = Provider.of<AuthModel>(context, listen: false);
      await DireccionesApi().deleteDireccion(authModel.token ?? "", id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Dirección eliminada correctamente"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      _cargarDirecciones();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al eliminar la dirección: ${e.toString()}"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_off_outlined,
              size: 64,
              color: AppTheme.primaryColor,
            ),
          ),
          SizedBox(height: 24),
          Text(
            "No tienes direcciones registradas",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Agrega una nueva dirección para tus envíos",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _agregarDireccion,
            icon: Icon(Icons.add_location_alt),
            label: Text("Agregar Dirección"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(Direccion direccion) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
        Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.location_on,
          color: AppTheme.primaryColor,
          size: 24,
        ),
      ),
      SizedBox(width: 16),
      Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              if (direccion.direccionPrioritaria)
          Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: 14,
            color: AppTheme.secondaryColor,
          ),
          SizedBox(width: 4),
          Text(
            "Principal",
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.secondaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
    Text(
    "${direccion.calle} #${direccion.numeroExterior}",
    style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
    ),
    ),
    if (direccion.numeroInterior != null && direccion.numeroInterior!.isNotEmpty)
    Text(
    "Interior: ${direccion.numeroInterior}",
    style: TextStyle(
    fontSize: 14,
    color: Colors.grey[600],
    ),
    ),
    SizedBox(height: 4),
                Text(
                  "${direccion.colonia}",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  "CP: ${direccion.codigoPostal}",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                if (direccion.referencia?.isNotEmpty ?? false)
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      "Referencia: ${direccion.referencia}",
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    "Teléfono: ${direccion.numeroContacto}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
          ),
      ),
            ],
            ),
              Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _editarDireccion(direccion),
                    icon: Icon(Icons.edit_outlined),
                    label: Text("Editar"),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.accentColor,
                    ),
                  ),
                  SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _mostrarDialogoEliminar(direccion),
                    icon: Icon(Icons.delete_outline),
                    label: Text("Eliminar"),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
        ),
      ),
    );
  }

  void _mostrarDialogoEliminar(Direccion direccion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 28,
            ),
            SizedBox(width: 8),
            Text("Eliminar dirección"),
          ],
        ),
        content: Text(
          "¿Estás seguro de que deseas eliminar esta dirección? Esta acción no se puede deshacer.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancelar",
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              _eliminarDireccion(direccion.id!);
              Navigator.pop(context);
            },
            icon: Icon(Icons.delete_outline),
            label: Text("Eliminar"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _agregarDireccion() {
    final _formKey = GlobalKey<FormState>();
    final _calleController = TextEditingController();
    final _numeroExteriorController = TextEditingController();
    final _numeroInteriorController = TextEditingController();
    final _codigoPostalController = TextEditingController();
    final _coloniaController = TextEditingController();
    final _referenciaController = TextEditingController();
    final _numeroContactoController = TextEditingController();
    bool _direccionPrioritaria = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
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
                  Row(
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
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _calleController,
                    decoration: InputDecoration(
                      labelText: "Calle",
                      prefixIcon: Icon(Icons.add_road),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) => value!.isEmpty ? "Ingrese la calle" : null,
                  ),
                  SizedBox(height: 16),
                  Row(
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
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _codigoPostalController,
                    decoration: InputDecoration(
                      labelText: "Código Postal",
                      prefixIcon: Icon(Icons.local_post_office),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                    value!.isEmpty ? "Ingrese el código postal" : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _coloniaController,
                    decoration: InputDecoration(
                      labelText: "Colonia",
                      prefixIcon: Icon(Icons.location_city),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) =>
                    value!.isEmpty ? "Ingrese la colonia" : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _referenciaController,
                    decoration: InputDecoration(
                      labelText: "Referencia",
                      prefixIcon: Icon(Icons.info_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _numeroContactoController,
                    decoration: InputDecoration(
                      labelText: "Número de Contacto",
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) =>
                    value!.isEmpty ? "Ingrese el número de contacto" : null,
                  ),
                  SizedBox(height: 16),
                  SwitchListTile(
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
                  ),
                  SizedBox(height: 24),
                  Row(
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
                          onPressed: () async {
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

                                final authModel =
                                Provider.of<AuthModel>(context, listen: false);
                                await DireccionesApi()
                                    .addDireccion(authModel.token ?? "", nuevaDireccion);

                                Navigator.pop(context);
                                _cargarDirecciones();

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
                          },
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
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
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
        AppTheme.darkTurquoise,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
    ),
    ),
    ),
    title: Text(
    "Mis Direcciones",
    style: TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    ),
    ),
    centerTitle: true,
    elevation: 0,
    ),
    body: Container(
    decoration: BoxDecoration(
    gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
    Colors.grey[50]!,
    Colors.white,
    ],
    ),
    ),
    child: FutureBuilder<List<Direccion>>(
    future: futureDirecciones,
    builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
    return Center(
    child: CircularProgressIndicator(
    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
    ),
    );
    }

    if (snapshot.hasError) {
    return Center(
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Icon(
    Icons.error_outline,
    size: 64,
    color: Colors.red,
    ),
    SizedBox(height: 16),
    Text(
    "Error al cargar las direcciones",
    style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    ),
    ),
    SizedBox(height: 8),
    Text(
    snapshot.error.toString(),
    textAlign: TextAlign.center,
    style: TextStyle(color: Colors.grey[600]),
    ),
    SizedBox(height: 24),
    ElevatedButton.icon(
    onPressed: _cargarDirecciones,
    icon: Icon(Icons.refresh),
    label: Text("Reintentar"),
    style: ElevatedButton.styleFrom(
    backgroundColor: AppTheme.primaryColor,
    foregroundColor: Colors.white,
    ),
    ),
    ],
    ),
    );
    }

    if (!snapshot.hasData || snapshot.data!.isEmpty) {
    return _buildEmptyState();
    }

    return ListView.builder(
    padding: EdgeInsets.symmetric(vertical: 16),
    itemCount: snapshot.data!.length,
    itemBuilder: (context, index) {
    return _buildAddressCard(snapshot.data![index]);
    },
    );
    },
    ),
    ),
        floatingActionButton: FloatingActionButton(
          onPressed: _agregarDireccion,
          child: Icon(Icons.add_location_alt, size: 24),
          backgroundColor: AppTheme.secondaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
          mini: true, // Hace el FAB más pequeño
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
    );
  }
}