import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:paywave/config/routes/app_routes.dart';
import '../models/quick_service_model.dart';

/// Every service the app offers. Which ones appear under "Quick Services" is
/// decided by the user's favourites (see favourite_services_provider.dart).
///
/// To add a service: add an entry here with a NEW unique id and a route that
/// exists in AppRoutes. Users can then add it from the Edit screen.
const List<QuickServiceModel> quickServiceCatalog = [
  QuickServiceModel(
    id: 'airtime',
    title: 'Buy Prepaid Mobile',
    shortTitle: 'Airtime',
    icon: Icons.smartphone_rounded,
    routeName: AppRoutes.airtime,
  ),
  QuickServiceModel(
    id: 'electricity',
    title: 'Buy Electricity',
    shortTitle: 'Electricity',
    icon: Icons.lightbulb_rounded,
    routeName: AppRoutes.buyElectricity,
  ),
  QuickServiceModel(
    id: 'payshap',
    title: 'PayShap',
    icon: Icons.group_rounded,
    routeName: AppRoutes.payshap,
  ),
  QuickServiceModel(
    id: 'pay_bills',
    title: 'Pay Bills',
    icon: Icons.receipt_long_rounded,
    routeName: AppRoutes.payBills,
  ),
  QuickServiceModel(
    id: 'vouchers',
    title: 'Buy Vouchers',
    shortTitle: 'Vouchers',
    icon: Iconsax.ticket,
    routeName: AppRoutes.buyVouchers,
  ),
  QuickServiceModel(
    id: 'lotto',
    title: 'Play Lotto',
    shortTitle: 'Lotto',
    icon: Icons.casino_rounded,
    routeName: AppRoutes.playLotto,
  ),
  QuickServiceModel(
    id: 'bank_transfer',
    title: 'Send to Bank Account',
    shortTitle: 'To Bank',
    icon: Icons.account_balance_rounded,
    routeName: AppRoutes.bankAccount,
  ),
  QuickServiceModel(
    id: 'beneficiary',
    title: 'Add Beneficiary',
    shortTitle: 'Add Payee',
    icon: Icons.person_add_alt_1_rounded,
    routeName: AppRoutes.addBeneficiary,
  ),
];

final Map<String, QuickServiceModel> quickServiceById = {
  for (final s in quickServiceCatalog) s.id: s,
};

/// Shown on first launch, before the user has customised anything.
/// (Existing users keep their saved list and can add new ones via Edit.)
const List<String> defaultFavouriteIds = [
  'airtime',
  'electricity',
  'payshap',
  'pay_bills',
  'vouchers',
  'lotto',
  'bank_transfer',
  'beneficiary',
];