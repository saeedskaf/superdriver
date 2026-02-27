import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:superdriver/data/env/environment.dart';
import 'package:superdriver/domain/models/home_model.dart';
import 'package:superdriver/domain/models/restaurant_model.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/components/text_custom.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';

// ============================================================
// LOCALIZATION HELPERS
// ============================================================

String getLocaleCode(BuildContext context) =>
    Localizations.localeOf(context).languageCode;

bool isArabic(BuildContext context) => getLocaleCode(context) == 'ar';

String getLocalizedName(
  BuildContext context, {
  required String name,
  String? nameEn,
}) {
  if (getLocaleCode(context) == 'en' && nameEn != null && nameEn.isNotEmpty) {
    return nameEn;
  }
  return name;
}

String getLocalizedDescription(
  BuildContext context, {
  String? description,
  String? descriptionEn,
}) {
  if (getLocaleCode(context) == 'en' &&
      descriptionEn != null &&
      descriptionEn.isNotEmpty) {
    return descriptionEn;
  }
  return description ?? descriptionEn ?? '';
}

// ============================================================
// IMAGE HELPERS
// ============================================================

String getFullImageUrl(String? imagePath) {
  if (imagePath == null || imagePath.isEmpty) return '';
  if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
    return imagePath;
  }
  final cleanPath = imagePath.startsWith('/')
      ? imagePath.substring(1)
      : imagePath;
  return '${Environment.baseUrl}/$cleanPath';
}

// ============================================================
// NETWORK IMAGE
// ============================================================

class NetworkImg extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final IconData icon;
  final double iconSize;

  const NetworkImg({
    super.key,
    this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.icon = Icons.restaurant_rounded,
    this.iconSize = 32,
  });

  @override
  Widget build(BuildContext context) {
    final hasUrl = url != null && url!.isNotEmpty;
    return hasUrl
        ? CachedNetworkImage(
            imageUrl: url!,
            width: width,
            height: height,
            fit: fit,
            placeholder: (_, __) => _placeholder(),
            errorWidget: (_, __, ___) => _placeholder(),
          )
        : _placeholder();
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFF3F4F6),
      child: Center(
        child: Icon(icon, size: iconSize, color: const Color(0xFFD1D5DB)),
      ),
    );
  }
}

