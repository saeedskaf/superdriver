import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:superdriver/domain/bloc/restaurant/restaurant_bloc.dart';
import 'package:superdriver/domain/models/restaurant_model.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/components/text_custom.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final String slug;

  const RestaurantDetailScreen({super.key, required this.slug});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<RestaurantBloc>().add(
          RestaurantDetailsLoadRequested(slug: widget.slug),
        );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: ColorsCustom.background,
      body: BlocBuilder<RestaurantBloc, RestaurantState>(
        builder: (context, state) {
          if (state is RestaurantDetailsLoading) {
            return _buildLoadingState();
          }

          if (state is RestaurantDetailsError) {
            return _buildErrorState(context, l10n, state.message);
          }

          if (state is RestaurantDetailsLoaded) {
            return _buildContent(context, l10n, state.restaurant);
          }

          return _buildLoadingState();
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(ColorsCustom.primary),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    AppLocalizations l10n,
    String message,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 60,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 16),
          TextCustom(
            text: message,
            fontSize: 14,
            color: ColorsCustom.textSecondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<RestaurantBloc>().add(
                    RestaurantDetailsLoadRequested(slug: widget.slug),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsCustom.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: TextCustom(
              text: l10n.retry,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations l10n,
    RestaurantDetail restaurant,
  ) {
    return CustomScrollView(
      slivers: [
        // App Bar with Cover Image
        _buildSliverAppBar(context, l10n, restaurant),

        // Restaurant Info Card
        SliverToBoxAdapter(
          child: _buildInfoCard(context, l10n, restaurant),
        ),

        // Tab Bar
        SliverPersistentHeader(
          pinned: true,
          delegate: _SliverTabBarDelegate(
            TabBar(
              controller: _tabController,
              labelColor: ColorsCustom.primary,
              unselectedLabelColor: ColorsCustom.textSecondary,
              indicatorColor: ColorsCustom.primary,
              indicatorWeight: 3,
              tabs: [
                Tab(text: l10n.menu),
                Tab(text: l10n.info),
              ],
            ),
          ),
        ),

        // Tab Content
        SliverFillRemaining(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildMenuTab(context, l10n, restaurant),
              _buildInfoTab(context, l10n, restaurant),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context,
    AppLocalizations l10n,
    RestaurantDetail restaurant,
  ) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: Colors.white,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: ColorsCustom.textPrimary,
            ),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {
                // Share restaurant
              },
              icon: const Icon(
                Icons.share_rounded,
                size: 20,
                color: ColorsCustom.textPrimary,
              ),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Cover Image
            if (restaurant.coverImage != null)
              Image.network(
                restaurant.coverImage!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: ColorsCustom.primary.withOpacity(0.2),
                ),
              )
            else
              Container(
                color: ColorsCustom.primary.withOpacity(0.2),
              ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Status Badges
            Positioned(
              top: 100,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: restaurant.isCurrentlyOpen
                          ? Colors.green.shade500
                          : Colors.red.shade500,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextCustom(
                      text: restaurant.isCurrentlyOpen ? l10n.open : l10n.closed,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (restaurant.hasDiscount) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: ColorsCustom.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextCustom(
                        text: '${restaurant.discountDouble.toInt()}% ${l10n.off}',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    AppLocalizations l10n,
    RestaurantDetail restaurant,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo & Name Row
          Row(
            children: [
              // Logo
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: ColorsCustom.grey100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ColorsCustom.grey200),
                ),
                child: restaurant.logo != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          restaurant.logo!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.restaurant_rounded,
                            color: ColorsCustom.grey400,
                            size: 30,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.restaurant_rounded,
                        color: ColorsCustom.grey400,
                        size: 30,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextCustom(
                      text: restaurant.name,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: ColorsCustom.textPrimary,
                    ),
                    if (restaurant.categoryName != null)
                      TextCustom(
                        text: restaurant.categoryName!,
                        fontSize: 14,
                        color: ColorsCustom.textSecondary,
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Stats Row
          Row(
            children: [
              _buildStatItem(
                icon: Icons.star_rounded,
                iconColor: Colors.amber.shade600,
                value: restaurant.ratingDouble.toStringAsFixed(1),
                label: '(${restaurant.totalReviews})',
              ),
              _buildDivider(),
              _buildStatItem(
                icon: Icons.access_time_rounded,
                iconColor: ColorsCustom.primary,
                value: restaurant.deliveryTimeEstimate ?? '20-30',
                label: 'min',
              ),
              _buildDivider(),
              _buildStatItem(
                icon: Icons.delivery_dining_rounded,
                iconColor: Colors.blue,
                value: restaurant.deliveryFeeDouble == 0
                    ? l10n.freeDelivery
                    : '${restaurant.deliveryFeeDouble.toStringAsFixed(0)} ${l10n.currency}',
                label: '',
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Minimum Order
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ColorsCustom.grey100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  color: ColorsCustom.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                TextCustom(
                  text: '${l10n.minOrder}: ${restaurant.minimumOrderDouble.toStringAsFixed(0)} ${l10n.currency}',
                  fontSize: 14,
                  color: ColorsCustom.textSecondary,
                ),
              ],
            ),
          ),
          // Call Button
          if (restaurant.phone != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _callRestaurant(restaurant.phone!),
                icon: const Icon(Icons.phone_rounded),
                label: TextCustom(
                  text: l10n.callRestaurant,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ColorsCustom.primary,
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ColorsCustom.primary,
                  side: const BorderSide(color: ColorsCustom.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 6),
          TextCustom(
            text: value,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: ColorsCustom.textPrimary,
          ),
          if (label.isNotEmpty)
            TextCustom(
              text: ' $label',
              fontSize: 12,
              color: ColorsCustom.textSecondary,
            ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 30,
      width: 1,
      color: ColorsCustom.grey200,
    );
  }

  Widget _buildMenuTab(
    BuildContext context,
    AppLocalizations l10n,
    RestaurantDetail restaurant,
  ) {
    // This will show menu categories and products
    // For now, placeholder
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu_rounded,
            size: 60,
            color: ColorsCustom.grey300,
          ),
          const SizedBox(height: 16),
          TextCustom(
            text: l10n.viewMenu,
            fontSize: 16,
            color: ColorsCustom.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTab(
    BuildContext context,
    AppLocalizations l10n,
    RestaurantDetail restaurant,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          if (restaurant.description != null &&
              restaurant.description!.isNotEmpty) ...[
            _buildSectionTitle(l10n.about),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextCustom(
                text: restaurant.description!,
                fontSize: 14,
                color: ColorsCustom.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Address
          if (restaurant.address != null) ...[
            _buildSectionTitle(l10n.deliveryAddress),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: ColorsCustom.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextCustom(
                      text: restaurant.address!,
                      fontSize: 14,
                      color: ColorsCustom.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Working Hours
          if (restaurant.workingHours.isNotEmpty) ...[
            _buildSectionTitle(l10n.workingHours),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: restaurant.workingHours.map((hours) {
                  return _buildWorkingHoursRow(l10n, hours);
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextCustom(
        text: title,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: ColorsCustom.textPrimary,
      ),
    );
  }

  Widget _buildWorkingHoursRow(AppLocalizations l10n, WorkingHours hours) {
    final dayNames = [
      l10n.sunday,
      l10n.monday,
      l10n.tuesday,
      l10n.wednesday,
      l10n.thursday,
      l10n.friday,
      l10n.saturday,
    ];

    final dayName = hours.day >= 0 && hours.day < 7
        ? dayNames[hours.day]
        : hours.dayName;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextCustom(
            text: dayName,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: ColorsCustom.textPrimary,
          ),
          TextCustom(
            text: hours.isClosed
                ? l10n.closedDay
                : '${hours.openingTime} - ${hours.closingTime}',
            fontSize: 14,
            color: hours.isClosed ? Colors.red : ColorsCustom.textSecondary,
          ),
        ],
      ),
    );
  }

  void _callRestaurant(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }
}

// Tab Bar Delegate
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
