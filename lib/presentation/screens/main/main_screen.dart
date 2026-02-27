import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:superdriver/domain/bloc/auth/auth_bloc.dart';
import 'package:superdriver/domain/bloc/navigation/navigation_bloc.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/components/btn_custom.dart';
import 'package:superdriver/presentation/components/text_custom.dart';
import 'package:superdriver/presentation/screens/auth/login_screen.dart';
import 'package:superdriver/presentation/screens/main/home/home_screen.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';

import 'cart_screen.dart';
import 'chat_screen.dart';
import 'orders_screen.dart';
import 'profile/profile_screen.dart';

// ============================================
// MAIN SCREEN
// ============================================

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NavigationBloc(),
      child: const _MainScreenContent(),
    );
  }
}

class _MainScreenContent extends StatefulWidget {
  const _MainScreenContent();

  @override
  State<_MainScreenContent> createState() => _MainScreenContentState();
}

class _MainScreenContentState extends State<_MainScreenContent> {
  final _cartScreenKey = GlobalKey<CartScreenState>();

  late List<Widget> _screens;

  /// Tabs that require authentication (Orders=1, Chat=2, Cart=3, Profile=4)
  static const _authRequiredTabs = {1, 2, 3, 4};

  @override
  void initState() {
    super.initState();
    _buildScreens();
  }

  void _buildScreens() {
    final isAuth = context.read<AuthBloc>().state is AuthAuthenticated;
    _screens = [
      const HomeScreen(),
      isAuth ? const OrdersScreen() : const _AuthPlaceholder(),
      isAuth ? const ChatScreen() : const _AuthPlaceholder(),
      isAuth
          ? CartScreen(key: _cartScreenKey, onNavigateToHome: _navigateToHome)
          : const _AuthPlaceholder(),
      isAuth ? const ProfileScreen() : const _AuthPlaceholder(),
    ];
  }

  bool get _isAuthenticated {
    return context.read<AuthBloc>().state is AuthAuthenticated;
  }

  void _navigateToHome() {
    context.read<NavigationBloc>().add(const NavigateToTab(0));
  }

