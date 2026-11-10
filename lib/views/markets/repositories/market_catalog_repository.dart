import 'dart:async';
import 'dart:math';
import '../models/market_item_model.dart';
import '../models/market_tab_model.dart';

/// Message is always safe to show to the user.
class MarketException implements Exception {
  const MarketException(this.message);
  final String message;

  @override
  String toString() => 'MarketException($message)';
}

/// Data source for the parts of the marketplace that don't come from an
/// existing API (RWAs, insurance, services) plus purchases.
/// Swap [MockMarketCatalogRepository] for backend by overriding
/// marketCatalogRepositoryProvider — no UI changes needed.
abstract class MarketCatalogRepository {
  Future<List<MarketItem>> fetchRwas();
  Future<List<MarketItem>> fetchInsurance();
  Future<List<MarketItem>> fetchServices();

  /// Returns a receipt/reference. Must be idempotent server-side
  /// (send an idempotency key when you implement this for real).
  Future<String> purchase(PurchaseRequest request);
}

class MockMarketCatalogRepository implements MarketCatalogRepository {
  final _random = Random.secure();

  Future<void> _latency() =>
      Future<void>.delayed(const Duration(milliseconds: 500));

  static MarketPlan _plan(String id, String label, String caption, double amt) =>
      MarketPlan(id: id, label: label, caption: caption, amount: amt);

  @override
  Future<List<MarketItem>> fetchRwas() async {
    await _latency();
    const presets = <double>[100, 500, 1000, 5000];
    return [
      MarketItem(
        id: 'rwa:tbill-6m',
        tab: MarketTab.rwas,
        title: 'US Treasury Bill 6M',
        subtitle: 'Tokenized government bond',
        priceLabel: 'R102.40',
        badge: '5.1% APY',
        tags: const ['Bond', 'USD', 'Low risk'],
        description:
            'Short-term US government debt, tokenized for fractional ownership. '
            'Interest accrues daily.',
        minAmount: 50,
        presets: presets,
        keywords: const ['treasury', 'government', 'fixed income', 'yield'],
      ),
      MarketItem(
        id: 'rwa:lagos-realty',
        tab: MarketTab.rwas,
        title: 'Lagos Prime Realty Fund',
        subtitle: 'Tokenized real estate',
        priceLabel: 'R25.00',
        badge: '8.4% yield',
        tags: const ['Real estate', 'Africa', 'Rental income'],
        description:
            'A basket of managed rental properties. Own a slice and earn '
            'monthly rental distributions.',
        minAmount: 25,
        presets: presets,
        keywords: const ['property', 'house', 'rent', 'nigeria'],
      ),
      MarketItem(
        id: 'rwa:vaulted-gold',
        tab: MarketTab.rwas,
        title: 'Vaulted Gold',
        subtitle: 'Tokenized gold bullion',
        priceLabel: 'R2,410.00',
        priceCaption: 'per oz',
        changePercent: 0.6,
        tags: const ['Commodity', 'Gold', 'Hedge'],
        description:
            'Each token is backed 1:1 by allocated physical gold held in '
            'audited vaults.',
        minAmount: 20,
        presets: presets,
        keywords: const ['precious metal', 'bullion', 'xau'],
      ),
      MarketItem(
        id: 'rwa:farmland',
        tab: MarketTab.rwas,
        title: 'Farmland Yield Note',
        subtitle: 'Agricultural income note',
        priceLabel: 'R10.00',
        badge: '9.2% APY',
        tags: const ['Agriculture', 'Africa', 'Short term'],
        description:
            'Finance verified smallholder farms and earn a share of harvest '
            'revenue.',
        minAmount: 10,
        presets: presets,
        keywords: const ['farm', 'crop', 'food'],
      ),
      MarketItem(
        id: 'rwa:solar-bond',
        tab: MarketTab.rwas,
        title: 'Solar Grid Bond',
        subtitle: 'Renewable energy bond',
        priceLabel: 'R50.00',
        badge: '7.1% APY',
        tags: const ['Energy', 'Green', 'Bond'],
        description:
            'Fund community solar installations and earn fixed returns '
            'from energy sales.',
        minAmount: 50,
        presets: presets,
        keywords: const ['solar', 'renewable', 'power', 'electricity'],
      ),
      MarketItem(
        id: 'rwa:carbon',
        tab: MarketTab.rwas,
        title: 'Carbon Credit Basket',
        subtitle: 'Verified carbon offsets',
        priceLabel: 'R18.75',
        changePercent: -1.2,
        tags: const ['Carbon', 'ESG', 'Offsets'],
        description:
            'A diversified basket of verified carbon credits you can hold '
            'or retire.',
        minAmount: 10,
        presets: presets,
        keywords: const ['climate', 'environment', 'esg'],
      ),
    ];
  }