// ============================================================
// SECTION HEADER
// ============================================================

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAllTap;
  final bool showSeeAll;

  const SectionHeader({
    super.key,
    required this.title,
    this.onSeeAllTap,
    this.showSeeAll = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 22,
            decoration: BoxDecoration(
              color: ColorsCustom.primary,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextCustom(
              text: title,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: ColorsCustom.textPrimary,
            ),
          ),
          if (showSeeAll && onSeeAllTap != null)
            GestureDetector(
              onTap: onSeeAllTap,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextCustom(
                    text: l10n.seeAll,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: ColorsCustom.primary,
                  ),
                  const SizedBox(width: 4),
                  // Arrow always points forward (>)
                  // Arabic: > points left visually (correct for RTL)
                  // English: > points right visually (correct for LTR)
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: ColorsCustom.primary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// SECTION DIVIDER
// ============================================================

class SectionDivider extends StatelessWidget {
  const SectionDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      height: 1,
      color: ColorsCustom.border, // #E0E0E0
    );
  }
}

// ============================================================
// CATEGORY CARD
// ============================================================

class CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;

  const CategoryCard({super.key, required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = getLocalizedName(
      context,
      name: category.name,
      nameEn: category.nameEn,
    );
    final imageUrl = getFullImageUrl(category.image);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: ColorsCustom.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ColorsCustom.border, width: 0.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      width: 80,
                      height: 80,
                      placeholder: (_, __) => _catFallback(),
                      errorWidget: (_, __, ___) => _catFallback(),
                    )
                  : _catFallback(),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: TextCustom(
              text: name,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: ColorsCustom.textPrimary,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _catFallback() {
    return Container(
      color: const Color(0xFFF3F4F6),
      child: const Center(
        child: Icon(
          Icons.restaurant_rounded,
          size: 24,
          color: ColorsCustom.primary,
        ),
      ),
    );
  }
}

const double _kCoverH = 130.0;
const double _kLogoSz = 56.0;
const double _kLogoHalf = _kLogoSz / 2;
const double _kLogoInset = 14.0;
const double _kContentH = 85.0;

/// Exported so sections can reference it for ListView height.
const double kRestaurantCardH = _kCoverH + _kContentH; // 210

class RestaurantCard extends StatelessWidget {
  final RestaurantListItem restaurant;
  final VoidCallback onTap;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final name = getLocalizedName(
      context,
      name: restaurant.name,
      nameEn: restaurant.nameEn,
    );
    final logoUrl = getFullImageUrl(restaurant.logo);
    final coverUrl = getFullImageUrl(restaurant.coverImage);
    final isClosed = !restaurant.isCurrentlyOpen;
    final hasDiscount =
        restaurant.hasDiscount && (restaurant.currentDiscount ?? 0) > 0;
    final discount = (restaurant.currentDiscount ?? 0).toInt();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: kRestaurantCardH,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none, // logo overflows — must not clip
          children: [
            // ── Card body (clipped for rounded corners) ──
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                children: [
                  // Cover image
                  _CardCover(
                    coverUrl: coverUrl,
                    isClosed: isClosed,
                    hasDiscount: hasDiscount,
                    discount: discount,
                    isFreeDelivery: restaurant.isFreeDelivery,
                    l10n: l10n,
                  ),
                  // Content area (fills remaining height)
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: EdgeInsetsDirectional.fromSTEB(
                        14, // start
                        6,
                        _kLogoInset + _kLogoSz + 10, // end: after logo
                        10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name
                          TextCustom(
                            text: name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),

                          const Spacer(),
                          // Delivery info row
                          _DeliveryRow(restaurant: restaurant, l10n: l10n),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Overlapping logo (outside ClipRRect so it's not clipped) ──
            PositionedDirectional(
              end: _kLogoInset,
              top: _kCoverH - _kLogoHalf,
              child: _Logo(
                url: logoUrl,
                isCurrentlyOpen: restaurant.isCurrentlyOpen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// COVER IMAGE — tags for discount + free delivery only
// ============================================================

class _CardCover extends StatelessWidget {
  final String coverUrl;
  final bool isClosed;
  final bool hasDiscount;
  final int discount;
  final bool isFreeDelivery;
  final AppLocalizations l10n;

  const _CardCover({
    required this.coverUrl,
    required this.isClosed,
    required this.hasDiscount,
    required this.discount,
    required this.isFreeDelivery,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final hasTags = hasDiscount || isFreeDelivery;

    return SizedBox(
      height: _kCoverH,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image (grayscale when closed)
          ColorFiltered(
            colorFilter: isClosed
                ? const ColorFilter.matrix(<double>[
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0,
                    0,
                    0,
                    1,
                    0,
                  ])
                : const ColorFilter.mode(
                    Colors.transparent,
                    BlendMode.multiply,
                  ),
            child: NetworkImg(url: coverUrl, height: _kCoverH),
          ),

          // Bottom gradient
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 50,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withAlpha(45)],
                ),
              ),
            ),
          ),

          // Tags (top-start corner)
          if (hasTags)
            PositionedDirectional(
              top: 10,
              start: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasDiscount) ...[
                    _TagChip(
                      label: '${l10n.discount} $discount%',
                      bgColor: ColorsCustom.primaryLight,
                      textColor: Colors.white,
                      icon: Icons.local_offer_rounded,
                    ),
                    if (isFreeDelivery) const SizedBox(height: 6),
                  ],
                  if (isFreeDelivery)
                    _TagChip(
                      label: l10n.freeDelivery,
                      bgColor: ColorsCustom.secondaryLight,
                      textColor: ColorsCustom.warning,
                      icon: Icons.delivery_dining_rounded,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// TAG CHIP
// ============================================================

class _TagChip extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;
  final IconData? icon;

  const _TagChip({
    required this.label,
    required this.bgColor,
    this.textColor = Colors.white,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
          ],
          TextCustom(
            text: label,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DELIVERY ROW — preparation time + delivery fee (dot separated)
// Free delivery is NOT repeated here (shown as tag on cover).
// ============================================================

class _DeliveryRow extends StatelessWidget {
  final RestaurantListItem restaurant;
  final AppLocalizations l10n;

  const _DeliveryRow({required this.restaurant, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final hasTime = restaurant.deliveryTimeEstimate?.isNotEmpty ?? false;
    final fee = restaurant.deliveryFee;
    final showFee = fee != null && fee > 0;

    if (!hasTime && !showFee) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Preparation time
        if (hasTime) ...[
          const Icon(
            Icons.schedule_rounded,
            size: 13,
            color: Color(0xFF9CA3AF),
          ),
          const SizedBox(width: 3),
          TextCustom(
            text: '${restaurant.deliveryTimeEstimate!} ${l10n.minute}',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6B7280),
          ),
        ],

        // Dot separator
        if (hasTime && showFee)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: TextCustom(
              text: '·',
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: const Color(0xFFD1D5DB),
            ),
          ),

        // Delivery fee
        if (showFee) ...[
          const Icon(
            Icons.delivery_dining_rounded,
            size: 13,
            color: Color(0xFF9CA3AF),
          ),
          const SizedBox(width: 3),
          TextCustom(
            text: '${fee.toStringAsFixed(0)} ${l10n.currency}',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6B7280),
          ),
        ],
      ],
    );
  }
}

// ============================================================
// LOGO WITH STATUS DOT
//
// Positioned at END side of the card via PositionedDirectional.
// Dot at START side of the logo via PositionedDirectional.
// Both flip correctly in RTL ↔ LTR.
// ============================================================

class _Logo extends StatelessWidget {
  final String url;
  final bool isCurrentlyOpen;

  const _Logo({required this.url, required this.isCurrentlyOpen});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _kLogoSz,
      height: _kLogoSz,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: ClipOval(
              child: NetworkImg(
                url: url,
                width: _kLogoSz - 6,
                height: _kLogoSz - 6,
                iconSize: 22,
              ),
            ),
          ),
          // Status dot — at the START side of the logo
          PositionedDirectional(
            bottom: 0,
            start: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: isCurrentlyOpen
                    ? const Color(0xFF22C55E)
                    : const Color(0xFF9CA3AF),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// LOADING & ERROR VIEWS
// ============================================================

// ============================================================
// HOME LOADING VIEW — SHIMMER SKELETON
// ============================================================

class HomeLoadingView extends StatefulWidget {
  const HomeLoadingView({super.key});

  @override
  State<HomeLoadingView> createState() => _HomeLoadingViewState();
}

class _HomeLoadingViewState extends State<HomeLoadingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerCtrl;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final screenW = MediaQuery.of(context).size.width;
    final catItemW = (screenW - 32 - 30) / 4; // matches CategoriesSection

    return AnimatedBuilder(
      animation: _shimmerCtrl,
      builder: (context, _) {
        return ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            // ── Header skeleton ──
            _buildHeaderSkeleton(topPadding),

            // ── Banner skeleton ──
            const SizedBox(height: 16),
            _bone(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height: 160,
              radius: 14,
            ),

            // ── Categories skeleton ──
            const SizedBox(height: 24),
            _buildSectionTitle(),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(
                  8,
                  (_) => SizedBox(
                    width: catItemW,
                    child: Column(
                      children: [
                        _bone(height: 80, width: 80, radius: 12),
                        const SizedBox(height: 6),
                        _bone(height: 10, width: 50, radius: 4),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Featured restaurants skeleton (horizontal) ──
            const SizedBox(height: 24),
            _buildSectionTitle(),
            const SizedBox(height: 10),
            SizedBox(
              height: 210,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 3,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (_, __) =>
                    _buildRestaurantCardSkeleton(screenW - 32),
              ),
            ),

            // ── All restaurants skeleton (vertical) ──
            const SizedBox(height: 24),
            _buildSectionTitle(),
            const SizedBox(height: 10),
            ...List.generate(
              3,
              (i) => Padding(
                padding: EdgeInsets.fromLTRB(16, i == 0 ? 0 : 14, 16, 0),
                child: _buildRestaurantCardSkeleton(screenW - 32),
              ),
            ),

            const SizedBox(height: 40),
          ],
        );
      },
    );
  }

  // ── Header skeleton ──
  Widget _buildHeaderSkeleton(double topPadding) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, topPadding + 12, 16, 14),
      color: ColorsCustom.surface,
      child: Column(
        children: [
          Row(
            children: [
              _bone(width: 40, height: 40, radius: 10),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _bone(height: 12, width: 80, radius: 4),
                    const SizedBox(height: 6),
                    _bone(height: 14, width: 150, radius: 4),
                  ],
                ),
              ),
              _bone(width: 40, height: 40, radius: 10),
            ],
          ),
          const SizedBox(height: 12),
          _bone(height: 48, radius: 12),
        ],
      ),
    );
  }

  // ── Section title skeleton ──
  Widget _buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _bone(width: 3, height: 22, radius: 2),
          const SizedBox(width: 8),
          _bone(height: 16, width: 120, radius: 4),
        ],
      ),
    );
  }

  // ── Restaurant card skeleton ──
  Widget _buildRestaurantCardSkeleton(double width) {
    return SizedBox(
      width: width,
      height: 210,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover
          _bone(height: 130, radius: 14),
          const SizedBox(height: 12),
          // Logo + name area
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _bone(width: 40, height: 40, shape: BoxShape.circle),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _bone(height: 14, width: 140, radius: 4),
                      const SizedBox(height: 6),
                      _bone(height: 11, width: 90, radius: 4),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Single shimmer bone ──
  Widget _bone({
    double? width,
    double? height,
    double radius = 8,
    BoxShape shape = BoxShape.rectangle,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: ShapeDecoration(
        shape: shape == BoxShape.circle
            ? const CircleBorder()
            : RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius),
              ),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: const [
            Color(0xFFEEEEEE),
            Color(0xFFF5F5F5),
            Color(0xFFEEEEEE),
          ],
          stops: [
            (_shimmerCtrl.value - 0.3).clamp(0.0, 1.0),
            _shimmerCtrl.value.clamp(0.0, 1.0),
            (_shimmerCtrl.value + 0.3).clamp(0.0, 1.0),
          ],
        ),
      ),
    );
  }
}

class HomeErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const HomeErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: ColorsCustom.primary.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: ColorsCustom.primary,
              ),
            ),
            const SizedBox(height: 24),
            TextCustom(
              text: message,
              fontSize: 14,
              color: ColorsCustom.textSecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: ColorsCustom.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.refresh_rounded,
                      size: 18,
                      color: ColorsCustom.textOnPrimary,
                    ),
                    const SizedBox(width: 8),
                    TextCustom(
                      text: l10n.retry,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ColorsCustom.textOnPrimary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
