import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/auth_model.dart';
import '../models/cart_model.dart';
import '../models/renta2_model.dart';
import '../api/rentas_api.dart';
import '../api/direccion_api.dart';
import '../models/direccion_model.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card2.dart';
import '../widgets/CustomDireccionSelector.dart';
import '../widgets/fechas_card.dart';
import '../widgets/confirm_button.dart';

class RentaFormPage2 extends StatefulWidget {
  final List<CartItem> cartItems;

  const RentaFormPage2({
    Key? key,
    required this.cartItems,
  }) : super(key: key);

  @override
  _RentaFormPage2State createState() => _RentaFormPage2State();
}

class _RentaFormPage2State extends State<RentaFormPage2> {
  DateTime? fechaInicio;
  DateTime? fechaFinal;
  Direccion? direccionSeleccionada;
  bool isLoading = false;
  bool isSubmitting = false;
  List<Direccion> direcciones = []; // Declara la lista de direcciones

  @override
  void initState() {
    super.initState();
    _cargarDirecciones();
  }

  Future<void> _seleccionarFecha() async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    DateTime selectedDate = tomorrow;
    DateTime currentMonth = tomorrow;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Encabezado del calendario
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios, color: AppTheme.primaryColor),
                        onPressed: () {
                          setModalState(() {
                            currentMonth = DateTime(currentMonth.year, currentMonth.month - 1, 1);
                          });
                        },
                      ),
                      Text(
                        "${_obtenerNombreMes(currentMonth.month)} ${currentMonth.year}",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.text,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_forward_ios, color: AppTheme.primaryColor),
                        onPressed: () {
                          setModalState(() {
                            currentMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Cuadrícula de días del calendario
                  Container(
                    height: 320,
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: 31,
                      itemBuilder: (context, index) {
                        DateTime date = DateTime(currentMonth.year, currentMonth.month, index + 1);
                        bool isDisabled = date.isBefore(tomorrow);
                        return GestureDetector(
                          onTap: isDisabled
                              ? null
                              : () {
                            setModalState(() {
                              selectedDate = date;
                            });
                            Navigator.pop(context);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              color: selectedDate == date
                                  ? AppTheme.secondaryColor
                                  : isDisabled
                                  ? AppTheme.grey
                                  : AppTheme.container,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selectedDate == date ? AppTheme.secondaryColor : AppTheme.grey,
                                width: 2,
                              ),
                            ),
                            alignment: Alignment.center,
                            width: 40,
                            height: 40,
                            child: Text(
                              "${date.day}",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDisabled
                                    ? AppTheme.grey
                                    : selectedDate == date
                                    ? AppTheme.White
                                    : AppTheme.text,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    setState(() {
      fechaInicio = selectedDate;
      fechaFinal = selectedDate.add(const Duration(days: 3)); // Ajusta según tu lógica
    });
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
    setState(() => isLoading = true); // Muestra un indicador de carga
    try {
      final authModel = Provider.of<AuthModel>(context, listen: false);

      // Validar token
      if (authModel.token == null || authModel.token!.isEmpty) {
        throw Exception("Token de autenticación no disponible");
      }

      print("Cargando direcciones..."); // Depuración
      final fetchedDirecciones = await DireccionesApi().fetchDirecciones(authModel.token!);
      print("Direcciones cargadas: $fetchedDirecciones"); // Depuración

      if (!mounted) return;

      // Actualizar el estado con las direcciones cargadas
      setState(() {
        direcciones = fetchedDirecciones;
        if (direcciones.isNotEmpty) {
          direccionSeleccionada = direcciones.first; // Seleccionar la primera dirección por defecto
        }
      });
    } catch (e) {
      if (!mounted) return;

      // Manejar errores con más detalles
      String errorMessage = "Error desconocido";
      if (e is Exception) {
        errorMessage = e.toString();
      }
      print("Error al cargar direcciones: $errorMessage"); // Depuración
      _mostrarError("Error al cargar direcciones: $errorMessage");
    } finally {
      if (mounted) {
        setState(() => isLoading = false); // Ocultar el indicador de carga
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
        duration: const Duration(seconds: 3),
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

  Future<void> _procesarCarrito() async {
    if (widget.cartItems.isEmpty) {
      _mostrarError("El carrito está vacío");
      return;
    }

    if (direccionSeleccionada == null || fechaInicio == null || fechaFinal == null) {
      _mostrarError("Selecciona una dirección y las fechas antes de proceder");
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final authModel = Provider.of<AuthModel>(context, listen: false);
      bool allSuccess = true;

      for (var item in widget.cartItems) {
        try {
          final renta = Renta2(
            idProducto: item.idProducto,
            idDireccion: direccionSeleccionada!.id!,
            fechaInicio: fechaInicio!.toIso8601String(),
            fechaFinal: fechaFinal!.toIso8601String(),
            costoEnvio: 50, // Ajusta según tu lógica
            total: double.parse(item.total) + 50, // Ajusta según tu lógica
          );

          await RentasApi().crearRenta(authModel.token!, renta);
        } catch (e) {
          allSuccess = false;
          _mostrarError("Error al crear la renta para el producto ${item.nombreProducto}: ${e.toString()}");
          break; // Detener el proceso si hay un error
        }
      }

      if (allSuccess) {
        _mostrarExito("Todas las rentas se han creado con éxito");
        await Future.delayed(const Duration(milliseconds: 800));
        Navigator.of(context).pushReplacementNamed('/home'); // Redirigir al inicio
      }
    } catch (e) {
      _mostrarError("Error general al procesar el carrito: ${e.toString()}");
    } finally {
      setState(() => isSubmitting = false);
    }
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
          title: Text("Confirmar Compra", style: TextStyle(color: AppTheme.White, fontWeight: FontWeight.bold)),
          centerTitle: true,
          elevation: 0,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Resumen del carrito
              Text("Resumen del Carrito", style: AppTheme.titleStyle),
              SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: widget.cartItems.length,
                itemBuilder: (context, index) {
                  final item = widget.cartItems[index];
                  return ListTile(
                    leading: CachedNetworkImage(
                      imageUrl: item.urlImagenPrincipal,
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(item.nombreProducto),
                    subtitle: Text("\$${item.total}"),
                  );
                },
              ),
              SizedBox(height: 16),
              // Selector de fechas
              FechasCard(
                fechaInicio: fechaInicio,
                fechaFinal: fechaFinal,
                onSeleccionarFecha: _seleccionarFecha,
              ),
              SizedBox(height: 16),
              // Selector de dirección
              CustomDireccionSelector(
                direcciones: direcciones,
                direccionSeleccionada: direccionSeleccionada,
                onDireccionChanged: (nuevaDireccion) {
                  setState(() => direccionSeleccionada = nuevaDireccion);
                },
                onAddDireccionPressed: _cargarDirecciones,
              ),
              SizedBox(height: 16),
              // Botón para confirmar y procesar el carrito
              ConfirmButton(
                isLoading: isLoading || isSubmitting,
                isSubmitting: isSubmitting,
                onPressed: _procesarCarrito,
              ),
            ],
          ),
        ),
      ),
    );
  }
}