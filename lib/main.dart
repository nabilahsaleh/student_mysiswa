import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:student_mysiswa/auth/auth.dart';
import 'package:student_mysiswa/pages/appointment_page.dart';
import 'package:student_mysiswa/pages/announcement_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
      if (notificationResponse.payload == 'announcement') {
        _navigateToAnnouncementPage();
      } else {
        _navigateToAppointmentPage();
      }
    },
  );

  // Listen for changes in 'bookings' collection
  FirebaseFirestore.instance.collection('bookings').snapshots().listen((QuerySnapshot snapshot) {
    for (var change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.modified) {
        var data = change.doc.data() as Map<String, dynamic>;
        String status = data['status'] ?? '';
        String userId = data['userId'] ?? '';

        if (status == 'canceled by admin' || status == 'completed') {
          _sendNotificationToUser(userId, flutterLocalNotificationsPlugin, status);
        }
      }
    }
  });

  // Listen for new documents in 'announcements' collection
  FirebaseFirestore.instance.collection('announcements').snapshots().listen((QuerySnapshot snapshot) {
    for (var change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.added) {
        var data = change.doc.data() as Map<String, dynamic>;
        String title = data['title'] ?? 'New Announcement';
        String body = data['body'] ?? 'Check out the latest announcement!';
        _sendAnnouncementNotification(flutterLocalNotificationsPlugin, title, body);
      }
    }
  });

  // Handle background and terminated state notification taps
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (message.data['type'] == 'announcement') {
      _navigateToAnnouncementPage();
    } else {
      _navigateToAppointmentPage();
    }
  });

  // Handle notification taps when the app is in the foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.data['type'] == 'announcement') {
      _navigateToAnnouncementPage();
    } else {
      _navigateToAppointmentPage();
    }
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

void _navigateToAnnouncementPage() {
  navigatorKey.currentState?.push(
    MaterialPageRoute(
      builder: (context) => const AnnouncementPage(),
    ),
  );
}

Future<void> _sendNotificationToUser(
    String userId,
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    String status) async {
  final currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser?.uid == userId) {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'appointment_channel',
      'Appointment Notifications',
      channelDescription: 'Notifications related to appointment actions',
      importance: Importance.max,
      priority: Priority.high,
      icon: 'mipmap/ic_notification',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Appointment Update',
      'Your appointment has been $status.',
      platformChannelSpecifics,
    );
  }
}

Future<void> _sendAnnouncementNotification(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    String title,
    String body) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'announcement_channel',
    'Announcement Notifications',
    channelDescription: 'Notifications for new announcements',
    importance: Importance.max,
    priority: Priority.high,
    icon: 'mipmap/ic_notification',
  );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    platformChannelSpecifics,
    payload: 'announcement', // Payload to identify the type of notification
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
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
