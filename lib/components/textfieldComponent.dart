import 'package:flutter/material.dart';

class Textfieldcomponent extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final bool obscureText;
  final String? Function(String?)? validator;

  const Textfieldcomponent({
    super.key,
    required this.labelText,
    required this.controller,
    this.obscureText = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
      obscureText: obscureText,
      validator: validator,
    );
  }
}