  void _onTabSelected(int index) {
    // If guest taps a protected tab → show login prompt
    if (_authRequiredTabs.contains(index) && !_isAuthenticated) {
      _showLoginRequiredSheet();
      return;
    }
    context.read<NavigationBloc>().add(NavigateToTab(index));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        // Rebuild screens when auth state changes (e.g. after login)
        if (authState is AuthAuthenticated ||
            authState is AuthUnauthenticated) {
          setState(() => _buildScreens());
          // If logged out, go back to home
          if (authState is AuthUnauthenticated) {
            context.read<NavigationBloc>().add(const NavigateToTab(0));
          }
        }
      },
      child: BlocConsumer<NavigationBloc, NavigationState>(
        listener: (context, state) {
          if (state.selectedIndex == 3) {
            _refreshCartIfNeeded();
          }
        },
        builder: (context, state) {
          return Scaffold(
            extendBody: true,
            body: IndexedStack(index: state.selectedIndex, children: _screens),
            bottomNavigationBar: _BottomNavBar(onTabSelected: _onTabSelected),
          );
        },
      ),
    );
  }

  void _refreshCartIfNeeded() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cartScreenKey.currentState?.loadCarts();
    });
  }

  // ── Login required bottom sheet ──

  void _showLoginRequiredSheet() {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: const BoxDecoration(
          color: ColorsCustom.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ColorsCustom.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: ColorsCustom.warningBg,
                shape: BoxShape.circle,
                border: Border.all(color: ColorsCustom.warning.withAlpha(77)),
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                size: 36,
                color: ColorsCustom.warning,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            TextCustom(
              text: l10n.loginRequired,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ColorsCustom.textPrimary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Subtitle
            TextCustom(
              text: l10n.loginRequiredMessage,
              fontSize: 14,
              color: ColorsCustom.textSecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Login button
            ButtonCustom.primary(
              text: l10n.login,
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
            const SizedBox(height: 12),

            // Continue browsing
            ButtonCustom.secondary(
              text: l10n.continueBrowsing,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// AUTH PLACEHOLDER (for guest mode)
// ============================================

/// Empty lightweight widget shown in IndexedStack for auth-required tabs
/// when user is not logged in. Prevents those screens from building
/// and making API calls.
class _AuthPlaceholder extends StatelessWidget {
  const _AuthPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

// ============================================
// BOTTOM NAVIGATION BAR
// ============================================

class _BottomNavBar extends StatelessWidget {
  final ValueChanged<int> onTabSelected;

  const _BottomNavBar({required this.onTabSelected});

  static const double _barHeight = 65;
  static const double _logoSize = 100;
  static const double _logoOverhang = 25;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomPadding = 20.0;

    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return SizedBox(
          height: _barHeight + bottomPadding + _logoOverhang,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ── Bar ──
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: _barHeight + bottomPadding,
                  padding: EdgeInsets.fromLTRB(12, 8, 12, 8 + bottomPadding),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(20),
                        blurRadius: 12,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _NavItem(
                        assetIcon: 'assets/icons/nav_home.png',
                        label: l10n.homeScreen,
                        isSelected: state.selectedIndex == 0,
                        onTap: () => onTabSelected(0),
                      ),
                      _NavItem(
                        assetIcon: 'assets/icons/nav_orders.png',
                        label: l10n.myOrders,
                        isSelected: state.selectedIndex == 1,
                        onTap: () => onTabSelected(1),
                      ),
                      const SizedBox(width: 100),
                      _NavItem(
                        assetIcon: 'assets/icons/nav_cart.png',
                        label: l10n.cart,
                        isSelected: state.selectedIndex == 3,
                        onTap: () => onTabSelected(3),
                      ),
                      _NavItem(
                        assetIcon: 'assets/icons/nav_profile.png',
                        label: l10n.profile,
                        isSelected: state.selectedIndex == 4,
                        onTap: () => onTabSelected(4),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Center logo ──
              Positioned(
                bottom: _barHeight + bottomPadding - _logoSize + _logoOverhang,
                left: 0,
                right: 0,
                child: Center(
                  child: _CenterLogo(
                    size: _logoSize,
                    isSelected: state.selectedIndex == 2,
                    onTap: () => onTabSelected(2),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================
// CENTER LOGO — spin + fire particles
// ============================================

class _CenterLogo extends StatefulWidget {
  final double size;
  final VoidCallback onTap;
  final bool isSelected;

  const _CenterLogo({
    required this.size,
    required this.onTap,
    required this.isSelected,
  });

  @override
  State<_CenterLogo> createState() => _CenterLogoState();
}

class _CenterLogoState extends State<_CenterLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spinCtrl;

  @override
  void initState() {
    super.initState();
    _spinCtrl = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _spinCtrl.dispose();
    super.dispose();
  }

  void _onTap() {
    _spinCtrl.forward(from: 0.0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _spinCtrl,
        builder: (_, __) {
          final t = _spinCtrl.value;
          return SizedBox(
            width: widget.size + 40,
            height: widget.size + 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (t > 0 && t < 1)
                  CustomPaint(
                    size: Size(widget.size + 40, widget.size + 40),
                    painter: _FirePainter(
                      progress: t,
                      baseColor: ColorsCustom.primary,
                    ),
                  ),
                Transform.rotate(
                  angle: t * 2 * pi,
                  child: SizedBox(
                    width: widget.size,
                    height: widget.size,
                    child: Image.asset(
                      isAr
                          ? 'assets/icons/nav_logo_ar.png'
                          : 'assets/icons/nav_logo_en.png',
                      width: widget.size,
                      height: widget.size,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FirePainter extends CustomPainter {
  final double progress;
  final Color baseColor;

  _FirePainter({required this.progress, required this.baseColor});

  static const int _particleCount = 10;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width / 2 - 20;
    final rng = [0.0, 0.62, 1.25, 1.88, 2.51, 3.14, 3.77, 4.40, 5.03, 5.65];

    final colors = [
      const Color(0xFFFFD54F),
      const Color(0xFFFF9800),
      const Color(0xFFFF5722),
      const Color(0xFFFF6D00),
      baseColor,
    ];

    for (int i = 0; i < _particleCount; i++) {
      final offset = i * 0.06;
      final particleT = (progress - offset).clamp(0.0, 1.0);
      if (particleT <= 0) continue;

      final angle = rng[i] + progress * 2 * pi;
      final distance = baseRadius + particleT * 22;
      final px = center.dx + distance * cos(angle);
      final py = center.dy + distance * sin(angle);

      final alpha = ((1.0 - particleT) * 220).round().clamp(0, 255);
      final radius = (3.5 - particleT * 2.5).clamp(0.5, 4.0);

      final color = colors[i % colors.length].withAlpha(alpha);
      final paint = Paint()
        ..color = color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.8);

      canvas.drawCircle(Offset(px, py), radius, paint);

      if (particleT > 0.15) {
        final trailAngle = angle - 0.3;
        final trailDist = distance - 6;
        final tx = center.dx + trailDist * cos(trailAngle);
        final ty = center.dy + trailDist * sin(trailAngle);
        final trailAlpha = (alpha * 0.5).round().clamp(0, 255);
        final trailPaint = Paint()
          ..color = colors[(i + 2) % colors.length].withAlpha(trailAlpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
        canvas.drawCircle(Offset(tx, ty), radius * 0.6, trailPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_FirePainter old) => progress != old.progress;
}

// ============================================
// NAV ITEM
// ============================================

class _NavItem extends StatelessWidget {
  final String assetIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.assetIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? ColorsCustom.primary : ColorsCustom.textHint;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(assetIcon, width: 22, height: 22, color: color),
              const SizedBox(height: 3),
              TextCustom(
                text: label,
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
