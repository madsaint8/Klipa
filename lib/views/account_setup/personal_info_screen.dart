import 'package:flutter/material.dart';
import 'package:paywave/views/account_setup/country_screen.dart';
import '../../config/theme/styles/text_styles.dart';
import '../../common/widgets/buttons/custom_button.dart';
import '../../common/widgets/text_field/custom_date_picker.dart';
import '../../common/widgets/text_field/custom_text_field.dart';
import '../../config/theme/constants/app_sizes.dart';
import '../../config/theme/constants/text_strings.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  DateTime? selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: AppSizes.defaultPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppTexts.personalInfo,
              style: TextStyles.title,
            ),
            const SizedBox(height: 8),
            const Text(
              AppTexts.accurateInfo,
              style: TextStyles.description,
            ),
            const SizedBox(height: 32),
            const CustomTextField(
              labelText: AppTexts.fullName,
              hintText: AppTexts.fullNameHint,
            ),
            const SizedBox(height: 16),
            const CustomTextField(
              labelText: AppTexts.username,
              hintText: AppTexts.usernameHint,
            ),
            const SizedBox(height: 16),
            CustomDatePicker(
              labelText: AppTexts.dob,
              selectedDate: selectedDate,
              onTap: () => _selectDate(context),
            ),
            const Spacer(),
            CustomButton(
              text: AppTexts.tContinue,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CountryScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
