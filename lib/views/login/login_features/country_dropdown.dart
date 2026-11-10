import 'package:flutter/material.dart';
import '../../../core/utils/constants/uidata.dart';

class CountryDropdown extends StatefulWidget {
  final Function(String code, String flag) onCountryChanged;
  final String initialCode;
  final String initialFlag;

  const CountryDropdown({
    super.key,
    required this.onCountryChanged,
    this.initialCode = '+27',
    this.initialFlag = '🇿🇦',
  });

  @override
  _CountryDropdownState createState() => _CountryDropdownState();
}

class _CountryDropdownState extends State<CountryDropdown> {
  late String selectedCountryCode;
  late String selectedCountryFlag;

  @override
  void initState() {
    super.initState();
    selectedCountryCode = widget.initialCode;
    selectedCountryFlag = widget.initialFlag;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          value: selectedCountryCode,
          items: countries.map((country) {
            return DropdownMenuItem<String>(
              value: country['code'],
              child: Row(
                children: [
                  Text(country['flag']!),
                  const SizedBox(width: 8),
                  Text(country['code']!),
                ],
              ),
            );
          }).toList(),
          onChanged: (String? newCode) {
            if (newCode != null) {
              setState(() {
                selectedCountryCode = newCode;
                selectedCountryFlag = countries.firstWhere(
                  (country) => country['code'] == selectedCountryCode,
                )['flag']!;
              });
              widget.onCountryChanged(selectedCountryCode, selectedCountryFlag);
            }
          },
        ),
      ),
    );
  }
}