  @override
  Future<List<MarketItem>> fetchInsurance() async {
    await _latency();
    return [
      MarketItem(
        id: 'ins:smart-contract',
        tab: MarketTab.insurance,
        title: 'Smart Contract Cover',
        subtitle: 'Protects DeFi deposits from exploits',
        priceLabel: 'From R90',
        priceCaption: '/ month',
        tags: const ['DeFi', 'Wallet', 'Hacks'],
        description:
            'Get paid out if a covered protocol is exploited or drained.',
        action: MarketAction.getCover,
        plans: [
          _plan('basic', 'Basic', 'Up to R1,000 cover', 5),
          _plan('standard', 'Standard', 'Up to R5,000 cover', 20),
          _plan('premium', 'Premium', 'Up to R25,000 cover', 85),
        ],
        keywords: const ['hack', 'exploit', 'defi cover', 'protection'],
      ),
      MarketItem(
        id: 'ins:wallet-theft',
        tab: MarketTab.insurance,
        title: 'Wallet Theft Protection',
        subtitle: 'Covers phishing & unauthorized transfers',
        priceLabel: 'From R40',
        priceCaption: '/ month',
        tags: const ['Wallet', 'Fraud', 'Phishing'],
        description:
            'Reimburses funds lost to phishing, SIM-swap or unauthorized '
            'transfers.',
        action: MarketAction.getCover,
        plans: [
          _plan('basic', 'Basic', 'Up to R500 cover', 4),
          _plan('plus', 'Plus', 'Up to R2,500 cover', 14),
        ],
        keywords: const ['scam', 'stolen', 'security'],
      ),
      MarketItem(
        id: 'ins:device',
        tab: MarketTab.insurance,
        title: 'Device Protection',
        subtitle: 'Phone loss, theft & damage',
        priceLabel: 'From R68',
        priceCaption: '/ month',
        tags: const ['Phone', 'Gadgets'],
        description: 'Repair or replace your phone if it is lost, stolen or broken.',
        action: MarketAction.getCover,
        plans: [
          _plan('basic', 'Screen only', 'Cracked screen repair', 6),
          _plan('full', 'Full cover', 'Loss, theft & damage', 12),
        ],
        keywords: const ['mobile', 'smartphone', 'screen'],
      ),
      MarketItem(
        id: 'ins:travel',
        tab: MarketTab.insurance,
        title: 'Travel Cover',
        subtitle: 'Medical, delays & lost luggage',
        priceLabel: 'From R120',
        priceCaption: '/ trip',
        tags: const ['Travel', 'Medical', 'Luggage'],
        description: 'Single-trip cover for medical emergencies, delays and baggage.',
        action: MarketAction.getCover,
        plans: [
          _plan('week', '1 week', 'Up to R50,000 medical', 12),
          _plan('month', '1 month', 'Up to R50,000 medical', 35),
        ],
        keywords: const ['holiday', 'flight', 'abroad', 'trip'],
      ),
      MarketItem(
        id: 'ins:health',
        tab: MarketTab.insurance,
        title: 'Micro Health Plan',
        subtitle: 'Affordable everyday health cover',
        priceLabel: 'From R80',
        priceCaption: '/ month',
        tags: const ['Health', 'Family'],
        description: 'Covers clinic visits, medication and hospital stays.',
        action: MarketAction.getCover,
        plans: [
          _plan('solo', 'Individual', 'Clinic & medication', 8),
          _plan('family', 'Family', 'Up to 4 people', 24),
        ],
        keywords: const ['medical', 'hospital', 'doctor', 'clinic'],
      ),
      MarketItem(
        id: 'ins:crop',
        tab: MarketTab.insurance,
        title: 'Crop & Weather Cover',
        subtitle: 'Parametric drought & flood protection',
        priceLabel: 'From R150',
        priceCaption: '/ season',
        tags: const ['Agriculture', 'Weather'],
        description:
            'Pays out automatically when rainfall data crosses your trigger.',
        action: MarketAction.getCover,
        plans: [
          _plan('small', 'Smallholder', '1-2 hectares', 15),
          _plan('farm', 'Farm', 'Up to 10 hectares', 60),
        ],
        keywords: const ['farm', 'drought', 'flood', 'rain'],
      ),
    ];
  }

