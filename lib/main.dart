import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:student_mysiswa/auth/auth.dart';
import 'package:student_mysiswa/pages/appointment_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter bindings are initialized
  await Firebase.initializeApp(); // Initialize Firebase

  // Initialize local notifications
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Set up Firestore listener for changes in 'bookings' collection
  FirebaseFirestore.instance
      .collection('bookings')
      .snapshots()
      .listen((QuerySnapshot snapshot) {
    for (var change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.modified) {
        var data = change.doc.data() as Map<String, dynamic>;
        String status = data['status'] ?? '';
        String userId = data['userId'] ?? ''; // Get user ID from document

        if (status == 'canceled by admin' || status == 'completed') {
          _sendNotificationToUser(userId, flutterLocalNotificationsPlugin, status);
        }
      }
    }
  });

  // Handle background and terminated state notification taps
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    _navigateToAppointmentPage();
  });

  // Handle notification taps when the app is in the foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    _navigateToAppointmentPage();
  });

  runApp(const MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void _navigateToAppointmentPage() {
  navigatorKey.currentState?.push(
    MaterialPageRoute(
      builder: (context) => const AppointmentPage(),
    ),
  );
}

Future<void> _sendNotificationToUser(
    String userId,
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    String status) async {
  // Get the current user's ID
  final currentUser = FirebaseAuth.instance.currentUser;
  
  // Check if the current user is the one whose appointment is affected
  if (currentUser?.uid == userId) {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'appointment_channel', // Use a consistent channel ID
      'Appointment Notifications',
      channelDescription: 'Notifications related to appointment actions',
      importance: Importance.max,
      priority: Priority.high,
      icon: 'mipmap/ic_notification',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      'Appointment Update', // Notification Title
      'Your appointment has been $status.', // Notification Body
      platformChannelSpecifics,
    );
  }
}

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
