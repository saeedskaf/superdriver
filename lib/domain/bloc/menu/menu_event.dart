part of 'menu_bloc.dart';

abstract class MenuEvent extends Equatable {
  const MenuEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load menu categories for a restaurant
class MenuCategoriesLoadRequested extends MenuEvent {
  final int restaurantId;

  const MenuCategoriesLoadRequested({required this.restaurantId});

  @override
  List<Object?> get props => [restaurantId];
}

/// Event to load products with simplified parameters
/// Only uses: restaurantId, categoryId, and search
class MenuProductsLoadRequested extends MenuEvent {
  final int restaurantId;
  final int? categoryId;
  final String? search;

  const MenuProductsLoadRequested({
    required this.restaurantId,
    this.categoryId,
    this.search,
  });

  @override
  List<Object?> get props => [restaurantId, categoryId, search];
}

/// Event to load product details by slug
class MenuProductDetailsLoadRequested extends MenuEvent {
  final String slug;

  const MenuProductDetailsLoadRequested({required this.slug});

  @override
  List<Object?> get props => [slug];
}

/// Event to load deals (products with discounts)
class MenuDealsLoadRequested extends MenuEvent {
  const MenuDealsLoadRequested();
}

/// Event to load featured products
class MenuFeaturedLoadRequested extends MenuEvent {
  const MenuFeaturedLoadRequested();
}

/// Event to load popular products
class MenuPopularLoadRequested extends MenuEvent {
  const MenuPopularLoadRequested();
}
