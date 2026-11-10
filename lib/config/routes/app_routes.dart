import 'package:flutter/material.dart';
import '../../core/widgets/auth_wrapper.dart';
import '../../views/beneficiaries/add_bank_beneficiary.dart';
import '../../views/beneficiaries/add_beneficiary_screen.dart';
import '../../views/value_added_services/screens/airtime/airtime_screen.dart';

class AppRoutes { 
  static const String authWrapper = '/auth-wrapper';
  static const String addBeneficiary = '/add-beneficiary';
  static const String contactNumber = '/contact-Number';
  static const String registeredBeneficiary = '/registered-beneficiary';
  static const String bankAccount = '/bank-account';
  static const String airtime = '/airtime';
  static const String buyElectricity = '/buy-electricity';
  static const String payshap = '/payshap';
  static const String payBills = '/pay-bills';
  static const String buyVouchers = '/buy-vouchers';
  static const String playLotto = '/play-lotto';

  static final routes = <String, WidgetBuilder>{
    authWrapper: (_) => const AuthWrapper(),
    addBeneficiary: (_) => const AddBeneficiaryPage(),
    contactNumber: (_) => const AddBeneficiaryPage(),
    registeredBeneficiary: (_) => const AddBeneficiaryPage(),
    bankAccount: (_) => const SendBankAccountPage(),
    airtime: (_) => const AirtimeScreen(),
    buyElectricity: (_) => const Scaffold(body: Center(child: Text("Buy Electricity Screen"))),
    payshap: (_) => const Scaffold(body: Center(child: Text("PayShap Screen"))),
    payBills: (_) => const Scaffold(body: Center(child: Text("Pay Bills Screen"))),
    buyVouchers: (_) => const Scaffold(body: Center(child: Text("Buy Vouchers Screen"))),
    playLotto: (_) => const Scaffold(body: Center(child: Text("Play Lotto Screen"))),
  };
}