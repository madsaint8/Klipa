import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String get fileName =>
      kReleaseMode ? '.env.production' : '.env.development';

  static Future<void> load() => dotenv.load(fileName: fileName);

  static String get alchemySepoliaRpcUrl => _get('ALCHEMY_SEPOLIA_RPC_URL');
  static String get supabaseDbUrl => _get('SUPABASE_DB_URL');
  static String get supabaseDbAnonKey => _get('SUPABASE_DB_ANON_KEY');
  static String get coingeckoApiUrl => _get('COINGECKO_API_URL');

  static String _get(String key) {
    final value = dotenv.maybeGet(key)?.trim() ?? '';
    if (value.isEmpty) {
      debugPrint('Environment: "$key" is missing or empty in $fileName');
    }
    return value;
  }
}