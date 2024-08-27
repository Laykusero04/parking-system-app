import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/drawer.dart';

class Profilescreen extends StatefulWidget {
  final bool isAdmin;
  const Profilescreen({Key? key, required this.isAdmin}) : super(key: key);

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen> {
  String _name = '';
  String _email = '';
  String _phone = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userData.exists) {
        setState(() {
          _name = userData['name'] ?? 'Not Available';
          _email = userData['email'] ?? 'Not Available';
          _phone = userData['phone'] ?? 'Not Available';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.amber,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(
                '/editProfile',
                arguments: widget.isAdmin,
              );
            },
            child: const Text('Edit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      drawer: CustomDrawer(isAdmin: widget.isAdmin),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.amber,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 24),
            _buildProfileInfoSection('Name', _name),
            const SizedBox(height: 16),
            _buildProfileInfoSection('Email', _email),
            const SizedBox(height: 16),
            _buildProfileInfoSection('Phone Number', _phone),
            const SizedBox(
              height: 15,
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).pushNamed(
                  '/changePassword',
                  arguments: widget.isAdmin,
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Icon(Icons.lock_outline, color: Colors.amber),
                    SizedBox(width: 8),
                    Text(
                      "Change Password",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to build the profile info section with label and value
  Widget _buildProfileInfoSection(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16.0,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity, // Ensures full width container
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 18.0,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
