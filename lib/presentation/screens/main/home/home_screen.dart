import 'dart:developer';

import 'package:flutter/material.dart' hide Banner;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:superdriver/domain/bloc/auth/auth_bloc.dart';
import 'package:superdriver/domain/bloc/home/home_bloc.dart';
import 'package:superdriver/domain/bloc/restaurant/restaurant_bloc.dart';
import 'package:superdriver/domain/bloc/menu/menu_bloc.dart';
import 'package:superdriver/domain/bloc/cart/cart_bloc.dart';
import 'package:superdriver/domain/models/home_model.dart';
import 'package:superdriver/domain/models/restaurant_model.dart';
import 'package:superdriver/domain/services/address_service.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/screens/main/home/address_selector.dart';
import 'package:superdriver/presentation/screens/main/home/home_app_bar.dart';
import 'package:superdriver/presentation/screens/main/home/home_sections.dart';
import 'package:superdriver/presentation/screens/main/home/home_widgets.dart';
import 'package:superdriver/presentation/screens/main/home/restaurant_detail_screen.dart';
import 'package:superdriver/presentation/screens/main/home/restaurants_screen.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DeliveryLocationResult? _selectedLocation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resolveInitialLocation();
    });
  }

  // ============================================================
  // AUTH HELPER
  // ============================================================

  bool get _isAuthenticated {
    return context.read<AuthBloc>().state is AuthAuthenticated;
  }

  // ============================================================
  // LOCATION
  // ============================================================

  Future<void> _resolveInitialLocation() async {
    DeliveryLocationResult? location;

    // ── Authenticated: try saved addresses first ──
    if (_isAuthenticated) {
      try {
        final addresses = await addressService.getAllAddresses();
        log('HomeScreen [1] getAllAddresses -> ${addresses.length} addresses');
        if (addresses.isNotEmpty) {
          final picked =
              addresses.where((a) => a.isCurrent).firstOrNull ??
              addresses.first;
          if (picked.title.isNotEmpty) {
            location = DeliveryLocationResult.fromSavedAddress(picked);
          }
        }
      } catch (e) {
        log('HomeScreen [1] getAllAddresses FAILED -> $e');
      }

      if (location == null) {
        try {
          final current = await addressService.getCurrentAddress();
          if (current != null && current.title.isNotEmpty) {
            location = DeliveryLocationResult.fromAddress(current);
          }
        } catch (e) {
          log('HomeScreen [2] getCurrentAddress FAILED -> $e');
        }
      }
    }

    // ── Fallback (both guest & authenticated): GPS auto-detect ──
    if (location == null) {
      try {
        location = await getCurrentLocationAsDefault();
      } catch (e) {
        log('HomeScreen [3] GPS FAILED -> $e');
      }
    }

    if (!mounted) return;

    log('HomeScreen [FINAL] -> "${location?.displayName ?? 'NONE'}"');
    setState(() => _selectedLocation = location);
    context.read<HomeBloc>().add(
      HomeLoadRequested(lat: location?.latitude, lng: location?.longitude),
    );
  }

  // ============================================================
  // EVENTS
  // ============================================================

  Future<void> _onRefresh() async {
    context.read<HomeBloc>().add(
      HomeRefreshRequested(
        lat: _selectedLocation?.latitude,
        lng: _selectedLocation?.longitude,
      ),
    );
  }

  void _onLocationChanged(DeliveryLocationResult result) {
    setState(() => _selectedLocation = result);
    context.read<HomeBloc>().add(
      HomeRefreshRequested(lat: result.latitude, lng: result.longitude),
    );
  }

  void _onLoadMore() {
    context.read<HomeBloc>().add(const HomeLoadMoreRestaurants());
  }

  // ============================================================
  // ADDRESS SELECTOR — auth-aware
  // ============================================================

  void _openAddressSelector() {
    showAddressSelector(
      context,
      currentLocation: _selectedLocation,
      onLocationSelected: _onLocationChanged,
      isAuthenticated: _isAuthenticated,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: ColorsCustom.background,
        body: BlocConsumer<HomeBloc, HomeState>(
          listener: _onStateChanged,
          builder: (context, state) {
            if (state is HomeLoaded) return _buildContent(context, state);
            if (state is HomeError) {
              return HomeErrorView(message: state.message, onRetry: _retryLoad);
            }
            return const HomeLoadingView();
          },
        ),
      ),
    );
  }

  void _onStateChanged(BuildContext context, HomeState state) {
    if (state is HomeError) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: ColorsCustom.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _retryLoad() {
    context.read<HomeBloc>().add(
      HomeLoadRequested(
        lat: _selectedLocation?.latitude,
        lng: _selectedLocation?.longitude,
      ),
    );
  }

  Widget _buildContent(BuildContext context, HomeLoaded state) {
    final l10n = AppLocalizations.of(context)!;
    final data = state.homeData;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: ColorsCustom.primary,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          // ---- Header ----
          HomeHeader(
            selectedLocation: _selectedLocation,
            onLocationTap: _openAddressSelector,
            onSearchTap: _navigateToSearch,
          ),

          // ---- Banners ----
          if (data.banners.isNotEmpty) ...[
            const SizedBox(height: 16),
            BannersSection(banners: data.banners),
          ],

          // ---- Categories ----
          if (data.categories.isNotEmpty) ...[
            const SizedBox(height: 24),
            CategoriesSection(
              categories: data.categories,
              onTap: _navigateToCategory,
            ),
          ],

          // ---- Featured (horizontal scroll) ----
          if (data.featuredRestaurants.isNotEmpty) ...[
            const SizedBox(height: 24),
            RestaurantsHorizontalSection(
              title: l10n.featuredRestaurants,
              restaurants: data.featuredRestaurants,
              onTap: _navigateToRestaurant,
              onSeeAllTap: () =>
                  _navigateToRestaurants(RestaurantsScreenMode.featured),
            ),
          ],

          // ---- Recommended (horizontal scroll, auth only) ----
          if (state.isAuthenticated &&
              (state.recommendedRestaurants?.isNotEmpty ?? false)) ...[
            const SizedBox(height: 24),
            RestaurantsHorizontalSection(
              title: l10n.recommendedForYou,
              restaurants: state.recommendedRestaurants!,
              onTap: _navigateToRestaurant,
            ),
          ],

          // ---- Nearby (horizontal scroll) ----
          if (state.nearbyRestaurants?.isNotEmpty ?? false) ...[
            const SizedBox(height: 24),
            RestaurantsHorizontalSection(
              title: l10n.nearbyRestaurants,
              restaurants: state.nearbyRestaurants!,
              onTap: _navigateToRestaurant,
            ),
          ],

          // ---- New (horizontal scroll) ----
          if (data.newRestaurants.isNotEmpty) ...[
            const SizedBox(height: 24),
            RestaurantsHorizontalSection(
              title: l10n.newRestaurants,
              restaurants: data.newRestaurants,
              onTap: _navigateToRestaurant,
              onSeeAllTap: () =>
                  _navigateToRestaurants(RestaurantsScreenMode.newRestaurants),
            ),
          ],

          // ---- All Restaurants (vertical scroll, paginated) ----
          if (state.allRestaurants.isNotEmpty) ...[
            const SizedBox(height: 24),
            RestaurantsVerticalSection(
              title: l10n.allRestaurants,
              restaurants: state.allRestaurants,
              onTap: _navigateToRestaurant,
              hasMore: state.hasMoreRestaurants,
              isLoadingMore: state.isLoadingMore,
              onLoadMore: _onLoadMore,
            ),
          ],

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  void _navigateToSearch() {
    _push(
      BlocProvider(
        create: (_) => RestaurantBloc(),
        child: RestaurantsScreen(
          mode: RestaurantsScreenMode.search,
          latitude: _selectedLocation?.latitude,
          longitude: _selectedLocation?.longitude,
        ),
      ),
    );
  }

  void _navigateToCategory(Category category) {
    final name = getLocalizedName(
      context,
      name: category.name,
      nameEn: category.nameEn,
    );
    _push(
      BlocProvider(
        create: (_) => RestaurantBloc(),
        child: RestaurantsScreen.category(
          categoryId: category.id,
          categoryName: name,
          latitude: _selectedLocation?.latitude,
          longitude: _selectedLocation?.longitude,
        ),
      ),
    );
  }

  void _navigateToRestaurant(RestaurantListItem restaurant) {
    _push(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => RestaurantBloc()),
          BlocProvider(create: (_) => MenuBloc()),
          BlocProvider(create: (_) => CartBloc()),
        ],
        child: RestaurantDetailScreen(
          slug: restaurant.slug,
          lat: _selectedLocation?.latitude,
          lng: _selectedLocation?.longitude,
        ),
      ),
    );
  }

  void _navigateToRestaurants(RestaurantsScreenMode mode) {
    _push(
      BlocProvider(
        create: (_) => RestaurantBloc(),
        child: RestaurantsScreen(
          mode: mode,
          latitude: _selectedLocation?.latitude,
          longitude: _selectedLocation?.longitude,
        ),
      ),
    );
  }

  void _push(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}
