import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_mysiswa/pages/edit_profile.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    if (currentUser == null) {
      throw Exception('No user is currently logged in.');
    }
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .get();
  }

  void logout() {
    FirebaseAuth.instance.signOut();
  }

  void navigateToEditProfile(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfilePage()),
    );

    // If the result is true, refresh the profile page
    if (result == true) {
      setState(() {
        // Trigger a refresh by rebuilding the FutureBuilder
      });
    }
  }

  void showProfilePictureDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Profile Picture'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  updateProfilePicture('assets/male.png');
                },
                child: Image.asset(
                  'assets/male.png',
                  width: 80,
                  height: 80,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  updateProfilePicture('assets/female.png');
                },
                child: Image.asset(
                  'assets/female.png',
                  width: 80,
                  height: 80,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void updateProfilePicture(String imagePath) async {
    if (currentUser != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .update({'profile_picture': imagePath});

      // Refresh the page after updating the profile picture
      setState(() {
        // Trigger a rebuild to reflect the new profile picture
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFEAE3),
      appBar: AppBar(
        title:
            const Text('P R O F I L E', style: TextStyle(color: Colors.black)),
        backgroundColor: const Color(0xFFFFEAE3),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
            color: Colors.black,
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: getUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            Map<String, dynamic>? data = snapshot.data?.data();
            if (data == null) {
              return const Center(child: Text('No data found'));
            }

            return Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => showProfilePictureDialog(context),
                    child: CircleAvatar(
                      radius: 55,
                      backgroundImage: data['profile_picture'] != null
                          ? AssetImage(data['profile_picture'])
                          : const AssetImage('assets/profile_placeholder.png'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  buildUserInfoRow('NAME', data['name']),
                  const SizedBox(height: 15),
                  buildUserInfoRow('EMAIL', data['email']),
                  const SizedBox(height: 15),
                  buildUserInfoRow('STUDENT ID', data['id']),
                  const SizedBox(height: 15),
                  buildUserInfoRow('PHONE', data['phone_number']),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(35.0),
        child: ElevatedButton(
          onPressed: () => navigateToEditProfile(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF121481),
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 30.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Edit Profile',
              style: TextStyle(color: Colors.white, fontSize: 18)),
        ),
      ),
    );
  }

  Widget buildUserInfoRow(String title, String? value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: const BoxDecoration(
        border: Border(
          bottom:
              BorderSide(color: Color.fromARGB(255, 211, 201, 201), width: 1.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Color(0xFF37474F),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
