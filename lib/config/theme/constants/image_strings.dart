import 'package:flutter/material.dart';
import '../../../data/models/payments/payment_methods_model.dart';

//===========================================================
//       App Image Strings
// This class contains all the App Images in String formats.
//===========================================================
class AppImages {

  //=============================================================
  //  App Logos
  //=============================================================
  static const String darkAppLogo  = "assets/logos/t-store-splash-logo-black.png";
  static const String lightAppLogo = "assets/logos/t-store-splash-logo-white.png";

  //=============================================================
  //  OnBoarding Texts
  //=============================================================
  static const String onBoardingImage1 = "assets/images/on_boarding_images/shield_handshake.png";
  static const String onBoardingImage2 = "assets/images/on_boarding_images/spend_money.png";
  static const String onBoardingImage3 = "assets/images/on_boarding_images/receive_money.png";

  //=============================================================   
  //  Account setup
  //=============================================================
  static const String createAccount = "assets/images/create_account.png";
  static const String welcome       = "assets/images/welcome.png";

  //=============================================================
  //  Banners
  //=============================================================
  static const String promoBanner1 = "assets/images/products/promo-banner-1.png";
  static const String promoBanner2 = "assets/images/products/promo-banner-2.png";
  static const String promoBanner3 = "assets/images/products/promo-banner-3.png";   
  static const String banner1      = "assets/images/banners/banner_1.jpg";
  static const String banner2      = "assets/images/banners/banner_2.jpg";
  static const String banner3      = "assets/images/banners/banner_3.jpg";
  static const String banner4      = "assets/images/banners/banner_4.jpg";
  static const String banner5      = "assets/images/banners/banner_5.jpg";
  static const String banner6      = "assets/images/banners/banner_6.jpg";
  static const String banner7      = "assets/images/banners/banner_7.jpg";
  static const String banner8      = "assets/images/banners/banner_8.jpg";

  //=============================================================
  //  Profile
  //=============================================================
  static const String user = "assets/images/content/user.png";

  //=============================================================
  //  Country Flag
  //=============================================================
  static const String countryFlag = "assets/images/SA_flag.jpg";

  //=============================================================
  //  Payment Options
  //=============================================================
  static const String applePay              = "assets/icons/payment_methods/apple-pay.png";
  static const String googlePay             = "assets/icons/payment_methods/google-pay.png";
  static const String creditCard            = "assets/icons/payment_methods/credit-card.png";
  static const String masterCard            = "assets/icons/payment_methods/master-card.png";
  static const String paypal                = "assets/icons/payment_methods/paypal.png";
  static const String visa                  = "assets/icons/payment_methods/visa.png";
  static const String paystack              = "assets/icons/payment_methods/paystack.png";
  static const String paytm                 = "assets/icons/payment_methods/paytm.png";
  static const String successfulPaymentIcon = "assets/icons/payment_methods/successful_payment_icon.png";
}

//=============================================================
//  Payment Methods
//=============================================================
const List<PaymentMethods> paymentMethods = [
  PaymentMethods(name: 'Instant Bank Transfer', icon: Icons.flash_on),
  PaymentMethods(name: 'Ozow', assetImage: 'assets/images/ozow.png'),
  PaymentMethods(name: 'TRON - TRX', assetImage: 'assets/images/tron.png'),
  PaymentMethods(name: 'PayShap', assetImage: 'assets/images/payShap.png'),
 
];