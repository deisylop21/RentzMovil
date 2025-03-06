import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';

// Esta función debe estar fuera de la clase y a nivel superior
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Asegurarse de que se registre incluso cuando la app está en segundo plano
  print('Manejando notificación en segundo plano:');
  print('Título: ${message.notification?.title}');
  print('Cuerpo: ${message.notification?.body}');
  print('Datos: ${message.data}');
}

class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final MethodChannel _channel = const MethodChannel('app.channel.notification');

  // Callback para manejar tap en notificaciones
  Function(RemoteMessage)? onNotificationTapped;

  Future<String?> initNotifications() async {
    try {
      // Solicitar permisos
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        announcement: true,
        carPlay: true,
        criticalAlert: true,
      );

      print('Estado de permisos de notificación: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Configurar manejadores de mensajes para diferentes estados de la app
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          _handleBackgroundMessage(message);
          // Llamar al callback si está definido
          onNotificationTapped?.call(message);
        });

        // Manejar notificaciones cuando la app está cerrada
        final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
        if (initialMessage != null) {
          _handleBackgroundMessage(initialMessage);
          // Llamar al callback si está definido
          onNotificationTapped?.call(initialMessage);
        }

        // Configurar el manejo de mensajes en segundo plano
        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

        // Obtener y retornar el token FCM
        final fcmToken = await _firebaseMessaging.getToken();
        print('FCM Token obtenido: $fcmToken');

        // Configurar listener para actualización del token
        _firebaseMessaging.onTokenRefresh.listen((newToken) async {
          print('FCM Token actualizado: $newToken');
          await _updateTokenInBackend(newToken);
        });

        // Suscribirse a tópicos si es necesario
        await _subscribeToTopics();

        return fcmToken;
      }
      return null;
    } catch (e) {
      print('Error al inicializar notificaciones: $e');
      return null;
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Mensaje recibido en primer plano:');
    print('Título: ${message.notification?.title}');
    print('Cuerpo: ${message.notification?.body}');
    print('Datos: ${message.data}');

    try {
      // Verificar si debemos mostrar la notificación
      final bool shouldShow = _shouldShowNotification(message);
      if (!shouldShow) return;

      // Usar el canal nativo para mostrar la notificación
      await _channel.invokeMethod('showNotification', {
        'title': message.notification?.title ?? 'Nueva notificación',
        'body': message.notification?.body ?? '',
        'id': message.hashCode,
        'imageUrl': message.notification?.android?.imageUrl,
        'data': message.data,
        'channelId': message.data['channel_id'] ?? 'high_importance_channel',
        'priority': 'high',
        'sound': true,
        'vibrate': true,
      });
    } catch (e) {
      print('Error al mostrar notificación: $e');
    }
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    print('Aplicación abierta desde notificación:');
    print('Título: ${message.notification?.title}');
    print('Cuerpo: ${message.notification?.body}');
    print('Datos: ${message.data}');
  }

  // Método para actualizar el token en el backend
  Future<void> _updateTokenInBackend(String token) async {
    try {
      // Implementa aquí la lógica para actualizar el token en tu backend
      print('Actualizando token en el backend: $token');
    } catch (e) {
      print('Error al actualizar token en el backend: $e');
    }
  }

  // Método para suscribirse a tópicos
  Future<void> _subscribeToTopics() async {
    try {
      await _firebaseMessaging.subscribeToTopic('general');
      // Añade más suscripciones según necesites
    } catch (e) {
      print('Error al suscribirse a tópicos: $e');
    }
  }

  // Método para decidir si mostrar una notificación
  bool _shouldShowNotification(RemoteMessage message) {
    // Implementa tu lógica aquí
    // Por ejemplo, no mostrar si la notificación es silenciosa
    if (message.data['silent'] == 'true') return false;
    return true;
  }

  // Método público para suscribirse a un tópico específico
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('Suscrito al tópico: $topic');
    } catch (e) {
      print('Error al suscribirse al tópico $topic: $e');
    }
  }

  // Método público para desuscribirse de un tópico
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('Desuscrito del tópico: $topic');
    } catch (e) {
      print('Error al desuscribirse del tópico $topic: $e');
    }
  }
}