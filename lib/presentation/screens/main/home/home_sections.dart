import 'dart:async';

import 'package:flutter/material.dart' hide Banner;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:superdriver/domain/models/home_model.dart';
import 'package:superdriver/domain/models/restaurant_model.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/components/text_custom.dart';
import 'package:superdriver/presentation/screens/main/home/home_widgets.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';

// ============================================================
// BANNERS
// ============================================================

class BannersSection extends StatefulWidget {
  final List<Banner> banners;
  const BannersSection({super.key, required this.banners});

  @override
  State<BannersSection> createState() => _BannersSectionState();
}

class _BannersSectionState extends State<BannersSection> {
  final _controller = PageController(viewportFraction: 0.92);
  int _current = 0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    if (widget.banners.length <= 1) return;
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_controller.hasClients) return;
      final next = (_current + 1) % widget.banners.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.banners.length;
    return SizedBox(
      height: 160,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: count,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) => _bannerCard(widget.banners[i]),
          ),
          if (count > 1) _indicators(count),
        ],
      ),
    );
  }

  Widget _bannerCard(Banner banner) {
    final url = getFullImageUrl(banner.image);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: ColorsCustom.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: url.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                placeholder: (_, __) => Container(color: ColorsCustom.primary),
                errorWidget: (_, __, ___) =>
                    Container(color: ColorsCustom.primary),
              )
            : Container(color: ColorsCustom.primary),
      ),
    );
  }

  Widget _indicators(int count) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: const BoxDecoration(
            color: ColorsCustom.surfaceVariant,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(count, (i) {
              final active = _current == i;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: active ? 20 : 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: active
                      ? ColorsCustom.secondaryDark
                      : ColorsCustom.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// CATEGORIES — 4 per line
// ============================================================

class CategoriesSection extends StatelessWidget {
  final List<Category> categories;
  final ValueChanged<Category> onTap;

  const CategoriesSection({
    super.key,
    required this.categories,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
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
              TextCustom(
                text: l10n.categories,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ColorsCustom.textPrimary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - 30) / 4;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: categories.map((cat) {
                  return SizedBox(
                    width: itemWidth,
                    child: CategoryCard(category: cat, onTap: () => onTap(cat)),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ============================================================
// RESTAURANTS — HORIZONTAL SCROLL
//
// Same RestaurantCard. Width = screen - 32 to match vertical.
// Height = kRestaurantCardH + padding for shadow.
// ============================================================

class RestaurantsHorizontalSection extends StatelessWidget {
  final String title;
  final List<RestaurantListItem> restaurants;
  final ValueChanged<RestaurantListItem> onTap;
  final VoidCallback? onSeeAllTap;

  const RestaurantsHorizontalSection({
    super.key,
    required this.title,
    required this.restaurants,
    required this.onTap,
    this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = restaurants.length > 8
        ? restaurants.sublist(0, 8)
        : restaurants;
    final screenW = MediaQuery.of(context).size.width;
    final cardW = screenW - 64; // leaves room to peek the next card

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: title,
          onSeeAllTap: onSeeAllTap,
          showSeeAll: onSeeAllTap != null,
        ),
        SizedBox(
          height: kRestaurantCardH + 10, // card + shadow room
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsetsDirectional.only(start: 16, end: 16),
            itemCount: items.length,
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsetsDirectional.only(end: 12),
              child: SizedBox(
                width: cardW,
                child: RestaurantCard(
                  restaurant: items[i],
                  onTap: () => onTap(items[i]),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// RESTAURANTS — VERTICAL LIST (paginated)
//
// Same RestaurantCard, full width, stacked vertically.
// ============================================================

class RestaurantsVerticalSection extends StatelessWidget {
  final String title;
  final List<RestaurantListItem> restaurants;
  final ValueChanged<RestaurantListItem> onTap;
  final bool hasMore;
  final bool isLoadingMore;
  final VoidCallback? onLoadMore;

  const RestaurantsVerticalSection({
    super.key,
    required this.title,
    required this.restaurants,
    required this.onTap,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title, showSeeAll: false),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              for (final r in restaurants) ...[
                RestaurantCard(restaurant: r, onTap: () => onTap(r)),
                const SizedBox(height: 14),
              ],
              if (hasMore && onLoadMore != null)
                _LoadMoreButton(
                  isLoading: isLoadingMore,
                  onTap: onLoadMore!,
                  label: l10n.loadMore,
                ),
              if (!hasMore && restaurants.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 16),
                  child: Center(
                    child: TextCustom(
                      text: l10n.noMoreRestaurants,
                      fontSize: 13,
                      color: ColorsCustom.textHint,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LoadMoreButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;
  final String label;

  const _LoadMoreButton({
    required this.isLoading,
    required this.onTap,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: ColorsCustom.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ColorsCustom.border),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: ColorsCustom.primary,
                  ),
                )
              : TextCustom(
                  text: label,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ColorsCustom.primary,
                ),
        ),
      ),
    );
  }
}
