part of 'restaurant_bloc.dart';

abstract class RestaurantEvent extends Equatable {
  const RestaurantEvent();

  @override
  List<Object?> get props => [];
}

/// Load restaurants with optional filters
class RestaurantsLoadRequested extends RestaurantEvent {
  final RestaurantFilterParams? filters;

  const RestaurantsLoadRequested({this.filters});

  @override
  List<Object?> get props => [filters];
}

/// Refresh restaurants
class RestaurantsRefreshRequested extends RestaurantEvent {
  const RestaurantsRefreshRequested();
}

/// Load restaurant details
class RestaurantDetailsLoadRequested extends RestaurantEvent {
  final String slug;

  const RestaurantDetailsLoadRequested({required this.slug});

  @override
  List<Object?> get props => [slug];
}

/// Load restaurant categories
class RestaurantCategoriesLoadRequested extends RestaurantEvent {
  const RestaurantCategoriesLoadRequested();
}

/// Load restaurants by category
class RestaurantsByCategoryLoadRequested extends RestaurantEvent {
  final String categorySlug;

  const RestaurantsByCategoryLoadRequested({required this.categorySlug});

  @override
  List<Object?> get props => [categorySlug];
}

/// Load nearby restaurants
class NearbyRestaurantsLoadRequested extends RestaurantEvent {
  final double lat;
  final double lng;
  final double? radius;

  const NearbyRestaurantsLoadRequested({
    required this.lat,
    required this.lng,
    this.radius,
  });

  @override
  List<Object?> get props => [lat, lng, radius];
}

/// Search restaurants
class RestaurantsSearchRequested extends RestaurantEvent {
  final String query;

  const RestaurantsSearchRequested({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Clear search results
class RestaurantsSearchCleared extends RestaurantEvent {
  const RestaurantsSearchCleared();
}
