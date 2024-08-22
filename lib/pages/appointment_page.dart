import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_mysiswa/helper/helper_booking.dart';

class AppointmentPage extends StatelessWidget {
  const AppointmentPage({super.key});

  Future<List<Map<String, dynamic>>> _getUserBookings() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('User not logged in.');
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('bookings')
        .where('userId', isEqualTo: currentUser.uid)
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data(),
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('A P P O I N T M E N T S')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _getUserBookings(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No appointments found.'));
            }

            final upcomingAppointments = snapshot.data!.where((booking) => booking['status'] == 'scheduled').toList();
            final pastAppointments = snapshot.data!.where((booking) => booking['status'] == 'canceled' || booking['status'] == 'completed').toList();

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Upcoming Appointments',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (upcomingAppointments.isEmpty)
                    const Text('No upcoming appointments.'),
                  for (var appointment in upcomingAppointments)
                    _buildAppointmentCard(
                      context: context,
                      date: (appointment['date'] as Timestamp).toDate(),
                      time: appointment['timeSlot'],
                      status: appointment['status'],
                      isUpcoming: true,
                      appointmentId: appointment['id'],
                    ),
                  const SizedBox(height: 40),
                  const Text(
                    'Past Appointments',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (pastAppointments.isEmpty)
                    const Text('No past appointments.'),
                  for (var appointment in pastAppointments)
                    _buildAppointmentCard(
                      context: context,
                      date: (appointment['date'] as Timestamp).toDate(),
                      time: appointment['timeSlot'],
                      status: appointment['status'],
                      isUpcoming: false,
                      appointmentId: appointment['id'],
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppointmentCard({
    required BuildContext context,
    required DateTime date,
    required String time,
    required String status,
    required bool isUpcoming,
    required String appointmentId,
  }) {
    final formattedDate = "${date.day} ${_monthName(date.month)} ${date.year}";

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date: $formattedDate',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(
              'Time: $time',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 5),
            const Text(
              'Location: Banggunan Sarjana, Bilik Peralatan Komputer',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(
              'Status: $status',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            if (isUpcoming)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _showConfirmationDialog(
                        context: context,
                        title: 'Cancel Appointment',
                        content: 'Are you sure you want to cancel this appointment?',
                        onConfirm: () {
                          _cancelAppointment(context, appointmentId);
                        },
                      );
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      _showConfirmationDialog(
                        context: context,
                        title: 'Check-In',
                        content: 'Are you sure you want to check in for this appointment?',
                        onConfirm: () {
                          _checkInAppointment(context, appointmentId);
                        },
                      );
                    },
                    child: const Text('Check-In'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _monthName(int month) {
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return monthNames[month - 1];
  }

  // Function to show confirmation dialog
  Future<void> _showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            ElevatedButton(
              child: const Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                onConfirm(); // Execute the confirmed action
              },
            ),
          ],
        );
      },
    );
  }

  // Function to cancel an appointment
  void _cancelAppointment(BuildContext context, String appointmentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(appointmentId)
          .update({'status': 'canceled'});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment canceled.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to cancel appointment: $e')),
      );
    }
  }

  // Function to check-in for an appointment
  void _checkInAppointment(BuildContext context, String appointmentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(appointmentId)
          .update({'status': 'in-progress'});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checked in successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to check in: $e')),
      );
    }
  }
}
