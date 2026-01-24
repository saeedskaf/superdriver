import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:superdriver/domain/bloc/navigation/navigation_bloc.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';

import 'cart_screen.dart';
import 'chat_screen.dart';
import 'home_screen.dart';
import 'orders_screen.dart';
import 'profile/profile_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NavigationBloc(),
      child: const MainScreenContent(),
    );
  }
}

class MainScreenContent extends StatelessWidget {
  const MainScreenContent({super.key});

  static const List<Widget> _screens = [
    HomeScreen(),
    CartScreen(),
    ChatScreen(),
    OrdersScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return Scaffold(
          extendBody: true,
          body: _screens[state.selectedIndex],
          bottomNavigationBar: const ModernBottomNavBar(),
        );
      },
    );
  }
}

class ModernBottomNavBar extends StatelessWidget {
  const ModernBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              // Main Navigation Container
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.white.withOpacity(0.95)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: ColorsCustom.grey200.withOpacity(0.6),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                      spreadRadius: -5,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      icon: Icons.home_rounded,
                      label: l10n.homeScreen,
                      isSelected: state.selectedIndex == 0,
                      onTap: () => _navigateTo(context, 0),
                    ),
                    _NavItem(
                      icon: Icons.shopping_bag_rounded,
                      label: l10n.cart,
                      isSelected: state.selectedIndex == 1,
                      onTap: () => _navigateTo(context, 1),
                    ),
                    const SizedBox(width: 56),
                    _NavItem(
                      icon: Icons.receipt_long_rounded,
                      label: l10n.orders,
                      isSelected: state.selectedIndex == 3,
                      onTap: () => _navigateTo(context, 3),
                    ),
                    _NavItem(
                      icon: Icons.person_rounded,
                      label: l10n.profile,
                      isSelected: state.selectedIndex == 4,
                      onTap: () => _navigateTo(context, 4),
                    ),
                  ],
                ),
              ),

              // Floating Center Button
              Positioned(
                top: -20,
                child: _FloatingCenterButton(
                  onTap: () => _navigateTo(context, 2),
                  isSelected: state.selectedIndex == 2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateTo(BuildContext context, int index) {
    context.read<NavigationBloc>().add(NavigateToTab(index));
  }
}

class _FloatingCenterButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isSelected;

  const _FloatingCenterButton({required this.onTap, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.elasticOut,
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ColorsCustom.primary,
              ColorsCustom.primary.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: ColorsCustom.primary.withOpacity(0.4),
              blurRadius: 24,
              offset: const Offset(0, 12),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: ColorsCustom.primary.withOpacity(0.2),
              blurRadius: 40,
              offset: const Offset(0, 20),
              spreadRadius: 4,
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
          ),
          child: AnimatedRotation(
            duration: const Duration(milliseconds: 400),
            turns: isSelected ? 0.125 : 0,
            child: Icon(
              isSelected ? Icons.close_rounded : Icons.add_rounded,
              size: 32,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
        tween: Tween(begin: 0, end: isSelected ? 1 : 0),
        builder: (context, value, child) {
          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: 12 + (4 * value),
              vertical: 8,
            ),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        ColorsCustom.primary.withOpacity(0.15),
                        ColorsCustom.primary.withOpacity(0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              borderRadius: BorderRadius.circular(20),
              border: isSelected
                  ? Border.all(
                      color: ColorsCustom.primary.withOpacity(0.2),
                      width: 1,
                    )
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  scale: 1 + (0.1 * value),
                  child: Icon(
                    icon,
                    size: 26,
                    color: Color.lerp(
                      ColorsCustom.textSecondary,
                      ColorsCustom.primary,
                      value,
                    ),
                  ),
                ),
                SizedBox(height: 4 + (2 * value)),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 400),
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: Color.lerp(
                      ColorsCustom.textSecondary,
                      ColorsCustom.primary,
                      value,
                    ),
                    letterSpacing: isSelected ? 0.5 : 0.2,
                  ),
                  child: Text(label),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
