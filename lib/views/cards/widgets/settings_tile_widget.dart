import 'package:flutter/material.dart';
import '../../portfolio/app_colors.dart';

/// Purely presentational row. Give it `switchValue` + `onSwitchChanged` for a
/// toggle, or `onTap` for a navigation row. It owns no state.
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    this.switchValue,
    this.onSwitchChanged,
    this.onTap,
    this.isDestructive = false,
  });

  final String title;
  final String? subtitle;
  final bool? switchValue;
  final ValueChanged<bool>? onSwitchChanged;
  final VoidCallback? onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final isSwitch = switchValue != null;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDestructive ? AppColors.negative : AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!,
              style:
                  const TextStyle(fontSize: 12, color: AppColors.textMuted)),
      trailing: isSwitch
          ? Switch(
              value: switchValue!,
              onChanged: onSwitchChanged,
              thumbColor: const WidgetStatePropertyAll(Colors.white),
              trackColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? AppColors.skyDeep
                    : AppColors.sky.withValues(alpha: 0.35),
              ),
              trackOutlineColor:
                  const WidgetStatePropertyAll(Colors.transparent),
            )
          : Icon(Icons.arrow_forward_ios_rounded,
              size: 16,
              color: isDestructive ? AppColors.negative : AppColors.textMuted),
      onTap: isSwitch
          ? (onSwitchChanged == null
              ? null
              : () => onSwitchChanged!(!switchValue!))
          : onTap,
    );
  }
}