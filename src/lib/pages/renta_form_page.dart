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
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    total = double.parse(widget.cartItem.total) + 50;
    _cargarDirecciones();
  }

  String formatearFecha(DateTime fecha) {
    final meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return "${fecha.day} de ${meses[fecha.month - 1]} del ${fecha.year}";
  }

  Future<void> _cargarDirecciones() async {
    if (!mounted) return;

    setState(() => isLoading = true);
    try {
      final authModel = Provider.of<AuthModel>(context, listen: false);
      final fetchedDirecciones = await DireccionesApi().fetchDirecciones(authModel.token!);

      if (!mounted) return;

      setState(() {
        direcciones = fetchedDirecciones;
        if (direcciones.isNotEmpty) {
          direccionSeleccionada = direcciones.first;
        }
      });
    } catch (e) {
      if (!mounted) return;
      _mostrarError("Error al cargar direcciones: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _mostrarMensaje(String mensaje, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  void _mostrarError(String mensaje) => _mostrarMensaje(mensaje, isError: true);
  void _mostrarExito(String mensaje) => _mostrarMensaje(mensaje);

  Future<void> _seleccionarFecha() async {
    // Configuramos la fecha inicial como mañana
    final tomorrow = DateTime.now().add(const Duration(days: 1));

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: tomorrow, // Inicializamos con mañana en lugar de hoy
      firstDate: tomorrow, // Primera fecha disponible es mañana
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
            ),
          ),
          child: child ?? Container(),
        );
      },
    );

    if (pickedDate != null && mounted) {
      setState(() {
        fechaInicio = pickedDate;
        fechaFinal = pickedDate.add(const Duration(days: 3));
      });
    }
  }

  Future<void> _rentarProducto() async {
    if (!_validarFormulario()) return;
    if (isSubmitting) return;

    setState(() => isSubmitting = true);
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

      if (!mounted) return;

      _mostrarExito("Renta creada con éxito");
      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacementNamed('/cart');
    } catch (e) {
      if (!mounted) return;
      _mostrarError("Error al crear la renta: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
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
    return WillPopScope(
      onWillPop: () async {
        if (isSubmitting) {
          _mostrarError("Por favor espere mientras se procesa la renta");
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Formulario de Renta"),
          elevation: 0,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProductCard(),
              const SizedBox(height: 16),
              _buildDireccionCard(),
              const SizedBox(height: 16),
              _buildFechasCard(),
              const SizedBox(height: 24),
              _buildConfirmButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Detalles del Producto",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.cartItem.urlImagenPrincipal,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 50, color: Colors.grey[600]),
                      const SizedBox(height: 8),
                      Text(
                        'Error al cargar la imagen',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.cartItem.nombreProducto,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(widget.cartItem.descripcion),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Costo de envío:", style: TextStyle(color: Colors.grey[600])),
                const Text("\$50.00"),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total a pagar:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "\$${total.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDireccionCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Dirección de Entrega",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: Icon(Icons.add_location_alt),
                  onPressed: () => Navigator.pushNamed(context, '/direcciones'),
                  tooltip: 'Agregar Nueva Dirección',
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (direcciones.isEmpty)
              _buildNoDireccionesWidget()
            else
              Column(
                children: [
                  DropdownButtonFormField<Direccion>(
                    value: direccionSeleccionada,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintText: "Selecciona una dirección",
                      filled: true,
                      fillColor: Colors.grey[100],
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
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () async {
                      await Navigator.pushNamed(context, '/direcciones');
                      // Recargar las direcciones cuando regrese
                      if (mounted) {
                        _cargarDirecciones();
                      }
                    },
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text("Agregar Nueva Dirección"),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDireccionesWidget() {
    return Column(
      children: [
        const Icon(
          Icons.location_off,
          size: 48,
          color: Colors.grey,
        ),
        const SizedBox(height: 8),
        const Text(
          "No hay direcciones registradas",
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () async {
            await Navigator.pushNamed(context, '/direcciones');
            // Recargar las direcciones cuando regrese
            if (mounted) {
              _cargarDirecciones();
            }
          },
          icon: const Icon(Icons.add_location),
          label: const Text("Agregar Dirección"),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFechasCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Fechas de Renta",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _seleccionarFecha,
              icon: const Icon(Icons.calendar_today),
              label: Text(
                fechaInicio == null
                    ? "Seleccionar Fecha de Inicio"
                    : "Inicio: ${formatearFecha(fechaInicio!)}\n"
                    "Fin: ${formatearFecha(fechaFinal!)}",
                textAlign: TextAlign.center,
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return ElevatedButton(
      onPressed: (isLoading || isSubmitting) ? null : _rentarProducto,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSubmitting)
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  ),
                ),
              ),
            Text(
              isSubmitting ? "Procesando..." : "Confirmar Renta",
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}