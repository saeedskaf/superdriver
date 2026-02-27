part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Initial load / full reload
class HomeLoadRequested extends HomeEvent {
  final double? lat;
  final double? lng;

  const HomeLoadRequested({this.lat, this.lng});

  @override
  List<Object?> get props => [lat, lng];
}

/// Pull-to-refresh (keeps old data on error)
class HomeRefreshRequested extends HomeEvent {
  final double? lat;
  final double? lng;

  const HomeRefreshRequested({this.lat, this.lng});

  @override
  List<Object?> get props => [lat, lng];
}

/// Fetch nearby restaurants when location changes
class HomeNearbyRequested extends HomeEvent {
  final double lat;
  final double lng;

  const HomeNearbyRequested({required this.lat, required this.lng});

  @override
  List<Object?> get props => [lat, lng];
}

/// Load next page of all restaurants
class HomeLoadMoreRestaurants extends HomeEvent {
  const HomeLoadMoreRestaurants();
}

/// User just logged in — fetch auth-only data
class HomeUserLoggedIn extends HomeEvent {
  const HomeUserLoggedIn();
}

/// User just logged out — clear auth-only data
class HomeUserLoggedOut extends HomeEvent {
  const HomeUserLoggedOut();
}
