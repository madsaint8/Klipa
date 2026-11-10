import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../config/routes/app_routes.dart';
import '../../models/services/quick_service_model.dart';

final List<QuickServiceModel> QuickServiceOptions = [
  const QuickServiceModel(
    title: 'Buy Prepaid Mobile',
    icon: Icons.smartphone_rounded,
    routeName: AppRoutes.airtime,
    accentColor: Colors.indigo,
  ),
  const QuickServiceModel(
    title: 'Buy Electricity',
    icon: Icons.lightbulb_rounded,
    routeName: AppRoutes.buyElectricity,
    accentColor: Colors.amber,
  ),
  const QuickServiceModel(
    title: 'PayShap',
    icon: Icons.group_rounded,
    routeName: AppRoutes.payshap,
    accentColor: Colors.teal,
  ),
  const QuickServiceModel(
    title: 'Pay Bills',
    icon: Icons.swap_horiz_rounded,
    routeName: AppRoutes.payBills,
    accentColor: Colors.orange,
  ),
  const QuickServiceModel(
    title: 'Buy Vouchers',
    icon: Iconsax.ticket,
    routeName: AppRoutes.buyVouchers,
    accentColor: Colors.purple,
  ),
  const QuickServiceModel(
    title: 'Play Lotto',
    icon: Icons.casino_rounded,
    routeName: AppRoutes.playLotto,
    accentColor: Colors.green,
  ),
];