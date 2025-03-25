import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/auth_model.dart';
import '../models/cart_model.dart';
import '../models/renta2_model.dart';
import '../models/direccion_model.dart';
import '../api/rentas_api.dart';
import '../api/direccion_api.dart';
import '../theme/app_theme.dart';

import '../widgets/product_card2.dart';
import '../widgets/direccion_card2.dart';
import '../widgets/fechas_card.dart';
import '../widgets/confirm_button.dart';

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

  // Helper Methods
  String formatearFecha(DateTime fecha) {
    final meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return "${fecha.day} de ${meses[fecha.month - 1]} del ${fecha.year}";
  }

  String _obtenerNombreMes(int mes) {
    const nombresMeses = [
      "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
      "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
    ];
    return nombresMeses[mes - 1];
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
        backgroundColor: isError ? AppTheme.errorColor : AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: AppTheme.White,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  void _mostrarError(String mensaje) => _mostrarMensaje(mensaje, isError: true);
  void _mostrarExito(String mensaje) => _mostrarMensaje(mensaje);

  Future<void> _seleccionarFecha() async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    DateTime selectedDate = tomorrow;
    DateTime currentMonth = tomorrow;

    // [Keep your existing _seleccionarFecha implementation]
    // Omitted for brevity, but would be the same as in the original code
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
              ProductCard(
                  cartItem: widget.cartItem,
                  total: total
              ),
              const SizedBox(height: 16),
              DireccionCard(
                direcciones: direcciones,
                direccionSeleccionada: direccionSeleccionada,
                onDireccionChanged: (direccion) {
                  setState(() => direccionSeleccionada = direccion);
                },
                onRecargarDirecciones: _cargarDirecciones,
              ),
              const SizedBox(height: 16),
              FechasCard(
                fechaInicio: fechaInicio,
                fechaFinal: fechaFinal,
                onSeleccionarFecha: _seleccionarFecha,
                formatearFecha: formatearFecha,
              ),
              const SizedBox(height: 24),
              ConfirmButton(
                isLoading: isLoading,
                isSubmitting: isSubmitting,
                onConfirm: _rentarProducto,
              ),
            ],
          ),
        ),
      ),
    );
  }
}