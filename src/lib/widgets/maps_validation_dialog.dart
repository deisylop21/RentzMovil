import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
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
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller = WebViewController.fromPlatformCreationParams(params);

    final String encodedQuery = Uri.encodeComponent(widget.direccionQuery + " Merida Yucatan");
    final String searchUrl = 'https://www.google.com/maps/search/$encodedQuery/?hl=es';

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            controller.runJavaScript('''
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
                content: Text(
                  'Error al cargar el mapa: ${error.description}',
                ),
                backgroundColor: Colors.red,
              ),
            );
          },
        ),
      )
      ..loadRequest(Uri.parse(searchUrl));

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8, // Increased height
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20), // Slightly more rounded
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Validar ubicación',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Instruction Banner
            Container(
              width: double.infinity,
              color: Colors.orange[100],
              padding: EdgeInsets.all(12),
              child: Text(
                '👉 Toca el punto rojo del mapa para verificar la ubicación exacta, luego presiona "Confirmar ubicación".',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.orange[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
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
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[300]!,
                    offset: Offset(0, -2),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                    ),
                    child: Text('Cancelar'),
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
                            backgroundColor: Colors.orange,
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
                    ),
                    child: Text('Confirmar ubicación'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}