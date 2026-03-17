import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:superdriver/domain/bloc/auth/auth_bloc.dart';
import 'package:superdriver/domain/bloc/chat/chat_unread_cubit.dart';
import 'package:superdriver/domain/bloc/home/home_bloc.dart';
import 'package:superdriver/domain/bloc/navigation/navigation_bloc.dart';
import 'package:superdriver/domain/bloc/orders/orders_bloc.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/components/custom_button.dart';
import 'package:superdriver/presentation/components/custom_text.dart';
import 'package:superdriver/presentation/screens/auth/login_screen.dart';
import 'package:superdriver/presentation/screens/main/home/home_screen.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';

import 'cart_screen.dart';
import 'chat/chat_screen.dart';
import 'orders_screen.dart';
import 'profile/profile_screen.dart';

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
  final _homeScreenKey = GlobalKey<HomeScreenState>();
  final _ordersScreenKey = GlobalKey<OrdersScreenState>();
  final _cartScreenKey = GlobalKey<CartScreenState>();
  final _profileScreenKey = GlobalKey<ProfileScreenState>();

  late List<Widget> _screens;
  late bool _lastAuthValue;

  // tabs that need auth
  static const _authRequiredTabs = {1, 2, 3, 4};

  @override
  void initState() {
    super.initState();
    _lastAuthValue = _isAuthenticated;
    _buildScreens();
  }

  void _buildScreens() {
    final isAuth = context.read<AuthBloc>().state is AuthAuthenticated;
    _screens = [
      HomeScreen(key: _homeScreenKey),
      isAuth ? OrdersScreen(key: _ordersScreenKey) : const _AuthPlaceholder(),
      isAuth ? const ChatScreen() : const _AuthPlaceholder(),
      isAuth
          ? CartScreen(key: _cartScreenKey, onNavigateToHome: _navigateToHome)
          : const _AuthPlaceholder(),
      isAuth
          ? ProfileScreen(key: _profileScreenKey)
          : const _AuthPlaceholder(),
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

    final currentIndex = context.read<NavigationBloc>().state.selectedIndex;

    if (currentIndex == index) {
      // Same tab re-selected → scroll to top + refresh
      HapticFeedback.lightImpact();
      _onSameTabReSelected(index);
      return;
    }

    HapticFeedback.selectionClick();
    context.read<NavigationBloc>().add(NavigateToTab(index));
  }

  void _onSameTabReSelected(int index) {
    switch (index) {
      case 0:
        _homeScreenKey.currentState?.scrollToTopAndRefresh();
        break;
      case 1:
        _ordersScreenKey.currentState?.scrollToTopAndRefresh();
        break;
      case 3:
        _cartScreenKey.currentState?.loadCarts();
        break;
      case 4:
        _profileScreenKey.currentState?.scrollToTopAndRefresh();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          previous.runtimeType != current.runtimeType,
      listener: (context, authState) {
        if (authState is AuthAuthenticated ||
            authState is AuthUnauthenticated) {
          final isAuthNow = authState is AuthAuthenticated;
          if (_lastAuthValue == isAuthNow) return;
          _lastAuthValue = isAuthNow;
          setState(() => _buildScreens());
          if (isAuthNow) {
            context.read<HomeBloc>().add(const HomeUserLoggedIn());
          } else {
            context.read<HomeBloc>().add(const HomeUserLoggedOut());
            context.read<NavigationBloc>().add(const NavigateToTab(0));
          }
        }
      },
      child: BlocConsumer<NavigationBloc, NavigationState>(
        listener: (context, state) {
          if (state.selectedIndex == 1) {
            _refreshOrdersIfNeeded();
          }
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

  void _refreshOrdersIfNeeded() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersBloc>().add(const OrdersRefreshRequested());
    });
  }

  void _refreshCartIfNeeded() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cartScreenKey.currentState?.loadCarts();
    });
  }

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
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ColorsCustom.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

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

            TextCustom(
              text: l10n.loginRequired,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ColorsCustom.textPrimary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            TextCustom(
              text: l10n.loginRequiredMessage,
              fontSize: 14,
              color: ColorsCustom.textSecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

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

// empty placeholder for guest mode
class _AuthPlaceholder extends StatelessWidget {
  const _AuthPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _BottomNavBar extends StatelessWidget {
  final ValueChanged<int> onTabSelected;

  const _BottomNavBar({required this.onTabSelected});

  static const double _barHeight = 65;
  static const double _logoSize = 100;
  static const double _logoOverhang = 25;
  static const double _bottomPadding = 20;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return SizedBox(
          height: _barHeight + _bottomPadding + _logoOverhang,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: _barHeight + _bottomPadding,
                  padding: const EdgeInsets.fromLTRB(
                    12,
                    8,
                    12,
                    8 + _bottomPadding,
                  ),
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

              Positioned(
                bottom: _barHeight + _bottomPadding - _logoSize + _logoOverhang,
                left: 0,
                right: 0,
                child: Center(
                  child: BlocBuilder<ChatUnreadCubit, int>(
                    builder: (context, unreadCount) {
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          _CenterLogo(
                            size: _logoSize,
                            isSelected: state.selectedIndex == 2,
                            onTap: () => onTabSelected(2),
                          ),
                          if (unreadCount > 0)
                            Positioned(
                              top: 35,
                              right: 35,
                              child: _UnreadBadge(count: unreadCount),
                            ),
                        ],
                      );
                    },
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
  static const String _legacyBgAr = 'assets/icons/nav_logo_ar.png';
  static const String _legacyBgEn = 'assets/icons/nav_logo_en.png';
  static const String _legacyCenterIcon = 'assets/icons/nav_app_logo.png';
  static const double _centerBgScale = 0.92;
  static const double _centerIconScale = 0.4;
  static const double _centerIconYOffset = -10;
  static const double _centerLabelYOffset = 15;
  static const double _tapScaleBoost = 0.08;
  static const double _tapLiftHeight = -6;
  static const double _rotationWobble = 0.08;

  @override
  void initState() {
    super.initState();
    _spinCtrl = AnimationController(
      duration: const Duration(milliseconds: 650),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _spinCtrl.dispose();
    super.dispose();
  }

  void _onTap() {
    if (_spinCtrl.isAnimating) {
      _spinCtrl.stop();
    }
    _spinCtrl.forward(from: 0.0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final centerBgAsset = isAr
        ? 'assets/icons/nav_center_bg_ar.png'
        : 'assets/icons/nav_center_bg_en.png';
    final legacyBgAsset = isAr ? _legacyBgAr : _legacyBgEn;
    final centerLabelColor = widget.isSelected
        ? ColorsCustom.primary
        : ColorsCustom.textHint;
    final centerBgSize = widget.size * _centerBgScale;
    final centerIconSize = widget.size * _centerIconScale;
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _spinCtrl,
        builder: (context, child) {
          final rawT = _spinCtrl.value;
          final t = Curves.easeInOutCubic.transform(rawT);
          final pulse = sin(rawT * pi);
          final scale = 1.0 + _tapScaleBoost * pulse;
          final lift = _tapLiftHeight * pulse;
          final glowAlpha = ((1.0 - rawT) * 110).round().clamp(0, 110);
          final rotationAngle =
              (t * 2 * pi) + (sin(rawT * pi) * _rotationWobble);
          return SizedBox(
            width: widget.size + 40,
            height: widget.size + 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (rawT > 0 && rawT < 1)
                  CustomPaint(
                    size: Size(widget.size + 40, widget.size + 40),
                    painter: _FirePainter(
                      progress: t,
                      baseColor: ColorsCustom.primary,
                    ),
                  ),
                Transform.translate(
                  offset: Offset(0, lift),
                  child: Transform.scale(
                    scale: scale,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (rawT > 0 && rawT < 1)
                          Container(
                            width: centerBgSize * 0.9,
                            height: centerBgSize * 0.9,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: ColorsCustom.primary.withAlpha(
                                    glowAlpha,
                                  ),
                                  blurRadius: 24,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        Transform.rotate(
                          angle: rotationAngle,
                          child: SizedBox(
                            width: widget.size,
                            height: widget.size,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.asset(
                                  centerBgAsset,
                                  width: centerBgSize,
                                  height: centerBgSize,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.asset(
                                        legacyBgAsset,
                                        width: centerBgSize,
                                        height: centerBgSize,
                                        fit: BoxFit.contain,
                                      ),
                                ),
                                Transform.translate(
                                  offset: const Offset(0, _centerIconYOffset),
                                  child: Image.asset(
                                    'assets/icons/nav_center_icon.png',
                                    width: centerIconSize,
                                    height: centerIconSize,
                                    fit: BoxFit.contain,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Image.asset(
                                              _legacyCenterIcon,
                                              width: centerIconSize,
                                              height: centerIconSize,
                                              fit: BoxFit.contain,
                                            ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(0, _centerLabelYOffset),
                          child: TextCustom(
                            text: l10n.orderCenterTab,
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: centerLabelColor,
                          ),
                        ),
                      ],
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

// ─────────────────────────────────────────────────────────────────────────────
// Unread chat badge with pulse animation
// ─────────────────────────────────────────────────────────────────────────────

class _UnreadBadge extends StatefulWidget {
  final int count;

  const _UnreadBadge({required this.count});

  @override
  State<_UnreadBadge> createState() => _UnreadBadgeState();
}

class _UnreadBadgeState extends State<_UnreadBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.count > 99 ? '99+' : '${widget.count}';

    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnim.value, child: child);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(
          color: ColorsCustom.error,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: ColorsCustom.error.withAlpha(100),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),
        ),
      ),
    );
  }
}
