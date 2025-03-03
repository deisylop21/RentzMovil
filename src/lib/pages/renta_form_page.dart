import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/auth_model.dart';
import '../models/cart_model.dart';
import '../models/renta2_model.dart';
import '../api/rentas_api.dart';
import '../api/direccion_api.dart';
import '../models/direccion_model.dart';

class RentaFormPage extends StatefulWidget {
  final CartItem cartItem;

  const RentaFormPage({
    Key? key,
    required this.cartItem,
  }) : super(key: key);

  @override
  _RentaFormPageState createState() => _RentaFormPageState();
}

class _RentaFormPageState extends State<RentaFormPage> {
  DateTime? fechaInicio;
  DateTime? fechaFinal;
  late double total;
  List<Direccion> direcciones = [];
  Direccion? direccionSeleccionada;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    total = double.parse(widget.cartItem.total) + 50;
    _cargarDirecciones();
  }

  Future<void> _cargarDirecciones() async {
    setState(() => isLoading = true);
    try {
      final authModel = Provider.of<AuthModel>(context, listen: false);
      final fetchedDirecciones = await DireccionesApi().fetchDirecciones(authModel.token!);

      setState(() {
        direcciones = fetchedDirecciones;
        if (direcciones.isNotEmpty) {
          direccionSeleccionada = direcciones.first;
        }
      });
    } catch (e) {
      _mostrarError("Error al cargar direcciones: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _mostrarExito(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      locale: const Locale('es', ''),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        fechaInicio = pickedDate;
        fechaFinal = pickedDate.add(Duration(days: 3));
      });
    }
  }

  Future<void> _rentarProducto() async {
    if (!_validarFormulario()) return;

    setState(() => isLoading = true);
    try {
      final authModel = Provider.of<AuthModel>(context, listen: false);

      final renta = Renta2(
        idProducto: widget.cartItem.idProducto,
        idDireccion: direccionSeleccionada!.id!,
        fechaInicio: fechaInicio!.toIso8601String(),
        fechaFinal: fechaFinal!.toIso8601String(),
        costoEnvio: 50,
        total: total,
      );

      await RentasApi().crearRenta(authModel.token!, renta);
      _mostrarExito("Renta creada con éxito");
      Navigator.popUntil(context, ModalRoute.withName('/cart'));
    } catch (e) {
      _mostrarError("Error al crear la renta: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  bool _validarFormulario() {
    if (fechaInicio == null) {
      _mostrarError("Selecciona una fecha de inicio");
      return false;
    }
    if (direccionSeleccionada == null) {
      _mostrarError("Selecciona una dirección de entrega");
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Formulario de Renta"),
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProductCard(),
            SizedBox(height: 16),
            _buildDireccionCard(),
            SizedBox(height: 16),
            _buildFechasCard(),
            SizedBox(height: 24),
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Detalles del Producto",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            Image.network(
              widget.cartItem.urlImagenPrincipal,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Icon(Icons.error),
            ),
            SizedBox(height: 8),
            Text(
              widget.cartItem.nombreProducto,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(widget.cartItem.descripcion),
            SizedBox(height: 8),
            Text(
              "Costo total: \$${total.toStringAsFixed(2)}",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDireccionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Dirección de Entrega",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            if (direcciones.isEmpty)
              _buildNoDireccionesWidget()
            else
              DropdownButtonFormField<Direccion>(
                value: direccionSeleccionada,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Selecciona una dirección",
                ),
                onChanged: (Direccion? nuevaDireccion) {
                  setState(() => direccionSeleccionada = nuevaDireccion);
                },
                items: direcciones.map((direccion) {
                  return DropdownMenuItem(
                    value: direccion,
                    child: Text("${direccion.calle} #${direccion.numeroExterior}"),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDireccionesWidget() {
    return Column(
      children: [
        Text("No hay direcciones registradas"),
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, '/direcciones'),
          child: Text("Agregar Dirección"),
        ),
      ],
    );
  }

  Widget _buildFechasCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Fechas de Renta",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _seleccionarFecha,
              icon: Icon(Icons.calendar_today),
              label: Text(
                fechaInicio == null
                    ? "Seleccionar Fecha de Inicio"
                    : "Inicio: ${fechaInicio!.toLocal().toString().split(' ')[0]}\n"
                    "Fin: ${fechaFinal!.toLocal().toString().split(' ')[0]}",
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return ElevatedButton(
      onPressed: isLoading ? null : _rentarProducto,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          isLoading ? "Procesando..." : "Confirmar Renta",
          style: TextStyle(fontSize: 18),
        ),
      ),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 50),
      ),
    );
  }
}