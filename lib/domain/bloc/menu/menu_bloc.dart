import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:superdriver/domain/models/menu_model.dart';
import 'package:superdriver/domain/services/menu_services.dart';

part 'menu_event.dart';
part 'menu_state.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  List<MenuCategory>? _categories;
  List<ProductSimpleMenu>? _products;
  ProductDetail? _currentProduct;

  MenuBloc() : super(const MenuInitial()) {
    on<MenuCategoriesLoadRequested>(_onCategoriesLoadRequested);
    on<MenuProductsLoadRequested>(_onProductsLoadRequested);
    on<MenuProductDetailsLoadRequested>(_onProductDetailsLoadRequested);
    on<MenuDealsLoadRequested>(_onDealsLoadRequested);
    on<MenuFeaturedLoadRequested>(_onFeaturedLoadRequested);
    on<MenuPopularLoadRequested>(_onPopularLoadRequested);
  }

  List<MenuCategory>? get categories => _categories;
  List<ProductSimpleMenu>? get products => _products;
  ProductDetail? get currentProduct => _currentProduct;

  Future<void> _onCategoriesLoadRequested(
    MenuCategoriesLoadRequested event,
    Emitter<MenuState> emit,
  ) async {
    emit(const MenuCategoriesLoading());
    try {
      final categories = await menuServices.getCategories(
        restaurantId: event.restaurantId,
      );
      _categories = categories;

      if (categories.isEmpty) {
        emit(const MenuCategoriesEmpty());
      } else {
        emit(MenuCategoriesLoaded(categories: categories));
      }
    } catch (e) {
      emit(MenuCategoriesError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onProductsLoadRequested(
    MenuProductsLoadRequested event,
    Emitter<MenuState> emit,
  ) async {
    emit(const MenuProductsLoading());
    try {
      final products = await menuServices.getProducts(
        restaurantId: event.restaurantId,
        categoryId: event.categoryId,
        search: event.search,
      );
      _products = products;

      if (products.isEmpty) {
        emit(const MenuProductsEmpty());
      } else {
        emit(MenuProductsLoaded(products: products));
      }
    } catch (e) {
      emit(MenuProductsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onProductDetailsLoadRequested(
    MenuProductDetailsLoadRequested event,
    Emitter<MenuState> emit,
  ) async {
    emit(const MenuProductDetailsLoading());
    try {
      final product = await menuServices.getProductDetails(event.slug);
      _currentProduct = product;
      emit(MenuProductDetailsLoaded(product: product));
    } catch (e) {
      emit(MenuProductDetailsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onDealsLoadRequested(
    MenuDealsLoadRequested event,
    Emitter<MenuState> emit,
  ) async {
    emit(const MenuDealsLoading());
    try {
      final products = await menuServices.getDeals();
      if (products.isEmpty) {
        emit(const MenuDealsEmpty());
      } else {
        emit(MenuDealsLoaded(products: products));
      }
    } catch (e) {
      emit(MenuDealsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onFeaturedLoadRequested(
    MenuFeaturedLoadRequested event,
    Emitter<MenuState> emit,
  ) async {
    emit(const MenuFeaturedLoading());
    try {
      final products = await menuServices.getFeaturedProducts();
      if (products.isEmpty) {
        emit(const MenuFeaturedEmpty());
      } else {
        emit(MenuFeaturedLoaded(products: products));
      }
    } catch (e) {
      emit(MenuFeaturedError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onPopularLoadRequested(
    MenuPopularLoadRequested event,
    Emitter<MenuState> emit,
  ) async {
    emit(const MenuPopularLoading());
    try {
      final products = await menuServices.getPopularProducts();
      if (products.isEmpty) {
        emit(const MenuPopularEmpty());
      } else {
        emit(MenuPopularLoaded(products: products));
      }
    } catch (e) {
      emit(MenuPopularError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
