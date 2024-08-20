import 'package:flutter/material.dart';

class AppointmentPage extends StatelessWidget {
  const AppointmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('A P P O I N T M E N T S')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upcoming Appointments',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildAppointmentCard(
              date: '12 Aug 2024',
              time: '10:00 AM',
              location: 'Room 101',
              isUpcoming: true,
            ),
            const SizedBox(height: 40),
            const Text(
              'Past Appointments',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildAppointmentCard(
              date: '10 Aug 2024',
              time: '02:00 PM',
              location: 'Room 202',
              isUpcoming: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard({
    required String date,
    required String time,
    required String location,
    required bool isUpcoming,
  }) {
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
              'Date: $date',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(
              'Time: $time',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(
              'Location: $location',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: isUpcoming
                  ? [
                      TextButton(
                        onPressed: () {
                          // Handle cancel appointment
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          // Handle check-in
                        },
                        child: const Text('Check-In'),
                      ),
                    ]
                  : [],
            ),
          ],
        ),
      ),
    );
  }
}