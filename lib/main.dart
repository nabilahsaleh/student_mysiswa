import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:student_mysiswa/auth/auth.dart';
import 'package:student_mysiswa/fcm_service.dart';
import 'package:student_mysiswa/pages/appointment_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter bindings are initialized
  await Firebase.initializeApp(); // Initialize Firebase

  // Initialize Firebase Messaging
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Handle background and terminated state notification taps
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    _navigateToAppointmentPage();
  });

  // Handle notification taps when the app is in the foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    _navigateToAppointmentPage();
  });


  final FCMService fcmService = FCMService();
  await fcmService.initialize();

  runApp(const MyApp());
}

void _navigateToAppointmentPage() {
  navigatorKey.currentState?.push(
    MaterialPageRoute(
      builder: (context) => AppointmentPage(),
    ),
  );
}


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey, // Set the navigator key
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(
          headlineSmall: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(fontSize: 16.0, color: Colors.grey),
          bodyLarge: TextStyle(fontSize: 14.0),
        ),
      ),
      home: const AuthPage(),
    );
  }
}
