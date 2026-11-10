import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/wallet/wallet_provider.dart';
import '../../providers/user/user_profile_provider.dart'; 
import '../quick_service/quick_service.dart';
import 'widgets/action_buttons_row.dart';
import 'widgets/home_header.dart.dart';
import 'widgets/quick_send_section.dart';
import 'widgets/recent_transactions_section.dart';
import '../../common/widgets/crypto/trending_section.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool isVisible = true;

  void _toggleBalanceVisibility() {
    setState(() => isVisible = !isVisible);
  }

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(userProfileProvider);
    final accountAsync = ref.watch(walletAccountProvider);

    final mq = MediaQuery.of(context);
    final screenWidth = mq.size.width;
    final isTablet = screenWidth >= 600;
    final hPadding = isTablet ? screenWidth * 0.10 : 20.0;

    return Scaffold(
      backgroundColor: const Color(0xFF2196F3),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ================= HEADER =================
            Padding(
              padding: EdgeInsets.fromLTRB(hPadding, 16, hPadding, 0),
              child: Column(
                children: [
                  userProfileAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                    error: (_, __) => const Text(
                      "Failed to load user",
                      style: TextStyle(color: Colors.white),
                    ),
                    data: (user) {
                      final fullName = user?['full_name'] ?? 'User';
                      final avatar = user?['profile_pic'];

                      return HomeHeader(
                        fullName: fullName,
                        avatar: avatar,
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // ================= BALANCE =================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      accountAsync.when(
                        loading: () => const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        ),
                        error: (_, __) => const Text(
                          '— —',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        data: (info) => Text(
                          isVisible
                              ? 'R ${(info['balance'] as double).toStringAsFixed(2)}'
                              : 'R ******',
                          style: TextStyle(
                            fontSize: isTablet ? 34 : 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: IconButton(
                          onPressed: _toggleBalanceVisibility,
                          icon: Icon(
                            isVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  accountAsync.maybeWhen(
                    data: (info) => Text(
                      'Your balance (${info['currency'] ?? 'ZAR'})',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    orElse: () => const Text(
                      'Your balance (ZAR)',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ================= ACTION BUTTONS =================
                   ConstrainedBox(
                    constraints:  const BoxConstraints(maxWidth: 420),
                    child: const ActionButtonsRow(),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),

            // ================= WHITE CONTENT AREA =================
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                child: Container(
                  color: Colors.white,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          hPadding,
                          16,
                          hPadding,
                          mq.padding.bottom + 24,
                        ),
                        sliver: const SliverList(
                          delegate: SliverChildListDelegate.fixed([
                            TrendingSection(),
                            SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(padding: EdgeInsets.all(5)),
                                Text('Quick Send',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    )),
                              ],
                            ),
                            SizedBox(height: 12),
                            QuickSendSection(),
                            SizedBox(height: 10),
                            QuickService(),
                            SizedBox(height: 8),
                            RecentTransactionsSection(),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
