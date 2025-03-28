import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart'; // Importar intl
import '../api/rentas_api.dart';
import '../models/renta_model.dart';
import '../models/auth_model.dart';
import '../theme/app_theme.dart';

class RentaDetailPage extends StatefulWidget {
  final int idRenta;
  RentaDetailPage({required this.idRenta});

  @override
  _RentaDetailPageState createState() => _RentaDetailPageState();
}

class _RentaDetailPageState extends State<RentaDetailPage> {
  late Future<Renta> _rentaFuture;

  @override
  void initState() {
    super.initState();
    final authModel = Provider.of<AuthModel>(context, listen: false);
    _rentaFuture = RentasApi().fetchRentaById(authModel.token!, widget.idRenta);
  }

  Future<void> _realizarPago() async {
    final authModel = Provider.of<AuthModel>(context, listen: false);
    try {
      String urlPago = await RentasApi().generarPago(authModel.token!, widget.idRenta);
      final Uri uri = Uri.parse(urlPago);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'No se pudo abrir el enlace de pago';
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $error"),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.text,
          ),
        ),
        SizedBox(height: 4),
        Text(
          content,
          style: TextStyle(
            fontSize: 18,
            color: AppTheme.text,
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color statusColor;
    String statusText;
    switch (status.toLowerCase().trim()) {
      case 'pendiente_pago':
        statusColor = AppTheme.errorColor;
        statusText = 'Pendiente de pago'; // Mantener consistencia en mayúsculas
        break;
      case 'pendiente':
        statusColor = AppTheme.successColor;
        statusText = 'Pagado';
        break;
      case 'en transito_envio':
        statusColor = AppTheme.successColor;
        statusText = 'Enviado - En tránsito'; // Mejor formato y ortografía
        break;
      case 'en transito_recoleccion':
        statusColor = AppTheme.secondaryColor;
        statusText = 'En recolección'; // Ortografía correcta
        break;
      case 'finalizado':
        statusColor = AppTheme.text;
        statusText = 'Finalizado';
        break;
      case 'entregado':
        statusColor = AppTheme.successColorDark;
        statusText = 'entregado';
        break;
      default:
        statusColor = AppTheme.text;
        statusText = status;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.5)),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: statusColor,
          fontWeight: FontWeight.w600,
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
        AppTheme.primaryColor,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
    ),
    ),
    ),
    title: Text(
    'Detalles de la Renta', style: TextStyle(
      color: AppTheme.White,
      fontWeight: FontWeight.bold,
    ),
    ),
          centerTitle: true,
          elevation: 0,
    ),
    body: FutureBuilder<Renta>(
    future: _rentaFuture,
    builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
    return Center(
    child: CircularProgressIndicator(
    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
    ),
    );
    } else if (snapshot.hasError) {
    return Center(
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Icon(
    Icons.error_outline,
    size: 60,
    color: AppTheme.errorColor,
    ),
    SizedBox(height: 16),
    Text(
    "Error: ${snapshot.error}",
    style: TextStyle(color: AppTheme.errorColor),
    textAlign: TextAlign.center,
    ),
    ],
    ),
    );
    } else if (!snapshot.hasData) {
    return Center(
    child: Text("No se encontró la renta"),
    );
    }
    final renta = snapshot.data!;
    String fechaEntrega =
    DateFormat('EEEE, d MMMM yyyy', 'es').format(renta.fechaInicio);
    String fechaRecogida =
    DateFormat('EEEE, d MMMM yyyy', 'es').format(renta.fechaFinal);

    return SingleChildScrollView(
    physics: BouncingScrollPhysics(),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    // Imagen del producto
    Container(
    width: double.infinity,
    height: 250,
    decoration: BoxDecoration(
    color: AppTheme.grey,
    ),
    child: Hero(
    tag: 'renta_${renta.idRentaProducto}',
    child: Image.network(
    renta.urlImagenPrincipal,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) => Icon(
    Icons.image_not_supported,
    size: 100,
    color: AppTheme.grey,
    ),
    ),
    ),
    ),
      // Contenido
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título y estado
            Row(
              children: [
                Expanded(
                  child: Text(
                    renta.nombreProducto,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.text,
                    ),
                  ),
                ),
                _buildStatusChip(renta.estado),
              ],
            ),
            SizedBox(height: 24),
            // Precios
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Precio base",
                        style: TextStyle(
                          color: AppTheme.text,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "\$${renta.precio}",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.text,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Total a pagar",
                        style: TextStyle(
                          color: AppTheme.text,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "\$${renta.total}",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            // Descripción
            Card(
              elevation: 0,
              color: AppTheme.backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Descripción",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.text,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      renta.descripcion,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.text,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            // Información de entrega
            Card(
              elevation: 0,
              color: AppTheme.backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Información de entrega",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.text,
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildInfoSection(
                      "Dirección",
                      "${renta.calle} ${renta.numeroExterior}, ${renta.colonia}",
                    ),
                    _buildInfoSection("C.P.", renta.codigoPostal),
                    _buildInfoSection("Referencia", renta.referencia),
                    _buildInfoSection("Contacto", renta.numeroContacto),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.text,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: AppTheme.text,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Entrega programada para el $fechaEntrega\nentre las 9 AM y 5 PM\n"
                                  "Recogida programada para el $fechaRecogida\nentre las 9 AM y 5 PM",
                              style: TextStyle(
                                color: AppTheme.text,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ],
    ),
    );
    },
    ),
      bottomNavigationBar: FutureBuilder<Renta>(
        future: _rentaFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.estado == "Pendiente_Pago") {
            return Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.black.withOpacity(0.3),
                    offset: Offset(0, -4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _realizarPago,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successColor,
                  foregroundColor: AppTheme.backgroundColor,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "REALIZAR PAGO",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }
          return SizedBox.shrink();
        },
      ),
    );
  }
}