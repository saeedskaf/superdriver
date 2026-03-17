import 'dart:developer';
import 'dart:async';

import 'package:flutter/material.dart' hide Banner;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:superdriver/domain/bloc/auth/auth_bloc.dart';
import 'package:superdriver/domain/bloc/home/home_bloc.dart';
import 'package:superdriver/domain/bloc/restaurant/restaurant_bloc.dart';
import 'package:superdriver/domain/bloc/menu/menu_bloc.dart';
import 'package:superdriver/domain/bloc/cart/cart_bloc.dart';
import 'package:superdriver/domain/models/home_model.dart';
import 'package:superdriver/domain/models/restaurant_model.dart';
import 'package:superdriver/data/services/address_service.dart';
import 'package:superdriver/data/services/in_app_messaging_service.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/screens/main/home/address_selector.dart';
import 'package:superdriver/presentation/screens/main/home/home_app_bar.dart';
import 'package:superdriver/presentation/screens/main/home/home_sections.dart';
import 'package:superdriver/presentation/screens/main/home/home_cards.dart';
import 'package:superdriver/presentation/screens/main/restaurant/restaurant_detail_screen.dart';
import 'package:superdriver/presentation/screens/main/restaurant/restaurants_screen.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  static const String _homeOpenedFiamEvent = 'home_opened';

  final _scrollController = ScrollController();
  DeliveryLocationResult? _selectedLocation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      inAppMessagingService.triggerEvent(_homeOpenedFiamEvent);
      _resolveInitialLocation();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Scrolls to top and refreshes content — called on same-tab re-select.
  void scrollToTopAndRefresh() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
    _onRefresh();
  }

  bool get _isAuthenticated {
    return context.read<AuthBloc>().state is AuthAuthenticated;
  }

  Future<void> _resolveInitialLocation() async {
    final l10nLocal = AppLocalizations.of(context)!;
    DeliveryLocationResult? location;

    // try saved addresses first
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

    // fallback: GPS
    if (location == null) {
      try {
        location = await getCurrentLocationAsDefault(
          fallbackLocationName: l10nLocal.currentLocation,
        );
      } catch (e) {
        log('HomeScreen [3] GPS FAILED -> $e');
      }
    }

    if (!mounted) return;

    final bloc = context.read<HomeBloc>();
    final hasSameLocation = _isSameLocation(_selectedLocation, location);
    log('HomeScreen [FINAL] -> "${location?.displayName ?? 'NONE'}"');
    setState(() => _selectedLocation = location);

    if (hasSameLocation && bloc.state is HomeLoaded) return;

    final hasExistingData = bloc.state is HomeLoaded;
    if (hasExistingData) {
      bloc.add(
        HomeRefreshRequested(lat: location?.latitude, lng: location?.longitude),
      );
    } else {
      bloc.add(
        HomeLoadRequested(lat: location?.latitude, lng: location?.longitude),
      );
    }
  }

  Future<void> _onRefresh() async {
    final bloc = context.read<HomeBloc>();
    final completer = Completer<void>();
    bloc.add(
      HomeRefreshRequested(
        lat: _selectedLocation?.latitude,
        lng: _selectedLocation?.longitude,
        completer: completer,
      ),
    );
    await completer.future.timeout(
      const Duration(seconds: 12),
      onTimeout: () {},
    );
  }

  void _onLocationChanged(DeliveryLocationResult result) {
    if (_isSameLocation(_selectedLocation, result)) return;
    setState(() => _selectedLocation = result);
    context.read<HomeBloc>().add(
      HomeRefreshRequested(lat: result.latitude, lng: result.longitude),
    );
  }

  bool _isSameLocation(DeliveryLocationResult? a, DeliveryLocationResult? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return a == b;
    return a.latitude == b.latitude &&
        a.longitude == b.longitude &&
        a.displayName == b.displayName;
  }

  void _onLoadMore() {
    context.read<HomeBloc>().add(const HomeLoadMoreRestaurants());
  }

  void _openAddressSelector() {
    showAddressSelector(
      context,
      currentLocation: _selectedLocation,
      onLocationSelected: _onLocationChanged,
      isAuthenticated: _isAuthenticated,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    final bottomScrollSpace = MediaQuery.of(context).padding.bottom + 120;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: ColorsCustom.primary,
      displacement: 72,
      child: ListView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          HomeHeader(
            selectedLocation: _selectedLocation,
            onLocationTap: _openAddressSelector,
            onSearchTap: _navigateToSearch,
          ),

          if (data.banners.isNotEmpty) ...[
            const SizedBox(height: 16),
            BannersSection(banners: data.banners),
          ],

          if (data.categories.isNotEmpty) ...[
            const SizedBox(height: 24),
            CategoriesSection(
              categories: data.categories,
              onTap: _navigateToCategory,
            ),
          ],

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

          if (state.isAuthenticated &&
              (state.recommendedRestaurants?.isNotEmpty ?? false)) ...[
            const SizedBox(height: 24),
            RestaurantsHorizontalSection(
              title: l10n.recommendedForYou,
              restaurants: state.recommendedRestaurants!,
              onTap: _navigateToRestaurant,
            ),
          ],

          if (state.nearbyRestaurants?.isNotEmpty ?? false) ...[
            const SizedBox(height: 24),
            RestaurantsHorizontalSection(
              title: l10n.nearbyRestaurants,
              restaurants: state.nearbyRestaurants!,
              onTap: _navigateToRestaurant,
            ),
          ],

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

          SizedBox(height: bottomScrollSpace),
        ],
      ),
    );
  }

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
