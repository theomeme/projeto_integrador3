import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseMessagingService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await _firebaseMessaging.getToken();
      print('Firebase Messaging token: $token');
    }
  }

  static void configureMessaging() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Mensagem recebida enquanto o aplicativo está em primeiro plano: ${message.notification?.body}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Lidar com a mensagem recebida enquanto o aplicativo está em segundo plano e é aberto pelo usuário
      print('Mensagem recebida enquanto o aplicativo está em segundo plano e é aberto pelo usuário: ${message.notification?.body}');
    });
  }
}