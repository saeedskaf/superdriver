part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final HomeData homeData;
  final List<RestaurantListItem>? recommendedRestaurants;
  final List<RestaurantListItem>? nearbyRestaurants;
  final List<RestaurantListItem> allRestaurants;
  final bool isAuthenticated;
  final bool hasMoreRestaurants;
  final bool isLoadingMore;

  const HomeLoaded({
    required this.homeData,
    this.recommendedRestaurants,
    this.nearbyRestaurants,
    required this.allRestaurants,
    required this.isAuthenticated,
    this.hasMoreRestaurants = true,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [
    homeData,
    recommendedRestaurants,
    nearbyRestaurants,
    allRestaurants,
    isAuthenticated,
    hasMoreRestaurants,
    isLoadingMore,
  ];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
