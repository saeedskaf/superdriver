import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:superdriver/domain/bloc/notification/notification_bloc.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/components/text_custom.dart';
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

    // Image area: status bar + top padding + address row (40) + gap
    final imageHeight = topPadding + 12 + 40 + 12 + (_searchBarHeight / 2);

    return SizedBox(
      // Total = image area + bottom half of search bar
      height: imageHeight + (_searchBarHeight / 2),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Background image + gradient fade ──
          SizedBox(
            height: imageHeight,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset('assets/icons/home_header_bg.png', fit: BoxFit.cover),
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

          // ── Address row ──
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
                                fontSize: 12,
                                color: ColorsCustom.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                              const SizedBox(height: 1),
                              TextCustom(
                                text: hasLocation
                                    ? selectedLocation!.displayName
                                    : l10n.selectDeliveryAddress,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
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
                          color: ColorsCustom.textPrimary,
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
                                color: ColorsCustom.surface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: ColorsCustom.border,
                                  width: 0.5,
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

          // ── Search bar (straddles image bottom edge) ──
          Positioned(
            left: 16,
            right: 16,
            top: imageHeight - (_searchBarHeight / 2),
            child: GestureDetector(
              onTap: onSearchTap,
              child: Container(
                height: _searchBarHeight,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: ColorsCustom.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ColorsCustom.border, width: 0.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      size: 22,
                      color: ColorsCustom.textHint,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextCustom(
                        text: l10n.searchRestaurants,
                        fontSize: 14,
                        color: ColorsCustom.textHint,
                      ),
                    ),
                    const Icon(
                      Icons.tune_rounded,
                      size: 20,
                      color: ColorsCustom.primary,
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
