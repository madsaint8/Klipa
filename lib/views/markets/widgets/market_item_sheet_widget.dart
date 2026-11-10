import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../logic/market_formatters.dart';
import '../logic/market_validators.dart';
import '../models/market_item_model.dart';
import '../providers/market_purchase_provider.dart';
import '../theme/market_theme.dart';
import 'change_badge_widget.dart';
import 'glass_container_widget.dart';
import 'market_avatar_widget.dart';
import 'market_button_widget.dart';

Future<void> showMarketItemSheet(BuildContext context, MarketItem item) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => MarketItemSheet(item: item),
  );
}

/// Details + purchase flow for any item, in one glass sheet:
/// details -> choose plan/amount -> processing -> success (or inline error).
/// The sheet can't be dismissed mid-payment.
class MarketItemSheet extends ConsumerStatefulWidget {
  const MarketItemSheet({super.key, required this.item});

  final MarketItem item;

  @override
  ConsumerState<MarketItemSheet> createState() => _MarketItemSheetState();
}

class _MarketItemSheetState extends ConsumerState<MarketItemSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountCtrl = TextEditingController(
    text: widget.item.presets.isNotEmpty
        ? widget.item.presets.first.round().toString()
        : widget.item.minAmount.round().toString(),
  );
  int _planIndex = 0;

  MarketItem get item => widget.item;

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  double? get _amount => item.plans.isNotEmpty
      ? item.plans[_planIndex].amount
      : MarketValidators.parseAmount(_amountCtrl.text);

  Future<void> _submit() async {
    if (item.plans.isEmpty && !(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final amount = _amount;
    if (amount == null) return;
    FocusScope.of(context).unfocus();
    HapticFeedback.mediumImpact();
    await ref.read(marketPurchaseProvider.notifier).purchase(
          item: item,
          amount: amount,
          planId: item.plans.isNotEmpty ? item.plans[_planIndex].id : null,
        );
    if (mounted &&
        ref.read(marketPurchaseProvider).status == PurchaseStatus.success) {
      HapticFeedback.heavyImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final purchase = ref.watch(marketPurchaseProvider);
    final processing = purchase.status == PurchaseStatus.processing;

    return PopScope(
      canPop: !processing,
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.92),
          child: GlassContainer(
            opacity: 0.8,
            blur: 24,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
            child: SingleChildScrollView(
              child: AnimatedSwitcher(
                duration: MarketTheme.switchDuration,
                switchInCurve: Curves.easeOutCubic,
                child: purchase.status == PurchaseStatus.success
                    ? _Success(
                        key: const ValueKey('success'),
                        item: item,
                        amount: _amount ?? 0,
                        reference: purchase.reference ?? '',
                      )
                    : KeyedSubtree(
                        key: const ValueKey('form'),
                        child: _buildForm(purchase, processing),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(PurchaseState purchase, bool processing) {
    final amount = _amount;
    final label = amount == null
        ? item.action.label
        : '${item.action.label}  •  ${MarketFormatters.amount(amount)}';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: MarketColors.textMuted.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            MarketAvatar(item: item, size: 56),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: MarketColors.text)),
                  Text(item.subtitle,
                      style: const TextStyle(
                          fontSize: 13, color: MarketColors.textSub)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(item.priceLabel,
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: MarketColors.text)),
                if (item.changePercent != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: ChangeBadge(percent: item.changePercent!),
                  ),
              ],
            ),
          ],
        ),
        if (item.description.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(item.description,
              style: const TextStyle(
                  fontSize: 14, color: MarketColors.textSub, height: 1.5)),
        ],
        if (item.tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final t in item.tags)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: MarketColors.tag,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(t,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: MarketColors.textSub)),
                ),
            ],
          ),
        ],
        const SizedBox(height: 20),
        if (!item.action.isTransaction)
          _buildExplore()
        else ...[
          item.plans.isNotEmpty ? _buildPlans() : _buildAmount(),
          if (purchase.status == PurchaseStatus.failure) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Iconsax.warning_2,
                    size: 16, color: MarketColors.negative),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(purchase.message ?? 'Something went wrong.',
                      style: const TextStyle(
                          fontSize: 13, color: MarketColors.negative)),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          MarketButton(
            label: label,
            gradient: item.tab.gradient,
            loading: processing,
            onPressed: _submit,
          ),
          const SizedBox(height: 10),
          Text(
            item.tab.isInvestment
                ? 'Prices can go up and down and you may get back less than you invest.'
                : 'Subject to the provider’s terms. Paid from your wallet balance.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11.5, color: MarketColors.textMuted),
          ),
        ],
      ],
    );
  }

  Widget _buildExplore() {
    final url = item.url;
    if (url == null || url.isEmpty) return const SizedBox.shrink();
    return MarketButton(
      label: 'Copy link',
      icon: Iconsax.copy,
      gradient: item.tab.gradient,
      onPressed: () async {
        await Clipboard.setData(ClipboardData(text: url));
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Link copied'),
              behavior: SnackBarBehavior.floating),
        );
      },
    );
  }

  Widget _buildAmount() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Amount',
              style: TextStyle(
                  fontWeight: FontWeight.w700, color: MarketColors.text)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              LengthLimitingTextInputFormatter(9),
            ],
            onChanged: (_) => setState(() {}),
            validator: (v) => MarketValidators.amountText(item, v),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              prefixText: '\$ ',
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: item.tab.accent, width: 1.5),
              ),
            ),
          ),
          if (item.presets.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                for (final p in item.presets)
                  ActionChip(
                    label: Text(MarketFormatters.amount(p)),
                    onPressed: () => setState(
                        () => _amountCtrl.text = p.round().toString()),
                    backgroundColor: MarketColors.skyLight,
                    side: BorderSide.none,
                    labelStyle: TextStyle(
                        color: item.tab.accent, fontWeight: FontWeight.w700),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlans() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Choose a plan',
            style: TextStyle(
                fontWeight: FontWeight.w700, color: MarketColors.text)),
        const SizedBox(height: 8),
        for (var i = 0; i < item.plans.length; i++)
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _planIndex = i);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: i == _planIndex ? 0.95 : 0.55),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: i == _planIndex ? item.tab.accent : Colors.transparent,
                  width: 1.6,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.plans[i].label,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: MarketColors.text)),
                        Text(item.plans[i].caption,
                            style: const TextStyle(
                                fontSize: 12, color: MarketColors.textSub)),
                      ],
                    ),
                  ),
                  Text(MarketFormatters.amount(item.plans[i].amount),
                      style: TextStyle(
                          fontWeight: FontWeight.w800, color: item.tab.accent)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Success extends StatelessWidget {
  const _Success({
    super.key,
    required this.item,
    required this.amount,
    required this.reference,
  });

  final MarketItem item;
  final double amount;
  final String reference;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.6, end: 1),
            duration: const Duration(milliseconds: 450),
            curve: Curves.elasticOut,
            builder: (_, v, child) => Transform.scale(scale: v, child: child),
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                  gradient: item.tab.gradient, shape: BoxShape.circle),
              child: const Icon(Iconsax.tick_circle,
                  size: 44, color: Colors.white),
            ),
          ),
          const SizedBox(height: 18),
          const Text('All done!',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: MarketColors.text)),
          const SizedBox(height: 6),
          Text('${item.title}  •  ${MarketFormatters.amount(amount)}',
              style: const TextStyle(fontSize: 14, color: MarketColors.textSub)),
          const SizedBox(height: 14),
          SelectableText('Reference: $reference',
              style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: MarketColors.textMuted)),
          const SizedBox(height: 22),
          MarketButton(
            label: 'Done',
            gradient: item.tab.gradient,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
