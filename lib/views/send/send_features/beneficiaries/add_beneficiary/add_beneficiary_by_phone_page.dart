import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../config/theme/app_theme.dart';
import '../../../../../providers/beneficiaries/beneficiaries_provider.dart';


class AddBeneficiaryByPhonePage extends ConsumerStatefulWidget {
  const AddBeneficiaryByPhonePage({super.key});

  @override
  ConsumerState<AddBeneficiaryByPhonePage> createState() =>
      _AddBeneficiaryByPhonePageState();
}

class _AddBeneficiaryByPhonePageState
    extends ConsumerState<AddBeneficiaryByPhonePage> {
  final _phoneController = TextEditingController();
  final _nicknameController = TextEditingController();
  bool _isSubmitting = false;
  String? _submitError;

  @override
  void dispose() {
    _phoneController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _onConfirm(Map<String, dynamic> user) async {
    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    try {
      await ref.read(beneficiariesProvider.notifier).add(
            contactUserId: user['id'] as String,
            name: user['full_name'] as String,
            phone: user['phone'] as String,
            nickname: _nicknameController.text.trim().isEmpty
                ? null
                : _nicknameController.text.trim(),
          );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${user['full_name']} added as beneficiary'),
            backgroundColor: PayWaveTheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _submitError = _friendlyError(e.toString());
        _isSubmitting = false;
      });
    }
  }

  String _friendlyError(String raw) {
    if (raw.contains('23505')) return 'This person is already a beneficiary.';
    if (raw.contains('23514')) return 'You cannot add yourself.';
    return 'Something went wrong. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final lookupState = ref.watch(phoneLookupProvider);
    final isFound = lookupState.status == PhoneLookupStatus.found;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        title: const Text('Add by Phone',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: PayWaveTheme.primary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Instruction card ───────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: PayWaveTheme.primary.withOpacity(0.07),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline,
                    color: PayWaveTheme.primary, size: 20),
                SizedBox(width: 10),
                 Expanded(
                  child: Text(
                    'Enter the cellphone number of a Klipa user to add them as a beneficiary.',
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Phone input ────────────────────────────────────────────
          _SectionLabel(label: 'Cellphone number'),
          const SizedBox(height: 8),
          _PhoneField(
            controller: _phoneController,
            onChanged: (val) {
              final digits = val.replaceAll(RegExp(r'\D'), '');
              if (digits.length >= 9) {
                ref.read(phoneLookupProvider.notifier).lookup(digits);
              } else {
                ref.read(phoneLookupProvider.notifier).reset();
              }
            },
          ),
          const SizedBox(height: 8),

          // ── Lookup status ──────────────────────────────────────────
          _LookupStatusBanner(status: lookupState.status),
          const SizedBox(height: 20),

          // ── Found user card ────────────────────────────────────────
          if (isFound) ...[
            _FoundUserCard(user: lookupState.user!),
            const SizedBox(height: 20),

            // ── Optional nickname ────────────────────────────────────
            _SectionLabel(label: 'Nickname (optional)'),
            const SizedBox(height: 8),
            _NicknameField(controller: _nicknameController),
            const SizedBox(height: 32),

            // ── Error ────────────────────────────────────────────────
            if (_submitError != null) ...[
              Text(
                _submitError!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
            ],

            // ── Confirm button ───────────────────────────────────────
            _ConfirmButton(
              isLoading: _isSubmitting,
              onTap: () => _onConfirm(lookupState.user!),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black54),
      );
}

class _PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _PhoneField(
      {required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: TextInputType.phone,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        maxLength: 10,
        decoration: InputDecoration(
          counterText: '',
          hintText: '063 053 6013',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(Icons.phone_iphone,
              color: PayWaveTheme.primary, size: 22),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

class _LookupStatusBanner extends StatelessWidget {
  final PhoneLookupStatus status;
  const _LookupStatusBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: switch (status) {
        PhoneLookupStatus.loading => const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  height: 14,
                  width: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text('Looking up number...',
                    style: TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
        PhoneLookupStatus.notFound => Row(
            children: [
              const Icon(Icons.cancel_outlined,
                  color: Colors.red, size: 16),
              const SizedBox(width: 6),
              Text('No Klipa account found for this number.',
                  style: TextStyle(color: Colors.red[400], fontSize: 13)),
            ],
          ),
        PhoneLookupStatus.error => const Row(
            children: [
              Icon(Icons.warning_amber_outlined,
                  color: Colors.orange, size: 16),
              SizedBox(width: 6),
              Text('Lookup failed. Check connection.',
                  style: TextStyle(color: Colors.orange, fontSize: 13)),
            ],
          ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

class _FoundUserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  const _FoundUserCard({required this.user});

  String get _initials {
    final name = user['full_name'] as String? ?? '';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Verified badge
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified, color: Colors.green, size: 14),
                  SizedBox(width: 4),
                  Text('Klipa User',
                      style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          CircleAvatar(
            radius: 36,
            backgroundColor: PayWaveTheme.primary,
            child: Text(_initials,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 12),
          Text(
            user['full_name'] as String? ?? 'Unknown',
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF003366)),
          ),
          const SizedBox(height: 4),
          // Account number row
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('account',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                Row(
                  children: [
                    Text(
                      user['phone'] as String? ?? '',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 18),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NicknameField extends StatelessWidget {
  final TextEditingController controller;
  const _NicknameField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          hintText: 'e.g. Mom, Work, Landlord',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(Icons.label_outline,
              color: PayWaveTheme.primary, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _ConfirmButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: PayWaveTheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
        child: isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white),
              )
            : const Text('Confirm & Add Beneficiary',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700)),
      ),
    );
  }
}