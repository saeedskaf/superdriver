part of 'menu_bloc.dart';

abstract class MenuState extends Equatable {
  const MenuState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class MenuInitial extends MenuState {
  const MenuInitial();
}

// ==================== Menu Categories States ====================

class MenuCategoriesLoading extends MenuState {
  const MenuCategoriesLoading();
}

class MenuCategoriesLoaded extends MenuState {
  final List<MenuCategory> categories;

  const MenuCategoriesLoaded({required this.categories});

  @override
  List<Object?> get props => [categories];
}

class MenuCategoriesEmpty extends MenuState {
  const MenuCategoriesEmpty();
}

class MenuCategoriesError extends MenuState {
  final String message;

  const MenuCategoriesError(this.message);

  @override
  List<Object?> get props => [message];
}

// ==================== Menu Products States ====================

class MenuProductsLoading extends MenuState {
  const MenuProductsLoading();
}

class MenuProductsLoaded extends MenuState {
  final List<ProductSimpleMenu> products;

  const MenuProductsLoaded({required this.products});

  @override
  List<Object?> get props => [products];
}

class MenuProductsEmpty extends MenuState {
  const MenuProductsEmpty();
}

class MenuProductsError extends MenuState {
  final String message;

  const MenuProductsError(this.message);

  @override
  List<Object?> get props => [message];
}

// ==================== Product Details States ====================

class MenuProductDetailsLoading extends MenuState {
  const MenuProductDetailsLoading();
}

class MenuProductDetailsLoaded extends MenuState {
  final ProductDetail product;

  const MenuProductDetailsLoaded({required this.product});

  @override
  List<Object?> get props => [product];
}

class MenuProductDetailsError extends MenuState {
  final String message;

  const MenuProductDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}

// ==================== Deals States ====================

class MenuDealsLoading extends MenuState {
  const MenuDealsLoading();
}

class MenuDealsLoaded extends MenuState {
  final List<ProductSimpleMenu> products;

  const MenuDealsLoaded({required this.products});

  @override
  List<Object?> get props => [products];
}

class MenuDealsEmpty extends MenuState {
  const MenuDealsEmpty();
}

class MenuDealsError extends MenuState {
  final String message;

  const MenuDealsError(this.message);

  @override
  List<Object?> get props => [message];
}

// ==================== Featured Products States ====================

class MenuFeaturedLoading extends MenuState {
  const MenuFeaturedLoading();
}

class MenuFeaturedLoaded extends MenuState {
  final List<ProductSimpleMenu> products;

  const MenuFeaturedLoaded({required this.products});

  @override
  List<Object?> get props => [products];
}

class MenuFeaturedEmpty extends MenuState {
  const MenuFeaturedEmpty();
}

class MenuFeaturedError extends MenuState {
  final String message;

  const MenuFeaturedError(this.message);

  @override
  List<Object?> get props => [message];
}

// ==================== Popular Products States ====================

class MenuPopularLoading extends MenuState {
  const MenuPopularLoading();
}

class MenuPopularLoaded extends MenuState {
  final List<ProductSimpleMenu> products;

  const MenuPopularLoaded({required this.products});

  @override
  List<Object?> get props => [products];
}

class MenuPopularEmpty extends MenuState {
  const MenuPopularEmpty();
}

class MenuPopularError extends MenuState {
  final String message;

  const MenuPopularError(this.message);

  @override
  List<Object?> get props => [message];
}
