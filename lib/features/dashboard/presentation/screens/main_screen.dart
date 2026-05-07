import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_components.dart';
import 'dashboard_screen.dart';
import '../../../../features/wallet/presentation/screens/wallet_screen.dart';
import '../../../../features/transactions/presentation/screens/transactions_screen.dart';
import '../../../../features/profile/presentation/screens/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const WalletScreen(),
    const TransactionsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= 800;

          if (isTablet) {
            return Row(
              children: [
                SizedBox(
                  width: 120,
                  child: GlassSideNavBar(
                    currentIndex: _currentIndex,
                    onTap: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: IndexedStack(index: _currentIndex, children: _screens),
                ),
              ],
            );
          }

          // Mobile Layout
          return Stack(
            children: [
              IndexedStack(index: _currentIndex, children: _screens),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: GlassBottomNavBar(
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
