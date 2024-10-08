import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _idController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (currentUser == null) return;
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      final data = userDoc.data();
      if (data != null) {
        setState(() {
          _nameController.text = data['name'] ?? '';
          _phoneController.text = data['phone_number'] ?? '';
          _idController.text = data['id'] ?? '';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load user data: $e')),
      );
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      if (currentUser == null) return;

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .update({
          'name': _nameController.text,
          'phone_number': _phoneController.text,
          'id': _idController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')),
        );

        Navigator.pop(
            context, true); // Pass `true` to indicate changes were made
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9BBFDD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF9BBFDD),
        title: const Text(
          'E D I T  P R O F I L E',
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField('Name', _nameController),
              const SizedBox(height: 35),
              _buildTextField('Phone', _phoneController),
              const SizedBox(height: 35),
              _buildTextField('Student ID', _idController),
              const SizedBox(height: 60),
              Center(
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color.fromARGB(255, 247, 108, 108), // Pink color
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 40.0), // Uniform padding for size consistency
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          10), // Consistent rounded corners
                    ),
                  ),
                  child: const Text(
                    'SAVE CHANGES',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18), // Consistent text style
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF546E7A),
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          style: const TextStyle(
            fontSize: 18,
            color: Color(0xFF37474F),
          ),
          decoration: const InputDecoration(
            contentPadding:
                EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            border: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Colors.white), // Default border color
            ),
            enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Colors.white), // White border when enabled
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Color(0xFF435A7F), width: 3.0), // White border when focused
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Colors.red, width: 3.0), // Red border on error
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Colors.red, width: 3.0), // Red border on focused error
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your $label';
            }
            return null;
          },
        ),
      ],
    );
  }
}
