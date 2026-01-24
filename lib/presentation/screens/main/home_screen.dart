import 'package:flutter/material.dart' hide Banner;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:superdriver/domain/bloc/home/home_bloc.dart';
import 'package:superdriver/domain/bloc/restaurant/restaurant_bloc.dart';
import 'package:superdriver/domain/models/home_model.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/components/text_custom.dart';
import 'package:superdriver/presentation/screens/main/restaurant_detail_screen.dart';
import 'package:superdriver/presentation/screens/main/restaurants_screen.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';

// Constants for spacing and design
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}

class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _headerAnimationController;
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
    _setupScrollListener();
    _headerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  void _loadHomeData() {
    context.read<HomeBloc>().add(const HomeLoadRequested());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _headerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: ColorsCustom.background,
      body: BlocConsumer<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is HomeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                action: SnackBarAction(
                  label: l10n.retry,
                  textColor: Colors.white,
                  onPressed: _loadHomeData,
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is HomeLoading) {
            return _buildLoadingState();
          }

          if (state is HomeError && state is! HomeLoaded) {
            return _buildErrorState(context, l10n, state.message);
          }

          if (state is HomeLoaded) {
            return _buildContent(context, l10n, state.homeData);
          }

          return _buildLoadingState();
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (value * 0.2),
                child: Opacity(
                  opacity: value,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          ColorsCustom.primary,
                          ColorsCustom.primary.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          _ShimmerText(text: 'Loading...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    AppLocalizations l10n,
    String message,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.shade100,
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.error_outline_rounded,
                      size: 60,
                      color: Colors.red.shade400,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            TextCustom(
              text: l10n.errorOccurred,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: ColorsCustom.textPrimary,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextCustom(
              text: message,
              fontSize: 14,
              color: ColorsCustom.textSecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            _AnimatedButton(onPressed: _loadHomeData, label: l10n.retry),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations l10n,
    HomeData homeData,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<HomeBloc>().add(const HomeRefreshRequested());
      },
      color: ColorsCustom.primary,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAnimatedAppBar(context, l10n),
          if (homeData.banners.isNotEmpty)
            SliverToBoxAdapter(
              child: _buildBannersSection(context, homeData.banners),
            ),
          if (homeData.categories.isNotEmpty)
            SliverToBoxAdapter(
              child: _buildCategoriesSection(
                context,
                l10n,
                homeData.categories,
              ),
            ),
          if (homeData.featuredRestaurants.isNotEmpty)
            SliverToBoxAdapter(
              child: _buildRestaurantsSection(
                context,
                l10n,
                l10n.featuredRestaurants,
                homeData.featuredRestaurants,
                isFeatured: true,
              ),
            ),
          if (homeData.popularProducts.isNotEmpty)
            SliverToBoxAdapter(
              child: _buildPopularProducts(
                context,
                l10n,
                homeData.popularProducts,
              ),
            ),
          if (homeData.popularRestaurants.isNotEmpty)
            SliverToBoxAdapter(
              child: _buildRestaurantsSection(
                context,
                l10n,
                l10n.popularRestaurants,
                homeData.popularRestaurants,
              ),
            ),
          if (homeData.discountRestaurants.isNotEmpty)
            SliverToBoxAdapter(
              child: _buildRestaurantsSection(
                context,
                l10n,
                l10n.discountRestaurants,
                homeData.discountRestaurants,
                hasDiscount: true,
              ),
            ),
          if (homeData.newRestaurants.isNotEmpty)
            SliverToBoxAdapter(
              child: _buildRestaurantsSection(
                context,
                l10n,
                l10n.newRestaurants,
                homeData.newRestaurants,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _buildAnimatedAppBar(BuildContext context, AppLocalizations l10n) {
    final opacity = (_scrollOffset / 100).clamp(0.0, 1.0);
    final headerScale = 1.0 - (_scrollOffset / 500).clamp(0.0, 0.3);

    return SliverAppBar(
      expandedHeight: 180,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white.withOpacity(opacity),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ColorsCustom.primary,
                ColorsCustom.primary.withOpacity(0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Transform.scale(
              scale: headerScale,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.md,
                  AppSpacing.xl,
                  80,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextCustom(
                            text: l10n.deliveryTo,
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          _LocationSelector(l10n: l10n),
                        ],
                      ),
                    ),
                    _NotificationButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          height: 70,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppRadius.xxl),
              topRight: Radius.circular(AppRadius.xxl),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: _SearchBar(controller: _searchController, l10n: l10n),
        ),
      ),
    );
  }

  Widget _buildBannersSection(BuildContext context, List<Banner> banners) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: SizedBox(
        height: 200,
        child: PageView.builder(
          itemCount: banners.length,
          controller: PageController(viewportFraction: 0.92),
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            return _BannerCard(banner: banners[index], index: index);
          },
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(
    BuildContext context,
    AppLocalizations l10n,
    List<Category> categories,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: l10n.categories,
          actionText: l10n.seeAll,
          onTap: () {},
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            physics: const BouncingScrollPhysics(),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return _CategoryCard(
                category: categories[index],
                index: index,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<RestaurantBloc>(),
                        child: RestaurantsScreen(
                          categorySlug: categories[index].slug,
                          categoryName: categories[index].name,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRestaurantsSection(
    BuildContext context,
    AppLocalizations l10n,
    String title,
    List<Restaurant> restaurants, {
    bool isFeatured = false,
    bool hasDiscount = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: title, actionText: l10n.seeAll, onTap: () {}),
        SizedBox(
          height: isFeatured ? 270 : 230,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            physics: const BouncingScrollPhysics(),
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              return _RestaurantCard(
                restaurant: restaurants[index],
                index: index,
                isFeatured: isFeatured,
                hasDiscount: hasDiscount,
                l10n: l10n,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<RestaurantBloc>(),
                        child: RestaurantDetailScreen(
                          slug: restaurants[index].slug,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPopularProducts(
    BuildContext context,
    AppLocalizations l10n,
    List<ProductSimple> products,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: l10n.popularDishes,
          actionText: l10n.seeAll,
          onTap: () {},
        ),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            physics: const BouncingScrollPhysics(),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return _ProductCard(
                product: products[index],
                index: index,
                l10n: l10n,
                onTap: () {},
              );
            },
          ),
        ),
      ],
    );
  }
}

// ==================== REUSABLE WIDGETS ====================

class _LocationSelector extends StatelessWidget {
  final AppLocalizations l10n;

  const _LocationSelector({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Open location selector
      },
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.white, size: 20),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: TextCustom(
              text: l10n.currentLocation ?? 'الرياض، حي النخيل',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              maxLines: 1,
            ),
          ),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.white,
            size: 24,
          ),
        ],
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Stack(
        children: [
          IconButton(
            onPressed: () {
              // TODO: Open notifications
            },
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          ),
          Positioned(
            right: 10,
            top: 10,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final AppLocalizations l10n;

  const _SearchBar({required this.controller, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorsCustom.grey100,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: l10n.searchPlaceholder,
          hintStyle: TextStyle(color: ColorsCustom.textSecondary, fontSize: 14),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: ColorsCustom.textSecondary,
            size: 22,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  onPressed: () => controller.clear(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: ColorsCustom.textSecondary,
                    size: 20,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
        ),
        onSubmitted: (value) {
          // TODO: Handle search
        },
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  final Banner banner;
  final int index;

  const _BannerCard({required this.banner, required this.index});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: [
                  BoxShadow(
                    color: ColorsCustom.primary.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (banner.image != null)
                      CachedNetworkImage(
                        imageUrl: banner.image!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => _ShimmerPlaceholder(),
                        errorWidget: (context, url, error) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                ColorsCustom.primary,
                                ColorsCustom.primary.withOpacity(0.8),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ColorsCustom.primary,
                              ColorsCustom.primary.withOpacity(0.8),
                            ],
                          ),
                        ),
                      ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      left: AppSpacing.xl,
                      right: AppSpacing.xl,
                      bottom: AppSpacing.xl,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextCustom(
                            text: banner.title,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          if (banner.subtitle != null) ...[
                            const SizedBox(height: AppSpacing.xs),
                            TextCustom(
                              text: banner.subtitle!,
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;
  final int index;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (value * 0.2),
          child: Opacity(
            opacity: value,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                width: 90,
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Column(
                  children: [
                    Container(
                      width: 75,
                      height: 75,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: category.image != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              child: CachedNetworkImage(
                                imageUrl: category.image!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    _ShimmerPlaceholder(),
                                errorWidget: (context, url, error) => Icon(
                                  Icons.category_rounded,
                                  color: ColorsCustom.primary,
                                  size: 32,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.category_rounded,
                              color: ColorsCustom.primary,
                              size: 32,
                            ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextCustom(
                      text: category.name,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ColorsCustom.textPrimary,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final int index;
  final bool isFeatured;
  final bool hasDiscount;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const _RestaurantCard({
    required this.restaurant,
    required this.index,
    required this.isFeatured,
    required this.hasDiscount,
    required this.l10n,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 80)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(50 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                width: isFeatured ? 300 : 240,
                margin: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: isFeatured ? 140 : 110,
                          decoration: BoxDecoration(
                            color: ColorsCustom.grey200,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(AppRadius.xl),
                              topRight: Radius.circular(AppRadius.xl),
                            ),
                          ),
                          child: restaurant.logo != null
                              ? ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(AppRadius.xl),
                                    topRight: Radius.circular(AppRadius.xl),
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl: restaurant.logo!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    placeholder: (context, url) =>
                                        _ShimmerPlaceholder(),
                                    errorWidget: (context, url, error) =>
                                        Center(
                                          child: Icon(
                                            Icons.restaurant_rounded,
                                            size: 45,
                                            color: ColorsCustom.grey400,
                                          ),
                                        ),
                                  ),
                                )
                              : Center(
                                  child: Icon(
                                    Icons.restaurant_rounded,
                                    size: 45,
                                    color: ColorsCustom.grey400,
                                  ),
                                ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: _StatusBadge(
                            isOpen: restaurant.isCurrentlyOpen,
                            l10n: l10n,
                          ),
                        ),
                        if (hasDiscount && restaurant.hasDiscount)
                          Positioned(
                            top: 12,
                            left: 12,
                            child: _DiscountBadge(
                              discount: restaurant.discountDouble.toInt(),
                              l10n: l10n,
                            ),
                          ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextCustom(
                            text: restaurant.name,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ColorsCustom.textPrimary,
                            maxLines: 1,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: Colors.amber.shade600,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              TextCustom(
                                text: restaurant.ratingDouble.toStringAsFixed(
                                  1,
                                ),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: ColorsCustom.textPrimary,
                              ),
                              TextCustom(
                                text: ' (${restaurant.totalReviews})',
                                fontSize: 12,
                                color: ColorsCustom.textSecondary,
                              ),
                              const Spacer(),
                              Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: ColorsCustom.textSecondary,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Flexible(
                                child: TextCustom(
                                  text:
                                      restaurant.deliveryTimeEstimate ??
                                      '30-45',
                                  fontSize: 12,
                                  color: ColorsCustom.textSecondary,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          if (restaurant.deliveryFeeDouble == 0)
                            _FreeDeliveryBadge(l10n: l10n)
                          else
                            TextCustom(
                              text:
                                  '${restaurant.deliveryFeeDouble.toStringAsFixed(0)} ${l10n.currency}',
                              fontSize: 12,
                              color: ColorsCustom.textSecondary,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductSimple product;
  final int index;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const _ProductCard({
    required this.product,
    required this.index,
    required this.l10n,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 80)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(50 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                width: 170,
                margin: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: ColorsCustom.grey200,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(AppRadius.lg),
                              topRight: Radius.circular(AppRadius.lg),
                            ),
                          ),
                          child: product.image != null
                              ? ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(AppRadius.lg),
                                    topRight: Radius.circular(AppRadius.lg),
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl: product.image!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    placeholder: (context, url) =>
                                        _ShimmerPlaceholder(),
                                    errorWidget: (context, url, error) =>
                                        Center(
                                          child: Icon(
                                            Icons.fastfood_rounded,
                                            size: 40,
                                            color: ColorsCustom.grey400,
                                          ),
                                        ),
                                  ),
                                )
                              : Center(
                                  child: Icon(
                                    Icons.fastfood_rounded,
                                    size: 40,
                                    color: ColorsCustom.grey400,
                                  ),
                                ),
                        ),
                        if (product.hasDiscount)
                          Positioned(
                            top: AppSpacing.sm,
                            left: AppSpacing.sm,
                            child: _DiscountBadge(
                              discount: product.discountAmountDouble.toInt(),
                              l10n: l10n,
                            ),
                          ),
                        Positioned(
                          bottom: -18,
                          right: AppSpacing.md,
                          child: _AddToCartButton(),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.lg,
                        AppSpacing.md,
                        AppSpacing.md,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextCustom(
                            text: product.name,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: ColorsCustom.textPrimary,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 2),
                          TextCustom(
                            text: product.restaurantName,
                            fontSize: 11,
                            color: ColorsCustom.textSecondary,
                            maxLines: 1,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            children: [
                              Flexible(
                                child: TextCustom(
                                  text:
                                      '${product.currentPriceDouble.toStringAsFixed(0)} ${l10n.currency}',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: ColorsCustom.primary,
                                  maxLines: 1,
                                ),
                              ),
                              if (product.hasDiscount) ...[
                                const SizedBox(width: AppSpacing.xs),
                                Flexible(
                                  child: TextCustom(
                                    text:
                                        '${product.basePriceDouble.toStringAsFixed(0)}',
                                    fontSize: 11,
                                    color: ColorsCustom.textSecondary,
                                    decoration: TextDecoration.lineThrough,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback onTap;

  const _SectionHeader({
    required this.title,
    required this.actionText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextCustom(
            text: title,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: ColorsCustom.textPrimary,
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: ColorsCustom.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  TextCustom(
                    text: actionText,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ColorsCustom.primary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: ColorsCustom.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== SMALL COMPONENTS ====================

class _StatusBadge extends StatelessWidget {
  final bool isOpen;
  final AppLocalizations l10n;

  const _StatusBadge({required this.isOpen, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isOpen ? Colors.green.shade500 : Colors.red.shade500,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        boxShadow: [
          BoxShadow(
            color: (isOpen ? Colors.green : Colors.red).withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextCustom(
        text: isOpen ? l10n.open : l10n.closed,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}

class _DiscountBadge extends StatelessWidget {
  final int discount;
  final AppLocalizations l10n;

  const _DiscountBadge({required this.discount, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: ColorsCustom.primary,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        boxShadow: [
          BoxShadow(
            color: ColorsCustom.primary.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_offer_rounded, size: 12, color: Colors.white),
          const SizedBox(width: AppSpacing.xs),
          TextCustom(
            text: '$discount%',
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

class _FreeDeliveryBadge extends StatelessWidget {
  final AppLocalizations l10n;

  const _FreeDeliveryBadge({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: TextCustom(
        text: l10n.freeDelivery,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Colors.green.shade700,
      ),
    );
  }
}

class _AddToCartButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: ColorsCustom.primary,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: ColorsCustom.primary.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
    );
  }
}

class _AnimatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;

  const _AnimatedButton({required this.onPressed, required this.label});

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ColorsCustom.primary,
              ColorsCustom.primary.withOpacity(0.85),
            ],
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: [
            BoxShadow(
              color: ColorsCustom.primary.withOpacity(0.4),
              blurRadius: _isPressed ? 8 : 15,
              offset: Offset(0, _isPressed ? 2 : 6),
            ),
          ],
        ),
        child: TextCustom(
          text: widget.label,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _ShimmerPlaceholder extends StatefulWidget {
  @override
  State<_ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<_ShimmerPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ColorsCustom.grey200,
                ColorsCustom.grey100,
                ColorsCustom.grey200,
              ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ShimmerText extends StatefulWidget {
  final String text;

  const _ShimmerText({required this.text});

  @override
  State<_ShimmerText> createState() => _ShimmerTextState();
}

class _ShimmerTextState extends State<_ShimmerText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: 0.5 + (_controller.value * 0.5),
          child: TextCustom(
            text: widget.text,
            fontSize: 14,
            color: ColorsCustom.textSecondary,
          ),
        );
      },
    );
  }
}
