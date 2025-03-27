import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../theme/app_theme.dart';

class MapsValidationDialog extends StatefulWidget {
  final String direccionQuery;

  const MapsValidationDialog({
    Key? key,
    required this.direccionQuery,
  }) : super(key: key);

  @override
  _MapsValidationDialogState createState() => _MapsValidationDialogState();
}

class _MapsValidationDialogState extends State<MapsValidationDialog> {
  late final WebViewController _controller;
  bool isLoading = true;
  String currentUrl = '';

  @override
  void initState() {
    super.initState();

    // Inicialización del WebView
    final String encodedQuery = Uri.encodeComponent(widget.direccionQuery + " Merida Yucatan");
    final String searchUrl = 'https://www.google.com/maps/search/$encodedQuery/?hl=es';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            _controller.runJavaScript('''
              try {
                let coords = document.querySelector('meta[property="og:image"]')?.content;
                if (coords) {
                  let match = coords.match(/@(-?\\d+\\.\\d+),(-?\\d+\\.\\d+)/);
                  if (match) {
                    window.flutter_inappwebview.callHandler('updateCoords', match[1], match[2]);
                  }
                }
              } catch(e) {
                console.error('Error getting coordinates:', e);
              }
            ''');

            setState(() {
              isLoading = false;
              currentUrl = url;
            });
          },
          onWebResourceError: (WebResourceError error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al cargar el mapa: ${error.description}'),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          },
        ),
      )
      ..loadRequest(Uri.parse(searchUrl));
  }

  @override
  Widget build(BuildContext context) {
    // Acceder al tema actual
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.grey.withOpacity(0.2),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Ajustar al contenido
            children: [
              // Encabezado del diálogo
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: AppTheme.White),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Validar ubicación',
                        style: TextStyle(
                          color: AppTheme.White,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: AppTheme.White),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Banner de instrucciones
              Container(
                width: double.infinity,
                color: isDarkMode ? AppTheme.black : AppTheme.lightTurquoise,
                padding: EdgeInsets.all(12),
                child: Text(
                  '👉 Toca el punto rojo del mapa para verificar la ubicación exacta, luego presiona "Confirmar ubicación".',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDarkMode ? AppTheme.White : AppTheme.secondaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Contenido principal (WebView)
              Container(
                height: MediaQuery.of(context).size.height * 0.5, // Altura dinámica
                child: Stack(
                  children: [
                    WebViewWidget(controller: _controller),
                    if (isLoading)
                      Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                        ),
                      ),
                  ],
                ),
              ),

              // Pie de página con botones
              // Pie de página con botones
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.grey.withOpacity(0.1),
                      offset: Offset(0, -2),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end, // Alinea los botones a la derecha
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                      ),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(fontSize: 14), // Reducir el tamaño del texto
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (currentUrl.contains("@") && currentUrl.contains(",")) {
                          Navigator.pop(context, currentUrl);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Por favor, ajuste la ubicación en el mapa'),
                              backgroundColor: AppTheme.errorColor,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondaryColor,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        fixedSize: Size(150, 40), // Ancho y alto fijos para el botón
                      ),
                      child: Text(
                        'Confirmar ubicación',
                        style: TextStyle(fontSize: 14), // Reducir el tamaño del texto
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}