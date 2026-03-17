part of 'restaurant_bloc.dart';

abstract class RestaurantState extends Equatable {
  const RestaurantState();

  @override
  List<Object?> get props => [];
}

class RestaurantInitial extends RestaurantState {
  const RestaurantInitial();
}

class RestaurantsLoading extends RestaurantState {
  const RestaurantsLoading();
}

class RestaurantsLoaded extends RestaurantState {
  final List<RestaurantListItem> restaurants;
  final RestaurantFilterParams? filters;

  const RestaurantsLoaded({required this.restaurants, this.filters});

  /// Check if currently filtering by category
  bool get isFilteringByCategory => filters?.categoryId != null;

  /// Check if currently searching
  bool get isSearching =>
      filters?.search != null && filters!.search!.isNotEmpty;

  /// Get current search query if any
  String? get searchQuery => filters?.search;

  /// Get current category ID if filtering
  int? get categoryId => filters?.categoryId;

  @override
  List<Object?> get props => [restaurants, filters];
}

class RestaurantsEmpty extends RestaurantState {
  final int? categoryId;
  final RestaurantFilterParams? filters;

  const RestaurantsEmpty({this.categoryId, this.filters});

  @override
  List<Object?> get props => [categoryId, filters];
}

class RestaurantsSearchEmpty extends RestaurantState {
  final String query;
  final RestaurantFilterParams? filters;

  const RestaurantsSearchEmpty({required this.query, this.filters});

  @override
  List<Object?> get props => [query, filters];
}

class RestaurantsError extends RestaurantState {
  final String message;
  final RestaurantFilterParams? filters;

  const RestaurantsError(this.message, {this.filters});

  @override
  List<Object?> get props => [message, filters];
}

class RestaurantsLoadMoreLoaded extends RestaurantState {
  final List<RestaurantListItem> restaurants;
  final RestaurantFilterParams filters;

  const RestaurantsLoadMoreLoaded({
    required this.restaurants,
    required this.filters,
  });

  @override
  List<Object?> get props => [restaurants, filters];
}

class RestaurantsLoadMoreError extends RestaurantState {
  final String message;
  final RestaurantFilterParams filters;

  const RestaurantsLoadMoreError({
    required this.message,
    required this.filters,
  });

  @override
  List<Object?> get props => [message, filters];
}

class RestaurantDetailsLoading extends RestaurantState {
  const RestaurantDetailsLoading();
}

class RestaurantDetailsLoaded extends RestaurantState {
  final RestaurantDetail restaurant;

  const RestaurantDetailsLoaded({required this.restaurant});

  @override
  List<Object?> get props => [restaurant];
}

class RestaurantDetailsError extends RestaurantState {
  final String message;

  const RestaurantDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}

class CategoriesLoading extends RestaurantState {
  const CategoriesLoading();
}

class CategoriesLoaded extends RestaurantState {
  final List<RestaurantCategory> categories;

  const CategoriesLoaded({required this.categories});

  @override
  List<Object?> get props => [categories];
}

class CategoriesError extends RestaurantState {
  final String message;

  const CategoriesError(this.message);

  @override
  List<Object?> get props => [message];
}

class NearbyRestaurantsLoading extends RestaurantState {
  const NearbyRestaurantsLoading();
}

class NearbyRestaurantsLoaded extends RestaurantState {
  final List<RestaurantListItem> restaurants;

  const NearbyRestaurantsLoaded({required this.restaurants});

  @override
  List<Object?> get props => [restaurants];
}

class NearbyRestaurantsEmpty extends RestaurantState {
  final double lat;
  final double lng;

  const NearbyRestaurantsEmpty({required this.lat, required this.lng});

  @override
  List<Object?> get props => [lat, lng];
}

class NearbyRestaurantsError extends RestaurantState {
  final String message;

  const NearbyRestaurantsError(this.message);

  @override
  List<Object?> get props => [message];
}
