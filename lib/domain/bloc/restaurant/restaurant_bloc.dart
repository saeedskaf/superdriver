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
    on<RestaurantsByCategoryLoadRequested>(_onRestaurantsByCategoryLoadRequested);
    on<NearbyRestaurantsLoadRequested>(_onNearbyRestaurantsLoadRequested);
    on<RestaurantsSearchRequested>(_onSearchRequested);
    on<RestaurantsSearchCleared>(_onSearchCleared);
  }

  List<RestaurantListItem>? get restaurants => _restaurants;
  List<RestaurantCategory>? get categories => _categories;
  RestaurantDetail? get currentRestaurant => _currentRestaurant;

  Future<void> _onRestaurantsLoadRequested(
    RestaurantsLoadRequested event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(const RestaurantsLoading());
    try {
      final restaurants = await restaurantServices.getRestaurants(
        filters: event.filters,
      );
      _restaurants = restaurants;
      _currentFilters = event.filters;

      if (restaurants.isEmpty) {
        emit(const RestaurantsEmpty());
      } else {
        emit(RestaurantsLoaded(
          restaurants: restaurants,
          filters: event.filters,
        ));
      }
    } catch (e) {
      emit(RestaurantsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRestaurantsRefreshRequested(
    RestaurantsRefreshRequested event,
    Emitter<RestaurantState> emit,
  ) async {
    try {
      final restaurants = await restaurantServices.getRestaurants(
        filters: _currentFilters,
      );
      _restaurants = restaurants;

      if (restaurants.isEmpty) {
        emit(const RestaurantsEmpty());
      } else {
        emit(RestaurantsLoaded(
          restaurants: restaurants,
          filters: _currentFilters,
        ));
      }
    } catch (e) {
      emit(RestaurantsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRestaurantDetailsLoadRequested(
    RestaurantDetailsLoadRequested event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(const RestaurantDetailsLoading());
    try {
      final restaurant = await restaurantServices.getRestaurantDetails(event.slug);
      _currentRestaurant = restaurant;
      emit(RestaurantDetailsLoaded(restaurant: restaurant));
    } catch (e) {
      emit(RestaurantDetailsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCategoriesLoadRequested(
    RestaurantCategoriesLoadRequested event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(const CategoriesLoading());
    try {
      final categories = await restaurantServices.getCategories();
      _categories = categories;
      emit(CategoriesLoaded(categories: categories));
    } catch (e) {
      emit(CategoriesError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRestaurantsByCategoryLoadRequested(
    RestaurantsByCategoryLoadRequested event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(const RestaurantsLoading());
    try {
      final restaurants = await restaurantServices.getCategoryRestaurants(
        event.categorySlug,
      );
      _restaurants = restaurants;

      if (restaurants.isEmpty) {
        emit(const RestaurantsEmpty());
      } else {
        emit(RestaurantsLoaded(restaurants: restaurants));
      }
    } catch (e) {
      emit(RestaurantsError(e.toString().replaceAll('Exception: ', '')));
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
        emit(const RestaurantsEmpty());
      } else {
        emit(NearbyRestaurantsLoaded(restaurants: restaurants));
      }
    } catch (e) {
      emit(NearbyRestaurantsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onSearchRequested(
    RestaurantsSearchRequested event,
    Emitter<RestaurantState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      emit(const RestaurantInitial());
      return;
    }

    emit(const RestaurantsSearching());
    try {
      final restaurants = await restaurantServices.searchRestaurants(event.query);

      if (restaurants.isEmpty) {
        emit(RestaurantsSearchEmpty(query: event.query));
      } else {
        emit(RestaurantsSearchResults(
          restaurants: restaurants,
          query: event.query,
        ));
      }
    } catch (e) {
      emit(RestaurantsSearchError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void _onSearchCleared(
    RestaurantsSearchCleared event,
    Emitter<RestaurantState> emit,
  ) {
    if (_restaurants != null && _restaurants!.isNotEmpty) {
      emit(RestaurantsLoaded(
        restaurants: _restaurants!,
        filters: _currentFilters,
      ));
    } else {
      emit(const RestaurantInitial());
    }
  }
}
