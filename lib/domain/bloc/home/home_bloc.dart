import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:superdriver/domain/models/home_model.dart';
import 'package:superdriver/domain/models/restaurant_model.dart';
import 'package:superdriver/domain/services/home_services.dart';
import 'package:superdriver/domain/services/restaurant_services.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeData? _homeData;
  List<RestaurantListItem>? _recommendedRestaurants;
  List<RestaurantListItem>? _nearbyRestaurants;
  List<RestaurantListItem> _allRestaurants = [];
  bool _isAuthenticated = false;

  /// Pagination state
  static const int _pageSize = 10;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  /// Stored location — updated from events, reused across handlers.
  double? _lat;
  double? _lng;

  HomeBloc() : super(const HomeInitial()) {
    on<HomeLoadRequested>(_onLoad);
    on<HomeRefreshRequested>(_onRefresh);
    on<HomeNearbyRequested>(_onNearbyRequested);
    on<HomeLoadMoreRestaurants>(_onLoadMore);
    on<HomeUserLoggedIn>(_onUserLoggedIn);
    on<HomeUserLoggedOut>(_onUserLoggedOut);
  }

  // ============================================================
  // HELPERS
  // ============================================================

  HomeLoaded _buildLoadedState({bool isLoadingMore = false}) => HomeLoaded(
    homeData: _homeData!,
    recommendedRestaurants: _recommendedRestaurants,
    nearbyRestaurants: _nearbyRestaurants,
    allRestaurants: _allRestaurants,
    isAuthenticated: _isAuthenticated,
    hasMoreRestaurants: _hasMore,
    isLoadingMore: isLoadingMore,
  );

  String _formatError(Object e) => e.toString().replaceAll('Exception: ', '');

  void _updateLocation(double? lat, double? lng) {
    _lat = lat;
    _lng = lng;
  }

  RestaurantFilterParams? _buildFilters({int? page}) {
    final hasLocation = _lat != null && _lng != null;
    if (!hasLocation && page == null) return null;
    return RestaurantFilterParams(
      lat: _lat,
      lng: _lng,
      page: page,
      pageSize: _pageSize,
    );
  }

  Future<void> _fetchAllData() async {
    _isAuthenticated = await homeServices.isAuthenticated();
    _currentPage = 1;
    _hasMore = true;

    final publicFuture = Future.wait([
      homeServices.getHomeData(lat: _lat, lng: _lng),
      restaurantServices.getRestaurants(filters: _buildFilters(page: 1)),
    ]);

    final nearbyFuture = (_lat != null && _lng != null)
        ? homeServices.getNearbyRestaurants(lat: _lat!, lng: _lng!)
        : Future.value(null);

    final recommendedFuture = _isAuthenticated
        ? homeServices.getRecommendedRestaurants(lat: _lat, lng: _lng)
        : Future.value(null);

    final results = await Future.wait([
      publicFuture,
      nearbyFuture,
      recommendedFuture,
    ]);

    final publicResults = results[0] as List<dynamic>;
    _homeData = publicResults[0] as HomeData;
    _allRestaurants = publicResults[1] as List<RestaurantListItem>;
    _nearbyRestaurants = results[1] as List<RestaurantListItem>?;
    _recommendedRestaurants = results[2] as List<RestaurantListItem>?;

    _hasMore = _allRestaurants.length >= _pageSize;
  }

  // ============================================================
  // EVENT HANDLERS
  // ============================================================

  Future<void> _onLoad(HomeLoadRequested event, Emitter<HomeState> emit) async {
    _updateLocation(event.lat, event.lng);
    emit(const HomeLoading());
    try {
      await _fetchAllData();
      emit(_buildLoadedState());
    } catch (e) {
      log('HomeBloc: Error loading: $e');
      emit(HomeError(_formatError(e)));
    }
  }

  Future<void> _onRefresh(
    HomeRefreshRequested event,
    Emitter<HomeState> emit,
  ) async {
    _updateLocation(event.lat, event.lng);
    try {
      await _fetchAllData();
      emit(_buildLoadedState());
    } catch (e) {
      log('HomeBloc: Error refreshing: $e');
      if (_homeData != null) {
        emit(_buildLoadedState());
      } else {
        emit(HomeError(_formatError(e)));
      }
    }
  }

  Future<void> _onNearbyRequested(
    HomeNearbyRequested event,
    Emitter<HomeState> emit,
  ) async {
    _updateLocation(event.lat, event.lng);
    if (_homeData == null) return;
    try {
      _nearbyRestaurants = await homeServices.getNearbyRestaurants(
        lat: event.lat,
        lng: event.lng,
      );
      emit(_buildLoadedState());
    } catch (e) {
      log('HomeBloc: Error loading nearby: $e');
    }
  }

  Future<void> _onLoadMore(
    HomeLoadMoreRestaurants event,
    Emitter<HomeState> emit,
  ) async {
    if (_isLoadingMore || !_hasMore || _homeData == null) return;
    _isLoadingMore = true;
    emit(_buildLoadedState(isLoadingMore: true));

    try {
      final nextPage = _currentPage + 1;
      final more = await restaurantServices.getRestaurants(
        filters: _buildFilters(page: nextPage),
      );

      if (more.isEmpty) {
        _hasMore = false;
      } else {
        _currentPage = nextPage;
        // Deduplicate: only add restaurants not already in the list
        final existingIds = _allRestaurants.map((r) => r.id).toSet();
        final unique = more.where((r) => !existingIds.contains(r.id)).toList();
        _allRestaurants = [..._allRestaurants, ...unique];
        // If all results were duplicates or fewer than page size, no more
        _hasMore = more.length >= _pageSize && unique.isNotEmpty;
      }
    } catch (e) {
      log('HomeBloc: Error loading more: $e');
    }

    _isLoadingMore = false;
    emit(_buildLoadedState());
  }

  Future<void> _onUserLoggedIn(
    HomeUserLoggedIn event,
    Emitter<HomeState> emit,
  ) async {
    _isAuthenticated = true;
    if (_homeData == null) return;

    try {
      _recommendedRestaurants = await homeServices.getRecommendedRestaurants(
        lat: _lat,
        lng: _lng,
      );
      emit(_buildLoadedState());
    } catch (e) {
      log('HomeBloc: Error loading auth data: $e');
    }
  }

  Future<void> _onUserLoggedOut(
    HomeUserLoggedOut event,
    Emitter<HomeState> emit,
  ) async {
    _isAuthenticated = false;
    _recommendedRestaurants = null;
    if (_homeData != null) emit(_buildLoadedState());
  }
}
