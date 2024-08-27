import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/textfieldComponent.dart';

class Changepassword extends StatefulWidget {
  final bool isAdmin;
  const Changepassword({super.key, required this.isAdmin});

  @override
  State<Changepassword> createState() => _ChangepasswordState();
}

class _ChangepasswordState extends State<Changepassword> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          AuthCredential credential = EmailAuthProvider.credential(
            email: user.email!,
            password: _currentPasswordController.text,
          );
          await user.reauthenticateWithCredential(credential);
          await user.updatePassword(_newPasswordController.text);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password changed successfully')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error changing password: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        backgroundColor: Colors.amber,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Textfieldcomponent(
                labelText: 'Current Password',
                controller: _currentPasswordController,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your current password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Textfieldcomponent(
                labelText: 'New Password',
                controller: _newPasswordController,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Textfieldcomponent(
                labelText: 'Confirm Password',
                controller: _confirmPasswordController,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your new password';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _changePassword,
                child: const Text('Change Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
