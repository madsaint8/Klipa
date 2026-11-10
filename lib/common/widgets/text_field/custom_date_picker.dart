import 'package:flutter/material.dart';

class CustomDatePicker extends StatelessWidget {
  final String labelText;
  final DateTime? selectedDate;
  final VoidCallback onTap;

  const CustomDatePicker({
    super.key,
    required this.labelText,
    required this.selectedDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextField(
          decoration: InputDecoration(
            labelText: labelText,
            hintText: 'DD/MM/YYYY',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          controller: TextEditingController(
            text: selectedDate?.toLocal().toString().split(' ')[0] ?? '',
          ),
        ),
      ),
    );
  }
}
