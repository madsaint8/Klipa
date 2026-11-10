import 'package:flutter/material.dart';

class PasswordTextField extends StatefulWidget {
  final String hintText;
  final bool isVisible;
  final VoidCallback toggleVisibility;
  final TextEditingController controller;

  const PasswordTextField({
    super.key,
    required this.hintText,
    required this.isVisible,
    required this.toggleVisibility,
    required this.controller,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: !widget.isVisible,
      autocorrect: false,
      enableSuggestions: false,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.key),
        suffixIcon: IconButton(
          icon: Icon(widget.isVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: widget.toggleVisibility,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
      ),
    );
  }
}