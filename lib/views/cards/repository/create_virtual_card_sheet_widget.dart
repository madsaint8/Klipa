import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../config/theme/constants/text_strings.dart';
import '../../portfolio/app_colors.dart';
import '../formatters/card_formatters.dart';
import '../formatters/card_limits.dart';
import '../card_validators.dart';
import '../providers/cards_provider.dart';
import '../widgets/glass_action_button_widget.dart';
import '../widgets/glass_container_widget.dart';

Future<void> showCreateVirtualCardSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const CreateVirtualCardSheet(),
  );
}

/// Glass bottom sheet with a validated form. The sheet can't be dismissed
/// while the request is running, and the submit button disables itself, so a
/// card can never be created twice.
class CreateVirtualCardSheet extends ConsumerStatefulWidget {
  const CreateVirtualCardSheet({super.key});

  @override
  ConsumerState<CreateVirtualCardSheet> createState() =>
      _CreateVirtualCardSheetState();
}

class _CreateVirtualCardSheetState
    extends ConsumerState<CreateVirtualCardSheet> {
  static const _presets = <double>[1000, 5000, 10000, 25000];

  final _formKey = GlobalKey<FormState>();
  final _labelCtrl = TextEditingController();
  final _limitCtrl = TextEditingController(text: '5000');
  bool _submitting = false;

  @override
  void dispose() {
    _labelCtrl.dispose();
    _limitCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting || !(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);

    final ok = await ref.read(cardsProvider.notifier).createVirtualCard(
          label: _labelCtrl.text,
          spendingLimit: CardValidators.parseLimit(_limitCtrl.text)!,
        );

    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) Navigator.of(context).pop();
  }

  InputDecoration _decoration(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.65),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.skyDeep, width: 1.5),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_submitting,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: GlassContainer(
          opacity: 0.7,
          blur: 24,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.textMuted.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(AppTexts.createVirtualTitle,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _labelCtrl,
                    enabled: !_submitting,
                    maxLength: CardLimits.maxLabelLength,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: _decoration(AppTexts.cardLabelHint),
                    validator: CardValidators.label,
                  ),
                  const SizedBox(height: 8),
                  const Text(AppTexts.spendingLimit,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _limitCtrl,
                    enabled: !_submitting,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      LengthLimitingTextInputFormatter(9),
                    ],
                    decoration: _decoration('5000').copyWith(prefixText: 'R '),
                    validator: CardValidators.limit,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final p in _presets)
                        ActionChip(
                          label: Text(CardFormatters.amount(p)),
                          onPressed: _submitting
                              ? null
                              : () => setState(
                                  () => _limitCtrl.text = p.round().toString()),
                          backgroundColor: AppColors.skyLight,
                          side: BorderSide.none,
                          labelStyle: const TextStyle(
                              color: AppColors.skyDeep,
                              fontWeight: FontWeight.w600),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  GlassActionButton(
                    icon: Iconsax.add,
                    label: AppTexts.createCard,
                    loading: _submitting,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}