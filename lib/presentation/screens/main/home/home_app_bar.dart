import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:superdriver/domain/bloc/notification/notification_bloc.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/components/custom_text.dart';
import 'package:superdriver/presentation/screens/main/home/address_selector.dart';
import 'package:superdriver/presentation/screens/notifications/notifications_screen.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';

/// Simple header: bg image with fade + address row + search bar straddling edge.
class HomeHeader extends StatelessWidget {
  final DeliveryLocationResult? selectedLocation;
  final VoidCallback onLocationTap;
  final VoidCallback? onSearchTap;

  const HomeHeader({
    super.key,
    this.selectedLocation,
    required this.onLocationTap,
    this.onSearchTap,
  });

  // Search bar height — half sits on image, half below
  static const double _searchBarHeight = 48.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final topPadding = MediaQuery.of(context).padding.top;
    final hasLocation =
        selectedLocation != null && selectedLocation!.displayName.isNotEmpty;

    // Image area: status bar + top padding + address row + gap
    final imageHeight = topPadding + 12 + 44 + 14 + (_searchBarHeight / 2);

    return SizedBox(
      // Total = image area + bottom half of search bar
      height: imageHeight + (_searchBarHeight / 2),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            height: imageHeight,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/icons/home_header_background.png',
                  fit: BoxFit.cover,
                ),
                PositionedDirectional(
                  top: -28,
                  end: -18,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withAlpha(30),
                    ),
                  ),
                ),
                PositionedDirectional(
                  top: 44,
                  start: -32,
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ColorsCustom.secondary.withAlpha(20),
                    ),
                  ),
                ),
                // Gradient fade at bottom
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 50,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          ColorsCustom.background.withAlpha(0),
                          ColorsCustom.background,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: topPadding + 12,
            left: 16,
            right: 16,
            child: Row(
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/icons/logo_app.png',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: onLocationTap,
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        Flexible(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextCustom(
                                text: l10n.deliverTo,
                                fontSize: 11,
                                color: ColorsCustom.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                              const SizedBox(height: 2),
                              TextCustom(
                                text: hasLocation
                                    ? selectedLocation!.displayName
                                    : l10n.selectDeliveryAddress,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: ColorsCustom.textPrimary,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: ColorsCustom.primary,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Notification
                BlocBuilder<NotificationBloc, NotificationState>(
                  builder: (context, state) {
                    final count = state.unreadCount;
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<NotificationBloc>(),
                              child: const NotificationsScreen(),
                            ),
                          ),
                        );
                      },
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(190),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withAlpha(210),
                                  width: 0.8,
                                ),
                              ),
                              child: Center(
                                child: Image.asset(
                                  'assets/icons/notification_icon.png',
                                  width: 20,
                                  height: 20,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            if (count > 0)
                              Positioned(
                                top: -2,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: ColorsCustom.primary,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: ColorsCustom.surface,
                                      width: 1.5,
                                    ),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 18,
                                    minHeight: 18,
                                  ),
                                  child: Center(
                                    child: Text(
                                      count > 99 ? '99+' : '$count',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          Positioned(
            left: 16,
            right: 16,
            top: imageHeight - (_searchBarHeight / 2),
            child: GestureDetector(
              onTap: onSearchTap,
              child: Container(
                height: _searchBarHeight,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: ColorsCustom.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: ColorsCustom.border, width: 0.8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(16),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: ColorsCustom.primarySoft,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(
                        Icons.search_rounded,
                        size: 18,
                        color: ColorsCustom.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextCustom(
                        text: l10n.searchRestaurants,
                        fontSize: 12,
                        color: ColorsCustom.textHint,
                      ),
                    ),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: ColorsCustom.secondarySoft,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        size: 18,
                        color: ColorsCustom.secondaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
