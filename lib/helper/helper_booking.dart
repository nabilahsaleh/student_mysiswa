import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String userId;
  final DateTime date;
  final String timeSlot;
  final String status; // e.g., 'confirmed', 'pending', 'canceled'

  Booking({
    required this.userId,
    required this.date,
    required this.timeSlot,
    this.status = 'scheduled',
  });

  // Convert a Booking object into a Map object for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'timeSlot': timeSlot,
      'status': status,
    };
  }

  // Create a Booking object from a Map object
  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      userId: map['userId'],
      date: (map['date'] as Timestamp).toDate(),
      timeSlot: map['timeSlot'],
      status: map['status'] ?? 'scheduled',
    );
  }
}
