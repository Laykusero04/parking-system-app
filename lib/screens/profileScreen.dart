import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/appTheme.dart';
import '../components/drawer.dart';

class Profilescreen extends StatefulWidget {
  final bool isAdmin;
  const Profilescreen({Key? key, required this.isAdmin}) : super(key: key);

  @override
  State<Profilescreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<Profilescreen> {
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
    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context).pushReplacementNamed(
                  '/editProfile',
                  arguments: widget.isAdmin,
                );
              },
            ),
          ],
        ),
        drawer: CustomDrawer(isAdmin: widget.isAdmin),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              _buildProfileInfo(),
              _buildChangePasswordButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 200,
      color: AppTheme.primaryColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 50, color: AppTheme.primaryColor),
            ),
            SizedBox(height: 10),
            Text(
              _name,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoTile(Icons.email, 'Email', _email),
            Divider(height: 20),
            _buildInfoTile(Icons.phone, 'Phone', _phone),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title:
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
      subtitle:
          Text(value, style: TextStyle(color: Colors.black, fontSize: 18)),
    );
  }

  Widget _buildChangePasswordButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      child: ElevatedButton.icon(
        icon: Icon(Icons.lock_outline),
        label: Text("Change Password"),
        onPressed: () {
          Navigator.of(context).pushNamed(
            '/changePassword',
            arguments: widget.isAdmin,
          );
        },
      ),
    );
  }
}
