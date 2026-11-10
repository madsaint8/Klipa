import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paywave/services/wallet/wallet_services.dart';
import 'package:paywave/services/wallet/wallet_vault.dart';
import '../../providers/wallet_provider.dart';

// ───────────────────────── Palette ─────────────────────────

const _sky = Color(0xFF38BDF8);
const _skyDeep = Color(0xFF0284C7);
const _skyPale = Color(0xFFE0F2FE);
const _ink = Color(0xFF0C4A6E);
const _muted = Color(0xFF64748B);
const _ok = Color(0xFF059669);
const _warn = Color(0xFFF59E0B);
const _bad = Color(0xFFEF4444);

/// 0x1234abcd…ef1234
String _short(String a) =>
    a.length > 14 ? '${a.substring(0, 8)}…${a.substring(a.length - 6)}' : a;

class SendScreen extends ConsumerStatefulWidget {
  const SendScreen({super.key});

  @override
  ConsumerState<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends ConsumerState<SendScreen> {
  /// Keep in sync with SignupController.minPinLength.
  static const _minPinLength = 8;

  final _toController = TextEditingController();
  final _amountController = TextEditingController();

  FeeEstimate? _fee;
  bool _feeLoading = false;
  String? _feeError;
  bool _feeExpanded = false;
  Timer? _debounce;

  bool _sending = false;
  bool _confirming = false;
  bool _busy = false; // unlocking / backing up
  String? _status;
  bool _statusIsError = false;
  String? _txHash;

  @override
  void initState() {
    super.initState();
    _toController.addListener(() {
      setState(() {});
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), _loadFee);
    });
    _amountController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadFee());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _toController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // ------------------------------- Helpers ----------------------------------

  double? get _amountValue =>
      double.tryParse(_amountController.text.trim().replaceAll(',', '.'));

  void _setStatus(String message, {bool error = false}) {
    if (!mounted) return;
    setState(() {
      _status = message;
      _statusIsError = error;
    });
  }

  String _friendlyError(Object e) {
    if (e is WalletException) return e.message;
    if (e is VaultException) return e.message;
    if (e is FormatException) return e.message;
    if (e is TimeoutException) return 'Network timed out. Please try again.';
    final m = e.toString().toLowerCase();
    if (m.contains('insufficient funds')) {
      return 'Insufficient funds to cover amount + network fee.';
    }
    if (m.contains('underpriced')) return 'Network fee too low. Try again.';
    if (m.contains('nonce')) return 'A previous transaction is still pending.';
    return 'Transaction failed. Please try again.';
  }

  // -------------------------------- Actions ---------------------------------

  Future<void> _paste() async {
    final data = await Clipboard.getData('text/plain');
    final text = data?.text?.trim();
    if (text != null && text.isNotEmpty) _toController.text = text;
  }

  Future<void> _loadFee() async {
    if (!mounted) return;
    final service = ref.read(walletServiceProvider);
    final to = _toController.text.trim();

    setState(() {
      _feeLoading = true;
      _feeError = null;
    });

    try {
      final fee = await service.estimateFee(
        to: service.isValidAddress(to) ? to : null,
      );
      if (!mounted) return;
      setState(() {
        _fee = fee;
        _feeLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _feeLoading = false;
        _feeError = 'Could not load network fee.';
      });
    }
  }

  Future<void> _max() async {
    final service = ref.read(walletServiceProvider);
    final to = _toController.text.trim();
    try {
      final max = await service.maxSendableEth(
        to: service.isValidAddress(to) ? to : null,
      );
      _amountController.text = max;
    } catch (e) {
      _setStatus(_friendlyError(e), error: true);
    }
  }

  /// New device / cleared storage: decrypt the cloud backup with the PIN.
  Future<void> _unlock() async {
    final pin = await showDialog<String>(
      context: context,
      builder: (_) => const _PinDialog(
        title: 'Unlock wallet',
        message: 'Enter your wallet PIN to enable sending on this device.',
        actionLabel: 'Unlock',
        minLength: 1,
      ),
    );
    if (pin == null || !mounted) return;

    setState(() => _busy = true);
    try {
      await ref.read(walletProvider.notifier).unlockWithPin(pin);
      _setStatus('Wallet unlocked. You can send now.');
      _loadFee();
    } catch (e) {
      _setStatus(_friendlyError(e), error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Device has the key but no cloud backup yet.
  Future<void> _setupBackup() async {
    final pin = await showDialog<String>(
      context: context,
      builder: (_) => const _PinDialog(
        title: 'Back up your wallet',
        message:
            'Choose a wallet PIN. Your key is encrypted with it before upload, '
            'so only you can restore it on a new device. If you forget the PIN, '
            'your funds cannot be recovered.',
        actionLabel: 'Save backup',
        confirm: true,
        minLength: _minPinLength,
      ),
    );
    if (pin == null || !mounted) return;

    setState(() => _busy = true);
    try {
      await ref.read(walletProvider.notifier).createBackup(pin);
      _setStatus('Backup saved. You can restore this wallet on any device.');
    } catch (e) {
      _setStatus(_friendlyError(e), error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _confirmSend(String to, String amount) async {
    final fee = _fee;
    final total = (_amountValue ?? 0) + (fee?.feeEth ?? 0);

    final ok = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(235),
              border: Border(top: BorderSide(color: _sky.withAlpha(60))),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _sky.withAlpha(120),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Confirm transfer',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _InfoRow('To', _short(to)),
                  _InfoRow('Amount', '$amount ETH'),
                  _InfoRow(
                    'Network fee',
                    fee == null ? '—' : '${fee.feeEth.toStringAsFixed(8)} ETH',
                  ),
                  Divider(height: 24, color: _sky.withAlpha(60)),
                  _InfoRow('Total', '${total.toStringAsFixed(8)} ETH',
                      bold: true),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _skyDeep,
                            side: BorderSide(color: _sky.withAlpha(120)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: const Text('Cancel',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _GradientButton(
                          label: 'Confirm',
                          enabled: true,
                          height: 52,
                          onPressed: () => Navigator.pop(ctx, true),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    return ok ?? false;
  }

  Future<void> _send() async {
    final service = ref.read(walletServiceProvider);
    final wallet = ref.read(walletProvider);
    final to = _toController.text.trim();
    final amountText = _amountController.text.trim().replaceAll(',', '.');
    final amount = double.tryParse(amountText);

    if (!wallet.canSign) {
      _setStatus(
        'This device does not hold the signing key for this wallet.',
        error: true,
      );
      return;
    }
    if (!service.isValidAddress(to)) {
      _setStatus('Enter a valid 0x recipient address.', error: true);
      return;
    }
    if (wallet.address != null &&
        to.toLowerCase() == wallet.address!.toLowerCase()) {
      _setStatus("You can't send to your own address.", error: true);
      return;
    }
    if (amount == null || amount <= 0) {
      _setStatus('Enter a valid amount.', error: true);
      return;
    }
    if (amount + (_fee?.feeEth ?? 0) > wallet.balanceEth) {
      _setStatus('Amount plus network fee exceeds your balance.', error: true);
      return;
    }
    if (!await _confirmSend(to, amountText)) return;
    if (!mounted) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _sending = true;
      _status = 'Signing and broadcasting…';
      _statusIsError = false;
      _txHash = null;
    });

    try {
      final hash = await ref
          .read(walletProvider.notifier)
          .send(to: to, amountEth: amountText);
      if (!mounted) return;
      HapticFeedback.mediumImpact();

      setState(() {
        _sending = false;
        _confirming = true;
        _status = 'Transaction submitted. Waiting for confirmation…';
        _txHash = hash;
      });
      _toController.clear();
      _amountController.clear();

      final confirmed = await service.waitForConfirmation(hash);
      if (!mounted) return;
      setState(() {
        _confirming = false;
        if (confirmed == true) {
          _status = 'Transaction confirmed ✓';
        } else if (confirmed == false) {
          _status = 'Transaction failed on-chain.';
          _statusIsError = true;
        } else {
          _status = 'Still pending. Check the explorer for updates.';
        }
      });
      ref.read(walletProvider.notifier).refreshBalance();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _confirming = false;
        _status = _friendlyError(e);
        _statusIsError = true;
      });
    }
  }

  // --------------------------------- UI -------------------------------------

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletProvider);
    final service = ref.read(walletServiceProvider);

    final canSign = wallet.canSign;
    final addressOk = service.isValidAddress(_toController.text);
    final amount = _amountValue;
    final canSend = canSign &&
        !_sending &&
        !_busy &&
        addressOk &&
        amount != null &&
        amount > 0;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        foregroundColor: _ink,
        title: const Text(
          'Send',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Stack(
        children: [
          const _SkyBackdrop(),
          SafeArea(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _balanceCard(wallet, service),
                    if (wallet.needsRecovery) ...[
                      const SizedBox(height: 14),
                      _actionBanner(
                        icon: Icons.lock_rounded,
                        color: _warn,
                        text:
                            'Enter your wallet PIN to unlock sending on this device.',
                        buttonLabel: 'Unlock',
                        onPressed: _busy ? null : _unlock,
                      ),
                    ] else if (wallet.needsBackup) ...[
                      const SizedBox(height: 14),
                      _actionBanner(
                        icon: Icons.cloud_upload_rounded,
                        color: _skyDeep,
                        text:
                            'Back up your wallet with a PIN so you can restore it '
                            'on a new device.',
                        buttonLabel: 'Set PIN',
                        onPressed: _busy ? null : _setupBackup,
                      ),
                    ] else if (!canSign &&
                        wallet.hasWallet &&
                        !wallet.isLoading) ...[
                      const SizedBox(height: 14),
                      _banner(
                        Icons.key_off_rounded,
                        'No signing key is available for this wallet, so it can only '
                        'show the balance. Wallets created before the PIN backup '
                        'cannot be restored.',
                        _warn,
                      ),
                    ],
                    const SizedBox(height: 18),
                    _Glass(
                      radius: 32,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _label('Recipient'),
                          _field(
                            controller: _toController,
                            hint: '0x…',
                            suffix: IconButton(
                              icon: const Icon(Icons.content_paste_rounded,
                                  color: _skyDeep),
                              onPressed: _paste,
                            ),
                            valid:
                                _toController.text.isEmpty ? null : addressOk,
                          ),
                          const SizedBox(height: 16),
                          _label('Amount'),
                          _field(
                            controller: _amountController,
                            hint: '0.0',
                            keyboard: const TextInputType.numberWithOptions(
                                decimal: true),
                            formatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9.,]')),
                            ],
                            suffix: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: TextButton(
                                onPressed: canSign ? _max : null,
                                style: TextButton.styleFrom(
                                  backgroundColor: _skyPale,
                                  foregroundColor: _skyDeep,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'MAX',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                            prefix: const Padding(
                              padding: EdgeInsets.only(left: 16, right: 4),
                              child: Text(
                                'ETH',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700, color: _ink),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _feeSection(amount),
                          const SizedBox(height: 18),
                          _GradientButton(
                            label: _sending ? 'Sending…' : 'Send ETH',
                            icon: Icons.arrow_upward_rounded,
                            loading: _sending,
                            enabled: canSend,
                            onPressed: _send,
                          ),
                        ],
                      ),
                    ),
                    if (_status != null) ...[
                      const SizedBox(height: 16),
                      _statusCard(service),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _balanceCard(WalletState wallet, WalletService service) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7DD3FC), _sky, _skyDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withAlpha(160), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: _skyDeep.withAlpha(90),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Available balance',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(60),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 8, color: Color(0xFF86EFAC)),
                    const SizedBox(width: 6),
                    Text(
                      service.networkName,
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${wallet.balanceEth.toStringAsFixed(6)} ETH',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          if (wallet.address != null) ...[
            const SizedBox(height: 8),
            Text(
              _short(wallet.address!),
              style: TextStyle(color: Colors.white.withAlpha(220), fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  /// Compact fee summary; gas details are tucked behind a toggle.
  Widget _feeSection(double? amount) {
    final fee = _fee;
    final total = (amount ?? 0) + (fee?.feeEth ?? 0);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: _skyPale.withAlpha(150),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.local_gas_station_rounded,
                  color: _skyDeep, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Network fee',
                style: TextStyle(fontWeight: FontWeight.w700, color: _ink),
              ),
              const Spacer(),
              if (_feeLoading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                InkWell(
                  onTap: _loadFee,
                  child: const Icon(Icons.refresh_rounded,
                      size: 18, color: _muted),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (_feeError != null)
            Text(
              _feeError!,
              style: const TextStyle(color: _bad, fontSize: 13),
            )
          else ...[
            _InfoRow(
              'Estimated fee',
              fee == null ? '—' : '${fee.feeEth.toStringAsFixed(8)} ETH',
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.topCenter,
              child: _feeExpanded
                  ? Column(
                      children: [
                        _InfoRow(
                          'Gas price',
                          fee == null
                              ? '—'
                              : '${fee.gasPriceGwei.toStringAsFixed(2)} Gwei',
                        ),
                        _InfoRow('Gas limit',
                            fee == null ? '—' : fee.gasLimit.toString()),
                      ],
                    )
                  : const SizedBox(width: double.infinity),
            ),
            Divider(height: 18, color: _sky.withAlpha(70)),
            _InfoRow(
              'Total (amount + fee)',
              '${total.toStringAsFixed(8)} ETH',
              bold: true,
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () => setState(() => _feeExpanded = !_feeExpanded),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _feeExpanded ? 'Hide details' : 'Details',
                        style: const TextStyle(
                            color: _skyDeep,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                      Icon(
                        _feeExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: _skyDeep,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusCard(WalletService service) {
    final color = _statusIsError ? _bad : (_confirming ? _warn : _ok);

    return _Glass(
      radius: 24,
      padding: const EdgeInsets.all(16),
      tint: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (_confirming)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(
                  _statusIsError
                      ? Icons.error_outline
                      : Icons.check_circle_outline,
                  color: color,
                  size: 20,
                ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _status!,
                  style: TextStyle(color: color, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          if (_txHash != null) ...[
            const SizedBox(height: 10),
            SelectableText(
              service.explorerTxUrl(_txHash!),
              style: const TextStyle(fontSize: 12, color: _skyDeep),
            ),
          ],
        ],
      ),
    );
  }

  Widget _banner(IconData icon, String text, Color color) {
    return _Glass(
      radius: 22,
      padding: const EdgeInsets.all(14),
      tint: color,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: const TextStyle(fontSize: 13, color: _ink, height: 1.35)),
          ),
        ],
      ),
    );
  }

  Widget _actionBanner({
    required IconData icon,
    required Color color,
    required String text,
    required String buttonLabel,
    required VoidCallback? onPressed,
  }) {
    return _Glass(
      radius: 22,
      padding: const EdgeInsets.all(14),
      tint: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(text,
                    style: const TextStyle(
                        fontSize: 13, color: _ink, height: 1.35)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: _busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(buttonLabel),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(
          text,
          style: const TextStyle(
              fontWeight: FontWeight.w700, color: _ink, fontSize: 13),
        ),
      );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    Widget? suffix,
    Widget? prefix,
    TextInputType? keyboard,
    List<TextInputFormatter>? formatters,
    bool? valid,
  }) {
    final borderColor = valid == null
        ? _sky.withAlpha(60)
        : (valid ? _ok.withAlpha(140) : _bad.withAlpha(140));

    OutlineInputBorder border(Color c) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: c, width: 1.4),
        );

    return TextField(
      controller: controller,
      keyboardType: keyboard,
      inputFormatters: formatters,
      cursorColor: _skyDeep,
      style: const TextStyle(fontWeight: FontWeight.w600, color: _ink),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0x4D0C4A6E)),
        filled: true,
        fillColor: Colors.white.withAlpha(190),
        prefixIcon: prefix,
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: suffix,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        enabledBorder: border(borderColor),
        focusedBorder: border(_skyDeep),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// PIN dialog (owns and disposes its own controllers)
// -----------------------------------------------------------------------------

class _PinDialog extends StatefulWidget {
  final String title;
  final String message;
  final String actionLabel;
  final bool confirm;
  final int minLength;

  const _PinDialog({
    required this.title,
    required this.message,
    required this.actionLabel,
    this.confirm = false,
    this.minLength = 1,
  });

  @override
  State<_PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<_PinDialog> {
  final _pin = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _pin.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    // The PIN is intentionally NOT trimmed: it must match exactly.
    final pin = _pin.text;
    if (pin.length < widget.minLength) {
      setState(() => _error = widget.minLength > 1
          ? 'Use at least ${widget.minLength} characters.'
          : 'Enter your PIN.');
      return;
    }
    if (widget.confirm && pin != _confirm.text) {
      setState(() => _error = 'PINs do not match.');
      return;
    }
    Navigator.pop(context, pin);
  }

  InputDecoration _dec(String label) {
    OutlineInputBorder b(Color c) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: c, width: 1.4),
        );
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: _muted),
      floatingLabelStyle: const TextStyle(color: _skyDeep),
      filled: true,
      fillColor: _skyPale.withAlpha(120),
      enabledBorder: b(_sky.withAlpha(60)),
      focusedBorder: b(_skyDeep),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: Text(
        widget.title,
        style: const TextStyle(color: _ink, fontWeight: FontWeight.w800),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.message,
                style: const TextStyle(fontSize: 13, color: _muted, height: 1.4)),
            const SizedBox(height: 16),
            TextField(
              controller: _pin,
              obscureText: true,
              autofocus: true,
              autocorrect: false,
              enableSuggestions: false,
              cursorColor: _skyDeep,
              decoration: _dec('Wallet PIN'),
              onSubmitted: widget.confirm ? null : (_) => _submit(),
            ),
            if (widget.confirm) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _confirm,
                obscureText: true,
                autocorrect: false,
                enableSuggestions: false,
                cursorColor: _skyDeep,
                decoration: _dec('Confirm PIN'),
                onSubmitted: (_) => _submit(),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                style: const TextStyle(color: _bad, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(foregroundColor: _muted),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: _skyDeep,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
          ),
          child: Text(widget.actionLabel),
        ),
      ],
    );
  }
}

// ───────────────────────── Shared widgets ─────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _InfoRow(this.label, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: _muted, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              color: _ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool enabled;
  final bool loading;
  final double height;
  final VoidCallback onPressed;

  const _GradientButton({
    required this.label,
    required this.enabled,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.height = 58,
  });

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(height / 2);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: r,
        gradient:
            enabled ? const LinearGradient(colors: [_sky, _skyDeep]) : null,
        color: enabled ? null : _skyPale,
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: _skyDeep.withAlpha(90),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: r,
          onTap: enabled ? onPressed : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (loading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              else if (icon != null)
                Icon(icon,
                    color: enabled ? Colors.white : _skyDeep.withAlpha(150)),
              if (loading || icon != null) const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: enabled ? Colors.white : _skyDeep.withAlpha(150),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Reusable frosted-glass surface. Pass [tint] for status-coloured glass.
class _Glass extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;
  final int alpha;
  final Color? tint;
  const _Glass({
    required this.child,
    required this.radius,
    required this.padding,
    this.alpha = 120,
    this.tint,
  });

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(radius);
    final accent = tint ?? _skyDeep;
    return Container(
      decoration: BoxDecoration(
        borderRadius: r,
        boxShadow: [
          BoxShadow(
            color: accent.withAlpha(36),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: r,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: r,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: tint == null
                    ? [
                        Colors.white.withAlpha(alpha + 50),
                        Colors.white.withAlpha(alpha),
                      ]
                    : [
                        Color.alphaBlend(
                            tint!.withAlpha(34), Colors.white.withAlpha(200)),
                        Color.alphaBlend(
                            tint!.withAlpha(20), Colors.white.withAlpha(170)),
                      ],
              ),
              border: Border.all(
                color: tint == null
                    ? Colors.white.withAlpha(200)
                    : tint!.withAlpha(90),
                width: 1.2,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// White page with soft blurred sky-blue blobs for the glass to refract.
class _SkyBackdrop extends StatelessWidget {
  const _SkyBackdrop();

  Widget _blob(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
        child: Stack(
          children: [
            Positioned(top: -60, right: -70, child: _blob(280, _sky.withAlpha(150))),
            Positioned(
                top: 300,
                left: -110,
                child: _blob(260, const Color(0xFF7DD3FC).withAlpha(140))),
            Positioned(bottom: -80, right: -40, child: _blob(300, _skyDeep.withAlpha(90))),
          ],
        ),
      ),
    );
  }
}