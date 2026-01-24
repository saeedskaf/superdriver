part of 'restaurant_bloc.dart';

abstract class RestaurantState extends Equatable {
  const RestaurantState();

  @override
  List<Object?> get props => [];
}

class RestaurantInitial extends RestaurantState {
  const RestaurantInitial();
}

/// Restaurants list states
class RestaurantsLoading extends RestaurantState {
  const RestaurantsLoading();
}

class RestaurantsLoaded extends RestaurantState {
  final List<RestaurantListItem> restaurants;
  final RestaurantFilterParams? filters;

  const RestaurantsLoaded({
    required this.restaurants,
    this.filters,
  });

  @override
  List<Object?> get props => [restaurants, filters];
}

class RestaurantsEmpty extends RestaurantState {
  const RestaurantsEmpty();
}

class RestaurantsError extends RestaurantState {
  final String message;

  const RestaurantsError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Restaurant details states
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

/// Categories states
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

/// Nearby restaurants states
class NearbyRestaurantsLoading extends RestaurantState {
  const NearbyRestaurantsLoading();
}

class NearbyRestaurantsLoaded extends RestaurantState {
  final List<RestaurantListItem> restaurants;

  const NearbyRestaurantsLoaded({required this.restaurants});

  @override
  List<Object?> get props => [restaurants];
}

class NearbyRestaurantsError extends RestaurantState {
  final String message;

  const NearbyRestaurantsError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Search states
class RestaurantsSearching extends RestaurantState {
  const RestaurantsSearching();
}

class RestaurantsSearchResults extends RestaurantState {
  final List<RestaurantListItem> restaurants;
  final String query;

  const RestaurantsSearchResults({
    required this.restaurants,
    required this.query,
  });

  @override
  List<Object?> get props => [restaurants, query];
}

class RestaurantsSearchEmpty extends RestaurantState {
  final String query;

  const RestaurantsSearchEmpty({required this.query});

  @override
  List<Object?> get props => [query];
}

class RestaurantsSearchError extends RestaurantState {
  final String message;

  const RestaurantsSearchError(this.message);

  @override
  List<Object?> get props => [message];
}
