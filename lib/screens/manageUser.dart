import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/drawer.dart';
import '../components/textfieldComponent.dart';

class Manageuser extends StatefulWidget {
  final bool isAdmin;
  const Manageuser({Key? key, required this.isAdmin}) : super(key: key);
  @override
  State<Manageuser> createState() => _ManageuserState();
}

class _ManageuserState extends State<Manageuser> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _addUser(int role) async {
    if (_formKey.currentState!.validate()) {
      try {
        // Create user in Firebase Authentication
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // If successful, add user details to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'role': role,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User added successfully')),
        );
        _clearForm();
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'An error occurred';
        if (e.code == 'weak-password') {
          errorMessage = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          errorMessage = 'The account already exists for that email.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding user: $e')),
        );
      }
    }
  }

  void _clearForm() {
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage User'),
        backgroundColor: Colors.amber,
      ),
      drawer: CustomDrawer(isAdmin: widget.isAdmin),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              return ListTile(
                title: Text(data['name'] ?? 'No Name'),
                subtitle: Text(
                    '${data['email'] ?? 'No Email'} - Role: ${data['role'] == 2 ? 'Admin' : 'User'}'),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              int selectedRole = 1; // Default role (user)
              return AlertDialog(
                title: const Text('Add user'),
                content: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Textfieldcomponent(
                          labelText: 'Full name',
                          controller: _nameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Textfieldcomponent(
                          labelText: 'Your Email',
                          controller: _emailController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Textfieldcomponent(
                          labelText: 'Phone Number',
                          controller: _phoneController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Textfieldcomponent(
                          labelText: 'Password',
                          controller: _passwordController,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          value: selectedRole,
                          decoration: const InputDecoration(
                            labelText: 'Role',
                          ),
                          items: const [
                            DropdownMenuItem(value: 1, child: Text('User')),
                            DropdownMenuItem(value: 2, child: Text('Admin')),
                          ],
                          onChanged: (int? newValue) {
                            if (newValue != null) {
                              selectedRole = newValue;
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _addUser(selectedRole);
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Add'),
                  ),
                ],
              );
            },
          );
        },
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add),
      ),
    );
  }
}
