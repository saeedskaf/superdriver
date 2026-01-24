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
  final List<Restaurant>? nearbyRestaurants;
  final List<Restaurant>? recommendedRestaurants;
  final TrendingData? trendingData;

  const HomeLoaded({
    required this.homeData,
    this.nearbyRestaurants,
    this.recommendedRestaurants,
    this.trendingData,
  });

  HomeLoaded copyWith({
    HomeData? homeData,
    List<Restaurant>? nearbyRestaurants,
    List<Restaurant>? recommendedRestaurants,
    TrendingData? trendingData,
  }) {
    return HomeLoaded(
      homeData: homeData ?? this.homeData,
      nearbyRestaurants: nearbyRestaurants ?? this.nearbyRestaurants,
      recommendedRestaurants: recommendedRestaurants ?? this.recommendedRestaurants,
      trendingData: trendingData ?? this.trendingData,
    );
  }

  @override
  List<Object?> get props => [
        homeData,
        nearbyRestaurants,
        recommendedRestaurants,
        trendingData,
      ];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

class HomeNearbyLoading extends HomeState {
  final HomeData homeData;

  const HomeNearbyLoading({required this.homeData});

  @override
  List<Object?> get props => [homeData];
}

class HomeNearbyLoaded extends HomeState {
  final HomeData homeData;
  final List<Restaurant> nearbyRestaurants;

  const HomeNearbyLoaded({
    required this.homeData,
    required this.nearbyRestaurants,
  });

  @override
  List<Object?> get props => [homeData, nearbyRestaurants];
}

class HomeNearbyError extends HomeState {
  final HomeData homeData;
  final String message;

  const HomeNearbyError({
    required this.homeData,
    required this.message,
  });

  @override
  List<Object?> get props => [homeData, message];
}
