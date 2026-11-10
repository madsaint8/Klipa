import '../../../data/models/notifications/notification_item_model.dart';
import '../../../data/models/crypto/stock.dart';




// Crypto data
// const List<CryptoNews> trendingNews = [
//   CryptoNews(
//     name: 'Bitcoin',
//     symbol: 'BTC',
//     price: 'IBIT Hits 700,000 BTC—Blackrock’s Grip\n on Bitcoin Tightens',
//     percentage: '-1.36',
//     iconPath: 'assets/images/crypto/news/news01.webp',
//   ),
//   CryptoNews(
//     name: 'Ethereum',
//     symbol: 'ETH',
//     price: 'IBIT Hits 700,000 BTC—Blackrock’s Grip\n on Bitcoin Tightens',
//     percentage: '-0.65',
//     iconPath: 'assets/images/crypto/news/news02.avif',
//   ),
//   CryptoNews(
//     name: 'Cardano',
//     symbol: 'ADA',
//     price: 'IBIT Hits 700,000 BTC—Blackrock’s Grip\n on Bitcoin Tightens',
//     percentage: '-0.79',
//     iconPath: 'assets/images/crypto/news/news03.avif',
//   ),
//   CryptoNews(
//     name: 'Cardano',
//     symbol: 'ADA',
//     price: 'IBIT Hits 700,000 BTC—Blackrock’s Grip\n on Bitcoin Tightens',
//     percentage: '-0.79',
//     iconPath: 'assets/images/crypto/news/news04.avif',
//   ),
// ];



// Country list
const List<Map<String, String>> countries = [
  {'name': 'Bangladesh', 'flag': '🇧🇩', 'code': '+880'},
  {'name': 'United States', 'flag': '🇺🇸', 'code': '+1'},
  {'name': 'Singapore', 'flag': '🇸🇬', 'code': '+65'},
  {'name': 'India', 'flag': '🇮🇳', 'code': '+91'},
  {'name': 'South Africa', 'flag': '🇿🇦', 'code': '+27'},
  {'name': 'Nigeria', 'flag': '🇳🇬', 'code': '+234'},
  {'name': 'Kenya', 'flag': '🇰🇪', 'code': '+254'},
  {'name': 'Ghana', 'flag': '🇬🇭', 'code': '+233'},
];



// Visibility
const String secret = '**********';
const String zeroBalance = '*******';


// Stock Data
final List<Stock> stocks = [
  Stock(
      name: 'Lively Inc.',
      symbol: 'LIVELY',
      price: 432.21,
      change: 2.53,
      changePercent: 9,
      isPositive: true),
  Stock(
      name: 'Ardy Inc.',
      symbol: 'ARDY',
      price: 245.89,
      change: -0.32,
      changePercent: 3,
      isPositive: false),
  Stock(
      name: 'Urdan Inc.',
      symbol: 'URDAN',
      price: 213.22,
      change: 2.49,
      changePercent: 8,
      isPositive: true),
  Stock(
      name: 'Holly Inc.',
      symbol: 'HOLLY',
      price: 821.87,
      change: -21.3,
      changePercent: 12,
      isPositive: false),
  Stock(
      name: 'Sicole Inc.',
      symbol: 'SICOLE',
      price: 245.32,
      change: 3.21,
      changePercent: 7,
      isPositive: true),
  Stock(
      name: 'Steve Inc.',
      symbol: 'STEVE',
      price: 421.98,
      change: -12.4,
      changePercent: 9,
      isPositive: false),
  Stock(
      name: 'Cybill Inc.',
      symbol: 'CYBILL',
      price: 873.23,
      change: 3.54,
      changePercent: 4,
      isPositive: true),
  Stock(
      name: 'Zack Inc.',
      symbol: 'ZACK',
      price: 982.32,
      change: 0.0,
      changePercent: 0,
      isPositive: true),
];



