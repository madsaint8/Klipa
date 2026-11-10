import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../views/cards/debit_card.dart';
import '../../views/home_screen/home_screen.dart';
import '../../views/markets/market_screen.dart';
import '../../views/portfolio/portfolio_screen.dart';
import '../../views/scan_to_pay/scan_to _pay.dart';
//import '../../views/scan_to_pay/scan_to _pay.dart';

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  int currentTab = 0;
  final PageStorageBucket bucket = PageStorageBucket();
  //=====================================================
  // ---------- Default Screen  ----------
  //=====================================================
  Widget currentScreen = const HomeScreen(); 

  //=====================================================
  // ----------  NAV BUTTON  ----------
  //=====================================================
  Widget buildNavButton({
    required IconData icon,
    required String label,
    required int tabIndex,
    required Widget screen,
  }) {
    final isSelected = currentTab == tabIndex;

    return InkWell(
      //=====================================================
      // Remove splash / highlight
      //=====================================================
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        setState(() {
          currentScreen = screen;
          currentTab = tabIndex;
        });
      },
      child: SizedBox(
        width: 70,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: isSelected
                    ? Colors.blue
                    : const Color.fromARGB(255, 108, 107, 107)),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? Colors.blue
                    : const Color.fromARGB(255, 108, 107, 107),
              ),
            ),
          ],
        ),
      ),
    );
  }
  // ----------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(bucket: bucket, child: currentScreen),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ScanToPayScreen()),
        ),
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        child: const Icon(Iconsax.scan_barcode, color: Colors.white, size: 35),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      //==========================================================================
      // --------  BOTTOM BAR with transparent overlays --------
      //==========================================================================
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
        ),
        child: BottomAppBar(
          height: 69,
          elevation: 5,
          color: Colors.grey[100],
          shape: const CircularNotchedRectangle(),
          notchMargin: 7,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                buildNavButton(
                    icon: Iconsax.home_2,
                    label: 'Home',
                    tabIndex: 0,
                    screen: const HomeScreen()),
                buildNavButton(
                    icon: Iconsax.chart_2,
                    label: 'Markets',
                    tabIndex: 1,
                    screen: const MarketsScreen()),
              ]),
              Row(children: [
                buildNavButton(
                    icon: Iconsax.chart_34,
                    label: 'Portfolio',
                    tabIndex: 2,
                    screen: const PortfolioScreen()),
                buildNavButton(
                    icon: Iconsax.cards,
                    label: 'Cards',
                    tabIndex: 3,
                    screen: const CardScreen()),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