  @override
  Future<List<MarketItem>> fetchServices() async {
    await _latency();
    return [
      MarketItem(
        id: 'svc:airtime',
        tab: MarketTab.services,
        title: 'Airtime & Data',
        subtitle: 'Top up any network instantly',
        priceLabel: 'From R10',
        tags: const ['Mobile', 'Data'],
        description: 'Instant airtime and data bundles for all major networks.',
        action: MarketAction.useService,
        plans: [
          _plan('a5', 'R25', 'Airtime', 5),
          _plan('a10', 'R110', 'Airtime + 1GB', 110),
          _plan('a20', 'R280', 'Airtime + 5GB', 280),
        ],
        keywords: const ['phone', 'recharge', 'bundle', 'internet'],
      ),
      MarketItem(
        id: 'svc:bills',
        tab: MarketTab.services,
        title: 'Pay Bills',
        subtitle: 'Electricity, water, TV & internet',
        priceLabel: 'No fees',
        tags: const ['Utilities'],
        description: 'Settle household bills from your wallet in seconds.',
        action: MarketAction.useService,
        plans: [
          _plan('b25', 'R625', 'Bill payment', 625),
          _plan('b50', 'R1,250', 'Bill payment', 1250),
          _plan('b100', 'R2,500', 'Bill payment', 2500),
        ],
        keywords: const ['electricity', 'water', 'dstv', 'wifi', 'utility'],
      ),
      MarketItem(
        id: 'svc:remit',
        tab: MarketTab.services,
        title: 'Send Money Abroad',
        subtitle: 'Low-fee international transfers',
        priceLabel: 'From 0.5%',
        priceCaption: 'fee',
        tags: const ['Remittance', 'Global'],
        description: 'Send money to friends and family in minutes at fair rates.',
        action: MarketAction.useService,
        plans: [
          _plan('r100', 'R100', 'Transfer', 100),
          _plan('r500', 'R500', 'Transfer', 500),
        ],
        keywords: const ['transfer', 'remittance', 'international', 'family'],
      ),
      MarketItem(
        id: 'svc:card-topup',
        tab: MarketTab.services,
        title: 'Virtual Card Top-up',
        subtitle: 'Fund your virtual cards',
        priceLabel: 'Instant',
        tags: const ['Cards'],
        description: 'Add funds to your virtual debit cards for online spending.',
        action: MarketAction.useService,
        plans: [
          _plan('c50', 'R1,250', 'Top-up', 1250),
          _plan('c200', 'R2500', 'Top-up', 2500),
        ],
        keywords: const ['card', 'fund', 'online shopping'],
      ),
      MarketItem(
        id: 'svc:tax',
        tab: MarketTab.services,
        title: 'Crypto Tax Report',
        subtitle: 'Annual gains & income summary',
        priceLabel: 'R150',
        priceCaption: '/ year',
        tags: const ['Tax', 'Compliance'],
        description: 'A clean, accountant-ready report of your on-chain activity.',
        action: MarketAction.useService,
        plans: [_plan('t1', '1 year', 'PDF + CSV export', 15)],
        keywords: const ['accounting', 'capital gains', 'report'],
      ),
    ];
  }

  @override
  Future<String> purchase(PurchaseRequest request) async {
    await _latency();
    if (request.amount <= 0) {
      throw const MarketException('Invalid amount.');
    }
    // TODO(real backend): check wallet balance, send an idempotency key.
    final ref = List.generate(8, (_) => _random.nextInt(36).toRadixString(36));
    return 'PW-${ref.join().toUpperCase()}';
  }
}