// Notificationns
final notifications = <NotificationItem>[
    NotificationItem(
      title: "Shop safely this Black Friday",
      subtitle: "Conversation assigned",
      date: DateTime(2022, 11, 16),
      daysAgo: "5 days ago",
      content: "Scammers are more active on social media, tricking people into Ponzi or pyramid schemes and crypto scams with promises of quick, high returns. They might disappear as soon as you've paid over your money.\n\n"
                "Avoid these scams:\n"
                "• Don’t invest with people contacting you on social media\n"
                "• Research and stick to what you know\n"
                "• Verify that the platform is FSCA-licensed\n"
                "• Never share personal info till you verify the investment's legitimacy\n"
                "• Be wary of promises of high returns with no risks",
      imageAsset: 'assets/images/investment_scam.png',          
    ),
    NotificationItem(
      title: "Pay safely this Black Friday",
      subtitle: "app-release-neeto: Visitor sent a message",
      date: DateTime(2022, 11, 16),
      daysAgo: "5 days ago",
      content: "Scammers are more active on social media, tricking people into Ponzi or pyramid schemes and crypto scams with promises of quick, high returns. They might disappear as soon as you've paid over your money.\n\n"
               "Avoid these scams:\n"
               "• Don’t invest with people contacting you on social media\n"
               "• Research and stick to what you know\n"
               "• Verify that the platform is FSCA-licensed\n"
               "• Never share personal info till you verify the investment's legitimacy\n"
               "• Be wary of promises of high returns with no risks",
    ),
    NotificationItem(
      title: "Get tips to Slam the Scams",
      subtitle: "Visitor opened new ticket",
      date: DateTime(2022, 11, 16),
      daysAgo: "5 days ago",
      content: "Scammers are more active on social media, tricking people into Ponzi or pyramid schemes and crypto scams with promises of quick, high returns. They might disappear as soon as you've paid over your money.\n\n"
               "Avoid these scams:\n"
               "• Don’t invest with people contacting you on social media\n"
               "• Research and stick to what you know\n"
               "• Verify that the platform is FSCA-licensed\n"
               "• Never share personal info till you verify the investment's legitimacy\n"
               "• Be wary of promises of high returns with no risks",
      imageAsset: 'assets/images/investment_scam.png',    
    ),
    NotificationItem(
      title: "New names for 2 products",
      subtitle: "Conversation assigned",
      date: DateTime(2022, 11, 16),
      daysAgo: "5 days ago",
      content: "Scammers are more active on social media, tricking people into Ponzi or pyramid schemes and crypto scams with promises of quick, high returns. They might disappear as soon as you've paid over your money.\n\n"
               "Avoid these scams:\n"
               "• Don’t invest with people contacting you on social media\n"
               "• Research and stick to what you know\n"
               "• Verify that the platform is FSCA-licensed\n"
               "• Never share personal info till you verify the investment's legitimacy\n"
               "• Be wary of promises of high returns with no risks",
      imageAsset: 'assets/images/investment_scam.png',    
    ),
    NotificationItem(
      title: "Hello",
      subtitle: "Fake apps scam alert",
      date: DateTime(2022, 11, 16),
      daysAgo: "5 days ago",
      content: "Scammers are more active on social media, tricking people into Ponzi or pyramid schemes and crypto scams with promises of quick, high returns. They might disappear as soon as you've paid over your money.\n\n"
               "Avoid these scams:\n"
               "• Don’t invest with people contacting you on social media\n"
               "• Research and stick to what you know\n"
               "• Verify that the platform is FSCA-licensed\n"
               "• Never share personal info till you verify the investment's legitimacy\n"
               "• Be wary of promises of high returns with no risks",
    ),
    NotificationItem(
      title: "Learn to #SlamTheScam",
      subtitle: "Visitor opened new ticket",
      date: DateTime(2022, 11, 16),
      daysAgo: "5 days ago",
      content: "Scammers are more active on social media, tricking people into Ponzi or pyramid schemes and crypto scams with promises of quick, high returns. They might disappear as soon as you've paid over your money.\n\n"
               "Avoid these scams:\n"
               "• Don’t invest with people contacting you on social media\n"
               "• Research and stick to what you know\n"
               "• Verify that the platform is FSCA-licensed\n"
               "• Never share personal info till you verify the investment's legitimacy\n"
               "• Be wary of promises of high returns with no risks",
    ),
    NotificationItem(
      title: "Don't get caught by scammers",
      subtitle: "Conversation assigned",
      date: DateTime(2022, 11, 9),
      daysAgo: "12 days ago",
      content: "Scammers are more active on social media, tricking people into Ponzi or pyramid schemes and crypto scams with promises of quick, high returns. They might disappear as soon as you've paid over your money.\n\n"
               "Avoid these scams:\n"
               "• Don’t invest with people contacting you on social media\n"
               "• Research and stick to what you know\n"
               "• Verify that the platform is FSCA-licensed\n"
               "• Never share personal info till you verify the investment's legitimacy\n"
               "• Be wary of promises of high returns with no risks",
      imageAsset: 'assets/images/investment_scam.png',    
    ),
    NotificationItem(
      title: "New! Get 50% off Showmax",
      subtitle: "Conversation assigned",
      date: DateTime(2022, 11, 9),
      daysAgo: "12 days ago",
      content: "Scammers are more active on social media, tricking people into Ponzi or pyramid schemes and crypto scams with promises of quick, high returns. They might disappear as soon as you've paid over your money.\n\n"
               "Avoid these scams:\n"
               "• Don’t invest with people contacting you on social media\n"
               "• Research and stick to what you know\n"
               "• Verify that the platform is FSCA-licensed\n"
               "• Never share personal info till you verify the investment's legitimacy\n"
               "• Be wary of promises of high returns with no risks",
    ),
    
    NotificationItem(
      title: "More convenience on our app",
      subtitle: "Visitor opened new ticket",
      date: DateTime(2022, 11, 16),
      daysAgo: "5 days ago",
      content: "Scammers are more active on social media, tricking people into Ponzi or pyramid schemes and crypto scams with promises of quick, high returns. They might disappear as soon as you've paid over your money.\n\n"
               "Avoid these scams:\n"
               "• Don’t invest with people contacting you on social media\n"
               "• Research and stick to what you know\n"
               "• Verify that the platform is FSCA-licensed\n"
               "• Never share personal info till you verify the investment's legitimacy\n"
               "• Be wary of promises of high returns with no risks",
    ),
    NotificationItem(
      title: "Manage your limits on our app",
      subtitle: "Conversation assigned",
      date: DateTime(2022, 11, 9),
      daysAgo: "12 days ago",
      content: "Scammers are more active on social media, tricking people into Ponzi or pyramid schemes and crypto scams with promises of quick, high returns. They might disappear as soon as you've paid over your money.\n\n"
               "Avoid these scams:\n"
               "• Don’t invest with people contacting you on social media\n"
               "• Research and stick to what you know\n"
               "• Verify that the platform is FSCA-licensed\n"
               "• Never share personal info till you verify the investment's legitimacy\n"
               "• Be wary of promises of high returns with no risks",
      imageAsset: 'assets/images/investment_scam.png',    
    ),
    NotificationItem(
      title: "Safe online payments with PayWave.",
      subtitle: "Conversation assigned",
      date: DateTime(2022, 11, 9),
      daysAgo: "12 days ago",
      content: "Scammers are more active on social media, tricking people into Ponzi or pyramid schemes and crypto scams with promises of quick, high returns. They might disappear as soon as you've paid over your money.\n\n"
               "Avoid these scams:\n"
               "• Don’t invest with people contacting you on social media\n"
               "• Research and stick to what you know\n"
               "• Verify that the platform is FSCA-licensed\n"
               "• Never share personal info till you verify the investment's legitimacy\n"
               "• Be wary of promises of high returns with no risks",
      imageAsset: 'assets/images/investment_scam.png',    
    ),
  ];








// Account Info
const String userName = 'Naledi Franci';
const String balance = 'R143,227.31';
const String userProfile = 'assets/images/anil.png';



// Trendig coins
const String selectionOption1 = 'Naledi Franci';
const String selectionOption2 = 'R143,227.31';
  
final List<Map<String, String>> beneficiaries = [
    {
      'initials': 'TS',
      'name': 'TJ',
      'lastPaid': '26 Dec 2024 09:45',
    },
    {
      'initials': 'M',
      'name': 'Mamello',
      'lastPaid': '07 Nov 2024 13:26',
    },
    {
      'initials': 'TD',
      'name': 'THE DON',
      'lastPaid': '15 Jul 2024 20:01',
    },
    {
      'initials': 'T',
      'name': 'THATO',
      'lastPaid': '03 Jun 2024 15:53',
    },
    {
      'initials': 'C',
      'name': 'Chief',
      'lastPaid': '02 Jun 2024 19:05',
    },
    {
      'initials': 'C',
      'name': 'Clougne',
      'lastPaid': '30 Apr 2024 10:47',
    },
  ];