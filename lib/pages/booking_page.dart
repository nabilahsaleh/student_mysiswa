import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:student_mysiswa/helper/helper_booking.dart';
import 'package:student_mysiswa/pages/home_page.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  _BookingPageState createState() => _BookingPageState();
}

String formatDateTime(DateTime dateTime) {
  final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
  return formatter.format(dateTime);
}

class _BookingPageState extends State<BookingPage> {
  DateTime _selectedDate = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  String _selectedTimeSlot = '';

  List<String> timeSlots = [
    '8:30 - 9:30',
    '9:30 - 10:30',
    '10:30 - 11:30',
    '11:30 - 12:30',
    '2:30 - 3:30',
    '3:30 - 4:30',
  ];

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  void _initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('mipmap/ic_notification');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
        if (notificationResponse.payload != null) {
          if (notificationResponse.payload == 'navigate_to_appointment') {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const HomePage(selectedIndex: 0)),
            );
          }
        }
      },
    );
  }

  void _bookSlot() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in.')),
      );
      return;
    }

    if (_selectedTimeSlot.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time slot.')),
      );
      return;
    }

    final booking = Booking(
      userId: currentUser.uid,
      date: _selectedDate,
      timeSlot: _selectedTimeSlot,
    );

    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .add(booking.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Booking confirmed for $_selectedDate at $_selectedTimeSlot'),
        ),
      );

      _showBookingNotification(_selectedDate, _selectedTimeSlot);

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const HomePage(selectedIndex: 0)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to book slot: $e')),
      );
    }
  }

  void _showBookingNotification(DateTime date, String timeSlot) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'appointment_channel', // Same channel ID
      'Appointment Notifications',
      channelDescription: 'Notifications related to appointment bookings',
      importance: Importance.max,
      priority: Priority.high,
      icon: 'mipmap/ic_notification',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Booking Confirmed',
      'Your booking for $date at $timeSlot is confirmed.',
      platformChannelSpecifics,
      payload: 'navigate_to_appointment',
    );
  }

  bool _isWeekend(DateTime date) {
    return date.weekday == 6 || date.weekday == 7;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9BBFDD),
      appBar: AppBar(
        title: const Center(child: Text('B O O K I N G')),
        backgroundColor: const Color(0xFF9BBFDD),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(25.0),
          color: const Color(0xFF9BBFDD),
          child: Column(
            children: [
              Container(
                color: Colors.white,
                child: TableCalendar(
                  firstDay: DateTime(2000),
                  lastDay: DateTime(2101),
                  focusedDay: _selectedDate,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDate, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDate = selectedDay;
                      _calendarFormat = CalendarFormat.month;
                    });
                  },
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    }
                  },
                  onPageChanged: (focusedDay) {
                    _selectedDate = focusedDay;
                  },
                  enabledDayPredicate: (day) {
                    return day.isAfter(
                            DateTime.now().subtract(const Duration(days: 1))) &&
                        !_isWeekend(day);
                  },
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    todayTextStyle: const TextStyle(color: Colors.white),
                    todayDecoration: const BoxDecoration(
                      color: Color(0xFFFFCBCB),
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: const TextStyle(color: Colors.white),
                    selectedDecoration: const BoxDecoration(
                      color: Color.fromARGB(255, 247, 108, 108),
                      shape: BoxShape.circle,
                    ),
                    weekendTextStyle: TextStyle(color: Colors.red[800]),
                    defaultTextStyle: const TextStyle(color: Colors.black),
                    holidayTextStyle: const TextStyle(color: Colors.green),
                    weekendDecoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    defaultDecoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekendStyle: TextStyle(color: Color(0xFF121481)),
                    weekdayStyle: TextStyle(color: Colors.black),
                  ),
                  headerStyle: HeaderStyle(
                    titleTextStyle: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    formatButtonTextStyle: const TextStyle(color: Colors.white),
                    formatButtonDecoration: BoxDecoration(
                      color: const Color(0xFF121481),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    leftChevronIcon: const Icon(
                      Icons.chevron_left,
                      color: Colors.black,
                    ),
                    rightChevronIcon: const Icon(
                      Icons.chevron_right,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text('Time slots',
                  style:
                      TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 3,
                ),
                itemCount: timeSlots.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTimeSlot = timeSlots[index];
                      });
                    },
                    child: Card(
                      color: _selectedTimeSlot == timeSlots[index]
                          ? const Color(0xFF121481)
                          : Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          timeSlots[index],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _selectedTimeSlot == timeSlots[index]
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _bookSlot,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  backgroundColor: const Color.fromARGB(255, 247, 108, 108),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'BOOK',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
