import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:superdriver/domain/models/home_model.dart';
import 'package:superdriver/domain/services/home_services.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeData? _homeData;
  List<Restaurant>? _nearbyRestaurants;
  List<Restaurant>? _recommendedRestaurants;
  TrendingData? _trendingData;

  HomeBloc() : super(const HomeInitial()) {
    on<HomeLoadRequested>(_onHomeLoadRequested);
    on<HomeRefreshRequested>(_onHomeRefreshRequested);
    on<HomeNearbyRestaurantsRequested>(_onNearbyRestaurantsRequested);
    on<HomeRecommendedRestaurantsRequested>(_onRecommendedRestaurantsRequested);
    on<HomeTrendingRequested>(_onTrendingRequested);
    on<HomeSearchSuggestionsRequested>(_onSearchSuggestionsRequested);
  }

  HomeData? get homeData => _homeData;

  Future<void> _onHomeLoadRequested(
    HomeLoadRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    try {
      final homeData = await homeServices.getHomeData();
      _homeData = homeData;

      emit(HomeLoaded(
        homeData: homeData,
        nearbyRestaurants: _nearbyRestaurants,
        recommendedRestaurants: _recommendedRestaurants,
        trendingData: _trendingData,
      ));
    } catch (e) {
      emit(HomeError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onHomeRefreshRequested(
    HomeRefreshRequested event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final homeData = await homeServices.getHomeData();
      _homeData = homeData;

      emit(HomeLoaded(
        homeData: homeData,
        nearbyRestaurants: _nearbyRestaurants,
        recommendedRestaurants: _recommendedRestaurants,
        trendingData: _trendingData,
      ));
    } catch (e) {
      emit(HomeError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onNearbyRestaurantsRequested(
    HomeNearbyRestaurantsRequested event,
    Emitter<HomeState> emit,
  ) async {
    if (_homeData == null) return;

    emit(HomeNearbyLoading(homeData: _homeData!));
    try {
      final nearbyRestaurants = await homeServices.getNearbyRestaurants(
        lat: event.lat,
        lng: event.lng,
      );
      _nearbyRestaurants = nearbyRestaurants;

      emit(HomeLoaded(
        homeData: _homeData!,
        nearbyRestaurants: nearbyRestaurants,
        recommendedRestaurants: _recommendedRestaurants,
        trendingData: _trendingData,
      ));
    } catch (e) {
      emit(HomeNearbyError(
        homeData: _homeData!,
        message: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onRecommendedRestaurantsRequested(
    HomeRecommendedRestaurantsRequested event,
    Emitter<HomeState> emit,
  ) async {
    if (_homeData == null) return;

    try {
      final recommendedRestaurants =
          await homeServices.getRecommendedRestaurants();
      _recommendedRestaurants = recommendedRestaurants;

      emit(HomeLoaded(
        homeData: _homeData!,
        nearbyRestaurants: _nearbyRestaurants,
        recommendedRestaurants: recommendedRestaurants,
        trendingData: _trendingData,
      ));
    } catch (e) {
      // Silently fail for recommendations, keep current state
      print('Failed to load recommendations: $e');
    }
  }

  Future<void> _onTrendingRequested(
    HomeTrendingRequested event,
    Emitter<HomeState> emit,
  ) async {
    if (_homeData == null) return;

    try {
      final trendingData = await homeServices.getTrending();
      _trendingData = trendingData;

      emit(HomeLoaded(
        homeData: _homeData!,
        nearbyRestaurants: _nearbyRestaurants,
        recommendedRestaurants: _recommendedRestaurants,
        trendingData: trendingData,
      ));
    } catch (e) {
      // Silently fail for trending, keep current state
      print('Failed to load trending: $e');
    }
  }

  Future<void> _onSearchSuggestionsRequested(
    HomeSearchSuggestionsRequested event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final suggestions = await homeServices.getSearchSuggestions();
      print('Search suggestions: $suggestions');
      // Handle suggestions as needed
    } catch (e) {
      print('Failed to load suggestions: $e');
    }
  }
}
