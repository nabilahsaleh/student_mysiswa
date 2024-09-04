import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class AnnouncementPage extends StatelessWidget {
  const AnnouncementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9BBFDD),
      appBar: AppBar(
        title: const Center(child: Text('A N N O U N C E M E N T ')),
        backgroundColor: const Color(0xFF9BBFDD),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Listening to the 'announcements' collection in Firestore
        stream: FirebaseFirestore.instance.collection('announcements').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong. Please try again.'));
          }

          // Check if there are any announcements
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No announcements available.'));
          }

          // Fetch the list of announcements
          final List<DocumentSnapshot> documents = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(25.0),
            itemCount: documents.length,
            itemBuilder: (context, index) {
              // Fetch title and message from the document
              String title = documents[index]['title'] ?? 'No Title';
              String message = documents[index]['message'] ?? 'No Message';
              Timestamp timestamp = documents[index]['timestamp'] ?? Timestamp.now();
              DateTime date = timestamp.toDate();

              return Card(
                color: const Color(0xFFC7DCED),
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16.0),
                  title: Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        message,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Posted on: ${date.toLocal()}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
