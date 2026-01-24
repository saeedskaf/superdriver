import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:superdriver/domain/models/cart_model.dart';
import 'package:superdriver/domain/services/cart_services.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  Cart? _currentCart;
  int? _currentRestaurantId;

  CartBloc() : super(const CartInitial()) {
    on<CartLoadRequested>(_onCartLoadRequested);
    on<CartLoadAllRequested>(_onCartLoadAllRequested);
    on<CartAddItemRequested>(_onCartAddItemRequested);
    on<CartUpdateItemRequested>(_onCartUpdateItemRequested);
    on<CartRemoveItemRequested>(_onCartRemoveItemRequested);
    on<CartClearRequested>(_onCartClearRequested);
    on<CartDeleteRequested>(_onCartDeleteRequested);
    on<CartApplyCouponRequested>(_onCartApplyCouponRequested);
    on<CartRemoveCouponRequested>(_onCartRemoveCouponRequested);
    on<CartValidateRequested>(_onCartValidateRequested);
    on<CartReset>(_onCartReset);
  }

  Cart? get currentCart => _currentCart;
  int? get currentRestaurantId => _currentRestaurantId;

  Future<void> _onCartLoadRequested(
    CartLoadRequested event,
    Emitter<CartState> emit,
  ) async {
    emit(const CartLoading());
    try {
      final cart = await cartServices.getCart(
        cartId: event.cartId,
        restaurantId: event.restaurantId,
      );
      _currentCart = cart;
      _currentRestaurantId = cart.restaurant?.id;

      if (cart.isEmpty) {
        emit(const CartEmpty());
      } else {
        emit(CartLoaded(cart: cart));
      }
    } catch (e) {
      // If cart doesn't exist yet, treat as empty
      if (e.toString().contains('404') || e.toString().contains('not found')) {
        emit(const CartEmpty());
      } else {
        emit(CartError(e.toString().replaceAll('Exception: ', '')));
      }
    }
  }

  Future<void> _onCartLoadAllRequested(
    CartLoadAllRequested event,
    Emitter<CartState> emit,
  ) async {
    emit(const CartLoading());
    try {
      final response = await cartServices.getAllCarts();
      emit(
        CartAllLoaded(
          carts: response.carts,
          count: response.count,
          maxAllowed: response.maxAllowed,
        ),
      );
    } catch (e) {
      emit(CartError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCartAddItemRequested(
    CartAddItemRequested event,
    Emitter<CartState> emit,
  ) async {
    emit(const CartLoading());
    try {
      final request = AddToCartRequest(
        restaurantId: event.restaurantId,
        productId: event.productId,
        quantity: event.quantity,
        variationId: event.variationId,
        addons: event.addons,
        specialInstructions: event.specialInstructions,
      );

      final cart = await cartServices.addToCart(request);
      _currentCart = cart;
      _currentRestaurantId = event.restaurantId;

      emit(
        CartOperationSuccess(cart: cart, message: 'تمت إضافة المنتج إلى السلة'),
      );
    } catch (e) {
      emit(CartError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCartUpdateItemRequested(
    CartUpdateItemRequested event,
    Emitter<CartState> emit,
  ) async {
    if (_currentCart != null) {
      emit(CartItemUpdating(cart: _currentCart!, updatingItemId: event.itemId));
    }

    try {
      final cart = await cartServices.updateCartItem(
        itemId: event.itemId,
        quantity: event.quantity,
        specialInstructions: event.specialInstructions,
      );
      _currentCart = cart;

      if (cart.isEmpty) {
        emit(const CartEmpty());
      } else {
        emit(CartLoaded(cart: cart));
      }
    } catch (e) {
      emit(CartError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCartRemoveItemRequested(
    CartRemoveItemRequested event,
    Emitter<CartState> emit,
  ) async {
    if (_currentCart != null) {
      emit(CartItemUpdating(cart: _currentCart!, updatingItemId: event.itemId));
    }

    try {
      final cart = await cartServices.deleteCartItem(event.itemId);
      _currentCart = cart;

      if (cart.isEmpty) {
        emit(const CartEmpty());
      } else {
        emit(CartLoaded(cart: cart));
      }
    } catch (e) {
      emit(CartError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCartClearRequested(
    CartClearRequested event,
    Emitter<CartState> emit,
  ) async {
    emit(const CartLoading());
    try {
      await cartServices.clearCart(event.cartId);
      _currentCart = null;
      emit(const CartCleared());
    } catch (e) {
      emit(CartError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCartDeleteRequested(
    CartDeleteRequested event,
    Emitter<CartState> emit,
  ) async {
    emit(const CartLoading());
    try {
      await cartServices.deleteCart(event.cartId);
      _currentCart = null;
      emit(const CartDeleted());
    } catch (e) {
      emit(CartError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCartApplyCouponRequested(
    CartApplyCouponRequested event,
    Emitter<CartState> emit,
  ) async {
    emit(const CartLoading());
    try {
      final cart = await cartServices.applyCoupon(
        cartId: event.cartId,
        code: event.couponCode,
      );
      _currentCart = cart;

      emit(CartCouponApplied(cart: cart, couponCode: event.couponCode));
    } catch (e) {
      emit(CartError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCartRemoveCouponRequested(
    CartRemoveCouponRequested event,
    Emitter<CartState> emit,
  ) async {
    emit(const CartLoading());
    try {
      final cart = await cartServices.removeCoupon(event.cartId);
      _currentCart = cart;
      emit(CartCouponRemoved(cart: cart));
    } catch (e) {
      emit(CartError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCartValidateRequested(
    CartValidateRequested event,
    Emitter<CartState> emit,
  ) async {
    try {
      final isValid = await cartServices.validateCart(event.cartId);
      if (isValid && _currentCart != null) {
        emit(CartValidated(cart: _currentCart!));
      }
    } catch (e) {
      if (_currentCart != null) {
        emit(
          CartValidationFailed(
            cart: _currentCart!,
            message: e.toString().replaceAll('Exception: ', ''),
          ),
        );
      } else {
        emit(CartError(e.toString().replaceAll('Exception: ', '')));
      }
    }
  }

  Future<void> _onCartReset(CartReset event, Emitter<CartState> emit) async {
    _currentCart = null;
    _currentRestaurantId = null;
    emit(const CartInitial());
  }
}
