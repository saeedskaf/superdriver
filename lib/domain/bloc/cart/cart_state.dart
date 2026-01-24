part of 'cart_bloc.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {
  const CartInitial();
}

class CartLoading extends CartState {
  const CartLoading();
}

class CartLoaded extends CartState {
  final Cart cart;

  const CartLoaded({required this.cart});

  @override
  List<Object?> get props => [cart];
}

/// State for when all carts are loaded
class CartAllLoaded extends CartState {
  final List<CartSummary> carts;
  final int count;
  final int maxAllowed;

  const CartAllLoaded({
    required this.carts,
    required this.count,
    required this.maxAllowed,
  });

  @override
  List<Object?> get props => [carts, count, maxAllowed];

  bool get isEmpty => carts.isEmpty;
  bool get isNotEmpty => carts.isNotEmpty;
  bool get hasReachedLimit => count >= maxAllowed;
}

class CartEmpty extends CartState {
  const CartEmpty();
}

class CartError extends CartState {
  final String message;

  const CartError(this.message);

  @override
  List<Object?> get props => [message];
}

class CartItemUpdating extends CartState {
  final Cart cart;
  final int updatingItemId;

  const CartItemUpdating({required this.cart, required this.updatingItemId});

  @override
  List<Object?> get props => [cart, updatingItemId];
}

class CartOperationSuccess extends CartState {
  final Cart cart;
  final String message;

  const CartOperationSuccess({required this.cart, required this.message});

  @override
  List<Object?> get props => [cart, message];
}

class CartCouponApplied extends CartState {
  final Cart cart;
  final String couponCode;

  const CartCouponApplied({required this.cart, required this.couponCode});

  @override
  List<Object?> get props => [cart, couponCode];
}

class CartCouponRemoved extends CartState {
  final Cart cart;

  const CartCouponRemoved({required this.cart});

  @override
  List<Object?> get props => [cart];
}

class CartValidated extends CartState {
  final Cart cart;

  const CartValidated({required this.cart});

  @override
  List<Object?> get props => [cart];
}

class CartValidationFailed extends CartState {
  final Cart cart;
  final String message;

  const CartValidationFailed({required this.cart, required this.message});

  @override
  List<Object?> get props => [cart, message];
}

class CartCleared extends CartState {
  const CartCleared();
}

/// State for when cart is completely deleted
class CartDeleted extends CartState {
  const CartDeleted();
}
