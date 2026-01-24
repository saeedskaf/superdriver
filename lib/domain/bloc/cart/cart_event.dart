part of 'cart_bloc.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

/// Load cart by cart_id or restaurant_id
class CartLoadRequested extends CartEvent {
  final int? cartId;
  final int? restaurantId;

  const CartLoadRequested({this.cartId, this.restaurantId});

  @override
  List<Object?> get props => [cartId, restaurantId];
}

/// Load all active carts
class CartLoadAllRequested extends CartEvent {
  const CartLoadAllRequested();
}

/// Add item to cart
class CartAddItemRequested extends CartEvent {
  final int restaurantId;
  final int productId;
  final int quantity;
  final int? variationId;
  final List<Map<String, dynamic>>? addons;
  final String? specialInstructions;

  const CartAddItemRequested({
    required this.restaurantId,
    required this.productId,
    this.quantity = 1,
    this.variationId,
    this.addons,
    this.specialInstructions,
  });

  @override
  List<Object?> get props => [
    restaurantId,
    productId,
    quantity,
    variationId,
    addons,
    specialInstructions,
  ];
}

/// Update cart item
class CartUpdateItemRequested extends CartEvent {
  final int itemId;
  final int quantity;
  final String? specialInstructions;

  const CartUpdateItemRequested({
    required this.itemId,
    required this.quantity,
    this.specialInstructions,
  });

  @override
  List<Object?> get props => [itemId, quantity, specialInstructions];
}

/// Remove item from cart
class CartRemoveItemRequested extends CartEvent {
  final int itemId;

  const CartRemoveItemRequested({required this.itemId});

  @override
  List<Object?> get props => [itemId];
}

/// Clear cart (removes all items but keeps cart)
class CartClearRequested extends CartEvent {
  final int cartId;

  const CartClearRequested({required this.cartId});

  @override
  List<Object?> get props => [cartId];
}

/// Delete cart completely
class CartDeleteRequested extends CartEvent {
  final int cartId;

  const CartDeleteRequested({required this.cartId});

  @override
  List<Object?> get props => [cartId];
}

/// Apply coupon to cart
class CartApplyCouponRequested extends CartEvent {
  final int cartId;
  final String couponCode;

  const CartApplyCouponRequested({
    required this.cartId,
    required this.couponCode,
  });

  @override
  List<Object?> get props => [cartId, couponCode];
}

/// Remove coupon from cart
class CartRemoveCouponRequested extends CartEvent {
  final int cartId;

  const CartRemoveCouponRequested({required this.cartId});

  @override
  List<Object?> get props => [cartId];
}

/// Validate cart for checkout
class CartValidateRequested extends CartEvent {
  final int cartId;

  const CartValidateRequested({required this.cartId});

  @override
  List<Object?> get props => [cartId];
}

/// Reset cart state
class CartReset extends CartEvent {
  const CartReset();
}
