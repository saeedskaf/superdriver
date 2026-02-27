import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:superdriver/domain/models/restaurant_model.dart';
import 'package:superdriver/domain/services/restaurant_services.dart';

part 'restaurant_event.dart';
part 'restaurant_state.dart';

class RestaurantBloc extends Bloc<RestaurantEvent, RestaurantState> {
  List<RestaurantListItem>? _restaurants;
  List<RestaurantCategory>? _categories;
  RestaurantDetail? _currentRestaurant;
  RestaurantFilterParams? _currentFilters;

  RestaurantBloc() : super(const RestaurantInitial()) {
    on<RestaurantsLoadRequested>(_onRestaurantsLoadRequested);
    on<RestaurantsRefreshRequested>(_onRestaurantsRefreshRequested);
    on<RestaurantDetailsLoadRequested>(_onRestaurantDetailsLoadRequested);
    on<RestaurantCategoriesLoadRequested>(_onCategoriesLoadRequested);
    on<NearbyRestaurantsLoadRequested>(_onNearbyRestaurantsLoadRequested);
    on<RestaurantsFilterChanged>(_onFilterChanged);
    on<RestaurantsClearFilters>(_onClearFilters);
  }

  // Public getters
  List<RestaurantListItem>? get restaurants => _restaurants;
  List<RestaurantCategory>? get categories => _categories;
  RestaurantDetail? get currentRestaurant => _currentRestaurant;
  RestaurantFilterParams? get currentFilters => _currentFilters;

  // ============================================================
  // HELPERS
  // ============================================================

  /// Emit the appropriate state for a restaurant list result.
  /// Handles loaded, empty, and search-empty states.
  void _emitForList(
    Emitter<RestaurantState> emit,
    List<RestaurantListItem> restaurants,
    RestaurantFilterParams? filters,
  ) {
    _restaurants = restaurants;
    _currentFilters = filters;

    if (restaurants.isEmpty) {
      final search = filters?.search;
      if (search != null && search.isNotEmpty) {
        emit(RestaurantsSearchEmpty(query: search));
      } else {
        emit(RestaurantsEmpty(categoryId: filters?.categoryId));
      }
    } else {
      emit(RestaurantsLoaded(restaurants: restaurants, filters: filters));
    }
  }

  String _formatError(dynamic error) {
    return error.toString().replaceAll('Exception: ', '');
  }

  // ============================================================
  // EVENT HANDLERS
  // ============================================================

  Future<void> _onRestaurantsLoadRequested(
    RestaurantsLoadRequested event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(const RestaurantsLoading());
    try {
      final restaurants = await restaurantServices.getRestaurants(
        filters: event.filters,
      );
      _emitForList(emit, restaurants, event.filters);
    } catch (e) {
      log('RestaurantBloc: Error loading restaurants: $e');
      emit(RestaurantsError(_formatError(e)));
    }
  }

  Future<void> _onRestaurantsRefreshRequested(
    RestaurantsRefreshRequested event,
    Emitter<RestaurantState> emit,
  ) async {
    final previousState = state;
    try {
      final restaurants = await restaurantServices.getRestaurants(
        filters: _currentFilters,
      );
      _emitForList(emit, restaurants, _currentFilters);
    } catch (e) {
      log('RestaurantBloc: Error refreshing: $e');
      if (previousState is RestaurantsLoaded) {
        emit(previousState);
      } else {
        emit(RestaurantsError(_formatError(e)));
      }
    }
  }

  Future<void> _onRestaurantDetailsLoadRequested(
    RestaurantDetailsLoadRequested event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(const RestaurantDetailsLoading());
    try {
      _currentRestaurant = await restaurantServices.getRestaurantDetails(
        event.slug,
        lat: event.lat,
        lng: event.lng,
      );
      emit(RestaurantDetailsLoaded(restaurant: _currentRestaurant!));
    } catch (e) {
      log('RestaurantBloc: Error loading details: $e');
      emit(RestaurantDetailsError(_formatError(e)));
    }
  }

  Future<void> _onCategoriesLoadRequested(
    RestaurantCategoriesLoadRequested event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(const CategoriesLoading());
    try {
      _categories = await restaurantServices.getCategories();
      emit(CategoriesLoaded(categories: _categories!));
    } catch (e) {
      log('RestaurantBloc: Error loading categories: $e');
      emit(CategoriesError(_formatError(e)));
    }
  }

  Future<void> _onNearbyRestaurantsLoadRequested(
    NearbyRestaurantsLoadRequested event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(const NearbyRestaurantsLoading());
    try {
      final restaurants = await restaurantServices.getNearbyRestaurants(
        lat: event.lat,
        lng: event.lng,
        radius: event.radius,
      );
      if (restaurants.isEmpty) {
        emit(NearbyRestaurantsEmpty(lat: event.lat, lng: event.lng));
      } else {
        emit(NearbyRestaurantsLoaded(restaurants: restaurants));
      }
    } catch (e) {
      log('RestaurantBloc: Error loading nearby: $e');
      emit(NearbyRestaurantsError(_formatError(e)));
    }
  }

  Future<void> _onFilterChanged(
    RestaurantsFilterChanged event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(const RestaurantsLoading());
    try {
      final newFilters = RestaurantFilterParams(
        categoryId: event.categoryId ?? _currentFilters?.categoryId,
        search: event.search ?? _currentFilters?.search,
        hasDiscount: event.hasDiscount ?? _currentFilters?.hasDiscount,
        isFeatured: event.isFeatured ?? _currentFilters?.isFeatured,
        isCurrentlyOpen:
            event.isCurrentlyOpen ?? _currentFilters?.isCurrentlyOpen,
        ordering: event.ordering ?? _currentFilters?.ordering,
        restaurantType: event.restaurantType ?? _currentFilters?.restaurantType,
      );
      final restaurants = await restaurantServices.getRestaurants(
        filters: newFilters,
      );
      _emitForList(emit, restaurants, newFilters);
    } catch (e) {
      log('RestaurantBloc: Error applying filters: $e');
      emit(RestaurantsError(_formatError(e)));
    }
  }

  Future<void> _onClearFilters(
    RestaurantsClearFilters event,
    Emitter<RestaurantState> emit,
  ) async {
    _currentFilters = null;
    emit(const RestaurantsLoading());
    try {
      final restaurants = await restaurantServices.getRestaurants();
      _emitForList(emit, restaurants, null);
    } catch (e) {
      log('RestaurantBloc: Error clearing filters: $e');
      emit(RestaurantsError(_formatError(e)));
    }
  }
}
