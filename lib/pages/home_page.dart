import 'package:flutter/material.dart';
import 'package:student_mysiswa/pages/appointment_page.dart';
import 'package:student_mysiswa/pages/booking_page.dart';
import 'package:student_mysiswa/pages/profile_page.dart';
import 'package:student_mysiswa/pages/announcement_page.dart';

class HomePage extends StatefulWidget {
  final int selectedIndex;

  const HomePage({super.key, this.selectedIndex = 0});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  Widget getPage(int index) {
  switch (index) {
    case 0:
      return const AppointmentPage();
    case 1:
      return const BookingPage();
    case 2:
      return ProfilePage();
    case 3:
      return const AnnouncementPage(); // Add Announcement Page case
    default:
      return const AppointmentPage();
  }
}


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: getPage(_selectedIndex),
    bottomNavigationBar: BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Appointment',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: 'Booking',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
        BottomNavigationBarItem( // New Announcement item
          icon: Icon(Icons.announcement),
          label: 'Announcement',
        ),
      ],
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.white,
      backgroundColor: const Color(0xFF435A7F),
    ),
  );
}

}
