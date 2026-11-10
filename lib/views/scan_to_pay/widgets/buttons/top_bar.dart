import 'package:flutter/material.dart';
import '../../../../config/theme/styles/app_text_styles.dart';
import 'glass_Icon_button.dart';


class TopBar extends StatelessWidget {
  final VoidCallback onClose;

  const TopBar({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          GlassIconButton(onTap: onClose, icon: Icons.close_rounded),
          const Spacer(),
          const Text('Scan to Pay', style: AppTextStyles.screenTitle),
          const Spacer(),
          // Balances the close button so the title stays centred.
          const SizedBox(width: 44),
        ],
      ),
    );
  }
}