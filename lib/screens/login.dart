import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/textfieldComponent.dart';
import 'dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Debug log to ensure login attempt is happening
        print('Attempting login');

        // Attempt to sign in with email and password
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Fetch user role from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        int role = userDoc.get('role') as int;

        // Debug log for successful login
        print('Login successful');

        // Navigate based on role
        if (role == 2) {
          // Admin
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (context) => const Dashboard(isAdmin: true)),
          );
        } else {
          // Regular user
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (context) => const Dashboard(isAdmin: false)),
          );
        }
      } on FirebaseAuthException catch (e) {
        // Debug log for Firebase authentication errors
        print('Login error: ${e.message}');

        // Show error message in a SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.amber,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Email field
              Textfieldcomponent(
                labelText: 'Email',
                controller: _emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password field
              Textfieldcomponent(
                labelText: 'Password',
                controller: _passwordController,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Login button
              ElevatedButton(
                onPressed: _login,
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
