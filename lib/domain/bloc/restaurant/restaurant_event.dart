part of 'restaurant_bloc.dart';

abstract class RestaurantEvent extends Equatable {
  const RestaurantEvent();

  @override
  List<Object?> get props => [];
}

/// Load restaurants with optional filters (handles category, search, and all filters)
class RestaurantsLoadRequested extends RestaurantEvent {
  final RestaurantFilterParams? filters;

  const RestaurantsLoadRequested({this.filters});

  @override
  List<Object?> get props => [filters];
}

/// Refresh current restaurant list
class RestaurantsRefreshRequested extends RestaurantEvent {
  const RestaurantsRefreshRequested();
}

/// Load restaurant details by slug
class RestaurantDetailsLoadRequested extends RestaurantEvent {
  final String slug;
  final double? lat;
  final double? lng;

  const RestaurantDetailsLoadRequested({
    required this.slug,
    this.lat,
    this.lng,
  });

  @override
  List<Object?> get props => [slug, lat, lng];
}

/// Load all categories
class RestaurantCategoriesLoadRequested extends RestaurantEvent {
  const RestaurantCategoriesLoadRequested();
}

/// Load nearby restaurants by location
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

/// Update filters (merges with existing filters)
class RestaurantsFilterChanged extends RestaurantEvent {
  final int? categoryId;
  final String? search;
  final bool? hasDiscount;
  final bool? isFeatured;
  final bool? isCurrentlyOpen;
  final String? ordering;
  final String? restaurantType;

  const RestaurantsFilterChanged({
    this.categoryId,
    this.search,
    this.hasDiscount,
    this.isFeatured,
    this.isCurrentlyOpen,
    this.ordering,
    this.restaurantType,
  });

  @override
  List<Object?> get props => [
    categoryId,
    search,
    hasDiscount,
    isFeatured,
    isCurrentlyOpen,
    ordering,
    restaurantType,
  ];
}

/// Clear all filters
class RestaurantsClearFilters extends RestaurantEvent {
  const RestaurantsClearFilters();
}
