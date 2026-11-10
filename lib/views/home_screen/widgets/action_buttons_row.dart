import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../config/theme/constants/text_strings.dart';
import '../../../../common/widgets/buttons/action_button.dart';
import '../../deposit/deposite_screen.dart';
import '../../send/send_screen.dart';

class ActionButtonsRow extends StatelessWidget {
  const ActionButtonsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        buildActionButton(
          AppTexts.send,
          Iconsax.send_2,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BeneficiaryScreen(),
              ),
            );
          },
        ),
        buildActionButton(
          AppTexts.deposit,
          Iconsax.receive_square,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TopUpScreen(),
              ),
            );
          },
        ),
      ],
    );
  }
}