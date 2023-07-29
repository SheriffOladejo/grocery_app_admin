import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<String> getFirebaseToken() async {
    // Request permission for receiving notifications on Android
    await _firebaseMessaging.requestPermission(
      sound: true,
      badge: true,
      alert: true,
      provisional: false,
    );

    // Get the FCM token
    String token = await _firebaseMessaging.getToken();
    return token;
  }

  Future<void> setupFirebaseMessaging() async {
    // Request permission for receiving notifications on Android
    await _firebaseMessaging.requestPermission(
      sound: true,
      badge: true,
      alert: true,
      provisional: false,
    );

    // Get the FCM token
    String token = await _firebaseMessaging.getToken();
    print("FCM Token: $token");

    // Handle incoming messages when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground Message: ${message.notification?.body}");
      // Handle the notification payload as desired (e.g., show a notification dialog).
    });

    // Handle the background message when the app is terminated or in the background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Background Message: ${message.notification?.body}");
      // Handle the notification payload as desired (e.g., navigate to a specific page).
    });
  }
}
