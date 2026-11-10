import 'package:flutter/material.dart';
import '../../config/theme/constants/app_sizes.dart';
import '../../config/theme/styles/text_styles.dart';
import '../../common/widgets/text_field/form_field.dart';
import '../../config/theme/colors/app_colors.dart';
import '../../config/theme/constants/text_strings.dart';
import 'personal_info_screen.dart';

class AddressScreen extends StatelessWidget {
  const AddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Define controllers and focus nodes for each field
    final TextEditingController addressController = TextEditingController();
    final TextEditingController cityController = TextEditingController();
    final TextEditingController postcodeController = TextEditingController();

    final FocusNode addressFocusNode = FocusNode();
    final FocusNode cityFocusNode = FocusNode();
    final FocusNode postcodeFocusNode = FocusNode();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: AppSizes.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text( AppTexts.homeAddress, style: TextStyles.header),
            const SizedBox(height: 8),
            const Text(
              AppTexts.accurateInfo,
              style: TextStyles.subtitle,
            ),
            const SizedBox(height: 32),
            CustomTextField(
              label: AppTexts.address,
              hint: AppTexts.addressHint,
              controller: addressController,
              focusNode: addressFocusNode,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: AppTexts.city,
              controller: cityController,
              focusNode: cityFocusNode,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: AppTexts.postCode,
              hint: AppTexts.postCodeHint,
              controller: postcodeController,
              focusNode: postcodeFocusNode,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PersonalInfoScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  AppTexts.tContinue,
                  style: TextStyles.buttonText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
