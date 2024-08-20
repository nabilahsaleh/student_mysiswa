import 'package:flutter/material.dart';
import 'package:student_mysiswa/pages/appointment_page.dart';
import 'package:student_mysiswa/pages/booking_page.dart';
import 'package:student_mysiswa/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    AppointmentPage(),
    BookingPage(),
  ];

  Widget getPage(int index) {
    switch (index) {
      case 0:
        return const AppointmentPage();
      case 1:
        return const BookingPage();
      case 2:
        return ProfilePage();  // Remove const here
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
      body: getPage(_selectedIndex),  // Dynamically get the page
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Booking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color.fromARGB(255, 247, 108, 108), // Color for the selected item
        unselectedItemColor: const Color(0xFF212325), // Color for unselected items
        backgroundColor: const Color(0xFFFFEAE3),// Background color of the bottom navigation bar
      ),
    );
  }
}
