import 'package:flutter/material.dart';

import '../../../core/utils/constants/uidata.dart';

class CountryDropdown extends StatelessWidget {
  final String? selectedCountry;
  final ValueChanged<String?> onChanged;

  const CountryDropdown({
    super.key,
    required this.selectedCountry,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Country',
        hintText: 'Select your country',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      initialValue: selectedCountry,
      onChanged: onChanged,
      items: countries.map((country) {
        return DropdownMenuItem<String>(
          value: country['name'],
          child: Row(
            children: [
              Text(country['flag'] ?? ''),
              const SizedBox(width: 8),
              Text(country['name'] ?? ''),
            ],
          ),
        );
      }).toList(),
    );
  }
}
