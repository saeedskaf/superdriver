class Cart {
  final int id;
  final CartRestaurant? restaurant;
  final List<CartItem> items;
  final int itemsCount;
  final int? coupon;
  final String? couponCode;
  final String? notes;
  final String subtotal;
  final String deliveryFee;
  final String discountAmount;
  final String total;
  final DateTime? expiresAt;
  final bool? isExpired;
  final int? timeRemainingSeconds;
  final DateTime createdAt;
  final DateTime updatedAt;

  Cart({
    required this.id,
    this.restaurant,
    required this.items,
    required this.itemsCount,
    this.coupon,
    this.couponCode,
    this.notes,
    required this.subtotal,
    required this.deliveryFee,
    required this.discountAmount,
    required this.total,
    this.expiresAt,
    this.isExpired,
    this.timeRemainingSeconds,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'] ?? 0,
      restaurant: json['restaurant'] != null
          ? CartRestaurant.fromJson(json['restaurant'])
          : null,
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => CartItem.fromJson(item))
              .toList() ??
          [],
      itemsCount: json['items_count'] ?? 0,
      coupon: json['coupon'],
      couponCode: json['coupon_code'],
      notes: json['notes'],
      subtotal: json['subtotal']?.toString() ?? '0',
      deliveryFee: json['delivery_fee']?.toString() ?? '0',
      discountAmount: json['discount_amount']?.toString() ?? '0',
      total: json['total']?.toString() ?? '0',
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'])
          : null,
      isExpired: json['is_expired'],
      timeRemainingSeconds: json['time_remaining_seconds'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  double get subtotalDouble => double.tryParse(subtotal) ?? 0;
  double get deliveryFeeDouble => double.tryParse(deliveryFee) ?? 0;
  double get discountAmountDouble => double.tryParse(discountAmount) ?? 0;
  double get totalDouble => double.tryParse(total) ?? 0;

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
  bool get hasCoupon => couponCode != null && couponCode!.isNotEmpty;
}

/// Response for all carts endpoint
class AllCartsResponse {
  final List<CartSummary> carts;
  final int count;
  final int maxAllowed;

  AllCartsResponse({
    required this.carts,
    required this.count,
    required this.maxAllowed,
  });

  factory AllCartsResponse.fromJson(Map<String, dynamic> json) {
    return AllCartsResponse(
      carts:
          (json['carts'] as List<dynamic>?)
              ?.map((item) => CartSummary.fromJson(item))
              .toList() ??
          [],
      count: json['count'] ?? 0,
      maxAllowed: json['max_allowed'] ?? 5,
    );
  }

  bool get isEmpty => carts.isEmpty;
  bool get isNotEmpty => carts.isNotEmpty;
  bool get hasReachedLimit => count >= maxAllowed;
}

/// Cart summary for the all carts list
class CartSummary {
  final int id;
  final int restaurantId;
  final String restaurantName;
  final String? restaurantLogo;
  final int itemsCount;
  final String total;
  final List<String> itemsPreview;
  final DateTime? expiresAt;
  final int? timeRemainingSeconds;
  final DateTime createdAt;
  final DateTime updatedAt;

  CartSummary({
    required this.id,
    required this.restaurantId,
    required this.restaurantName,
    this.restaurantLogo,
    required this.itemsCount,
    required this.total,
    required this.itemsPreview,
    this.expiresAt,
    this.timeRemainingSeconds,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CartSummary.fromJson(Map<String, dynamic> json) {
    return CartSummary(
      id: json['id'] ?? 0,
      restaurantId: json['restaurant_id'] ?? 0,
      restaurantName: json['restaurant_name'] ?? '',
      restaurantLogo: json['restaurant_logo'],
      itemsCount: json['items_count'] ?? 0,
      total: json['total']?.toString() ?? '0',
      itemsPreview:
          (json['items_preview'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'])
          : null,
      timeRemainingSeconds: json['time_remaining_seconds'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  double get totalDouble => double.tryParse(total) ?? 0;
}

class CartRestaurant {
  final int id;
  final String name;
  final String slug;
  final String? logo;
  final String restaurantType;

  CartRestaurant({
    required this.id,
    required this.name,
    required this.slug,
    this.logo,
    required this.restaurantType,
  });

  factory CartRestaurant.fromJson(Map<String, dynamic> json) {
    return CartRestaurant(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      logo: json['logo'],
      restaurantType: json['restaurant_type'] ?? 'food',
    );
  }
}

class CartItem {
  final int id;
  final CartProduct product;
  final CartVariation? variation;
  final int quantity;
  final String? specialInstructions;
  final String unitPrice;
  final String addonsTotal;
  final String totalPrice;
  final List<CartItemAddon> addons;
  final DateTime createdAt;

  CartItem({
    required this.id,
    required this.product,
    this.variation,
    required this.quantity,
    this.specialInstructions,
    required this.unitPrice,
    required this.addonsTotal,
    required this.totalPrice,
    required this.addons,
    required this.createdAt,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? 0,
      product: CartProduct.fromJson(json['product'] ?? {}),
      variation: json['variation'] != null
          ? CartVariation.fromJson(json['variation'])
          : null,
      quantity: json['quantity'] ?? 1,
      specialInstructions: json['special_instructions'],
      unitPrice: json['unit_price']?.toString() ?? '0',
      addonsTotal: json['addons_total']?.toString() ?? '0',
      totalPrice: json['total_price']?.toString() ?? '0',
      addons:
          (json['cart_item_addons'] as List<dynamic>?)
              ?.map((addon) => CartItemAddon.fromJson(addon))
              .toList() ??
          [],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  double get unitPriceDouble => double.tryParse(unitPrice) ?? 0;
  double get totalPriceDouble => double.tryParse(totalPrice) ?? 0;
}

class CartProduct {
  final int id;
  final String name;
  final String? image;
  final String basePrice;
  final String currentPrice;

  CartProduct({
    required this.id,
    required this.name,
    this.image,
    required this.basePrice,
    required this.currentPrice,
  });

  factory CartProduct.fromJson(Map<String, dynamic> json) {
    return CartProduct(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'],
      basePrice: json['base_price']?.toString() ?? '0',
      currentPrice: json['current_price']?.toString() ?? '0',
    );
  }

  double get currentPriceDouble => double.tryParse(currentPrice) ?? 0;
}

class CartVariation {
  final int id;
  final String name;
  final String? nameEn;
  final String priceAdjustment;
  final String totalPrice;
  final bool isAvailable;

  CartVariation({
    required this.id,
    required this.name,
    this.nameEn,
    required this.priceAdjustment,
    required this.totalPrice,
    required this.isAvailable,
  });

  factory CartVariation.fromJson(Map<String, dynamic> json) {
    return CartVariation(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      nameEn: json['name_en'],
      priceAdjustment: json['price_adjustment']?.toString() ?? '0',
      totalPrice: json['total_price']?.toString() ?? '0',
      isAvailable: json['is_available'] ?? true,
    );
  }
}

class CartItemAddon {
  final int id;
  final int addonId;
  final String addonName;
  final String addonPrice;
  final int quantity;
  final String totalPrice;

  CartItemAddon({
    required this.id,
    required this.addonId,
    required this.addonName,
    required this.addonPrice,
    required this.quantity,
    required this.totalPrice,
  });

  factory CartItemAddon.fromJson(Map<String, dynamic> json) {
    return CartItemAddon(
      id: json['id'] ?? 0,
      addonId: json['addon'] ?? 0,
      addonName: json['addon_name'] ?? '',
      addonPrice: json['addon_price']?.toString() ?? '0',
      quantity: json['quantity'] ?? 1,
      totalPrice: json['total_price']?.toString() ?? '0',
    );
  }
}

class AddToCartRequest {
  final int restaurantId;
  final int productId;
  final int quantity;
  final int? variationId;
  final List<Map<String, dynamic>>? addons;
  final String? specialInstructions;

  AddToCartRequest({
    required this.restaurantId,
    required this.productId,
    this.quantity = 1,
    this.variationId,
    this.addons,
    this.specialInstructions,
  });

  Map<String, dynamic> toJson() {
    return {
      'restaurant_id': restaurantId,
      'product_id': productId,
      'quantity': quantity,
      if (variationId != null) 'variation_id': variationId,
      if (addons != null && addons!.isNotEmpty) 'addons': addons,
      if (specialInstructions != null && specialInstructions!.isNotEmpty)
        'special_instructions': specialInstructions,
    };
  }
}
