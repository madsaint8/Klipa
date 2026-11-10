import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/routes/app_routes.dart';
import 'config/theme/app_theme.dart';
import 'core/auth/controllers/auth_controller.dart';
import 'config/theme/constants/text_strings.dart';
import 'data/models/environment/environment.dart';
import 'providers/navigation/navigation_provider.dart';
import 'services/auth/auth_gate.dart';
import 'services/wallet/wallet_services.dart';

Widget welcome = const AuthGate();

Future<void> main() async {
  // first: loading the .env asset requires binding.
  WidgetsFlutterBinding.ensureInitialized();

  // Loads .env.production in release mode, .env.development otherwise.
  await Environment.load();

  final supabaseUrl = Environment.supabaseDbUrl;
  final supabaseAnonKey = Environment.supabaseDbAnonKey;

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw StateError(
      'Missing Supabase configuration. Check SUPABASE_DB_URL and '
      'SUPABASE_DB_ANON_KEY in ${Environment.fileName}.',
    );
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  await WalletService.instance.init();

  runApp(
    const ProviderScope(
      child: Klipa(),
    ),
  );
}

class Klipa extends ConsumerWidget {
  const Klipa({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navService = ref.read(navigationProvider);

    return ScreenUtilInit(
      designSize: const Size(375, 825),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthController()),
          ],
          child: MaterialApp(
            navigatorKey: navService.navigatorKey,
            debugShowCheckedModeBanner: false,
            title: AppTexts.appName,
            theme: AppTheme.lightTheme,
            initialRoute: AppRoutes.authWrapper,
            routes: AppRoutes.routes,
          ),
        );
      },
    );
  }
}