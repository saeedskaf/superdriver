part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeLoadRequested extends HomeEvent {
  const HomeLoadRequested();
}

class HomeRefreshRequested extends HomeEvent {
  const HomeRefreshRequested();
}

class HomeNearbyRestaurantsRequested extends HomeEvent {
  final double lat;
  final double lng;

  const HomeNearbyRestaurantsRequested({
    required this.lat,
    required this.lng,
  });

  @override
  List<Object?> get props => [lat, lng];
}

class HomeRecommendedRestaurantsRequested extends HomeEvent {
  const HomeRecommendedRestaurantsRequested();
}

class HomeTrendingRequested extends HomeEvent {
  const HomeTrendingRequested();
}

class HomeSearchSuggestionsRequested extends HomeEvent {
  const HomeSearchSuggestionsRequested();
}
