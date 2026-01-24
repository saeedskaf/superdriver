class Order {
  final int id;
  final String orderNumber;
  final String status;
  final String statusDisplay;
  final int restaurantId;
  final String restaurantName;
  final String? restaurantLogo;
  final int? driverId;
  final String? driverName;
  final String? driverPhone;
  final String paymentMethod;
  final String paymentMethodDisplay;
  final String paymentStatus;
  final String paymentStatusDisplay;
  final String subtotal;
  final String deliveryFee;
  final String discountAmount;
  final String total;
  final int? coupon;
  final String itemsCount;
  final bool canCancel;
  final bool canReview;
  final String? restaurantSnapshot;
  final String? addressSnapshot;
  final String? itemsSnapshot;
  final String? notes;
  final String? specialInstructions;
  final DateTime? placedAt;
  final DateTime? acceptedAt;
  final DateTime? preparingAt;
  final DateTime? readyAt;
  final DateTime? pickedAt;
  final DateTime? deliveredAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final DateTime? estimatedDeliveryTime;
  final String? cancellationReason;
  final List<OrderItem> items;
  final List<OrderStatusHistory> statusHistory;
  final String? trackingInfo;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.statusDisplay,
    required this.restaurantId,
    required this.restaurantName,
    this.restaurantLogo,
    this.driverId,
    this.driverName,
    this.driverPhone,
    required this.paymentMethod,
    required this.paymentMethodDisplay,
    required this.paymentStatus,
    required this.paymentStatusDisplay,
    required this.subtotal,
    required this.deliveryFee,
    required this.discountAmount,
    required this.total,
    this.coupon,
    required this.itemsCount,
    required this.canCancel,
    required this.canReview,
    this.restaurantSnapshot,
    this.addressSnapshot,
    this.itemsSnapshot,
    this.notes,
    this.specialInstructions,
    this.placedAt,
    this.acceptedAt,
    this.preparingAt,
    this.readyAt,
    this.pickedAt,
    this.deliveredAt,
    this.completedAt,
    this.cancelledAt,
    this.estimatedDeliveryTime,
    this.cancellationReason,
    required this.items,
    required this.statusHistory,
    this.trackingInfo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? 0,
      orderNumber: json['order_number'] ?? '',
      status: json['status'] ?? 'draft',
      statusDisplay: json['status_display'] ?? '',
      restaurantId: json['restaurant'] ?? 0,
      restaurantName: json['restaurant_name'] ?? '',
      restaurantLogo: json['restaurant_logo'],
      driverId: json['driver'],
      driverName: json['driver_name'],
      driverPhone: json['driver_phone'],
      paymentMethod: json['payment_method'] ?? 'cash',
      paymentMethodDisplay: json['payment_method_display'] ?? '',
      paymentStatus: json['payment_status'] ?? 'pending',
      paymentStatusDisplay: json['payment_status_display'] ?? '',
      subtotal: json['subtotal']?.toString() ?? '0',
      deliveryFee: json['delivery_fee']?.toString() ?? '0',
      discountAmount: json['discount_amount']?.toString() ?? '0',
      total: json['total']?.toString() ?? '0',
      coupon: json['coupon'],
      itemsCount: json['items_count']?.toString() ?? '0',
      canCancel: _parseBool(json['can_cancel']),
      canReview: _parseBool(json['can_review']),
      restaurantSnapshot: json['restaurant_snapshot'],
      addressSnapshot: json['address_snapshot'],
      itemsSnapshot: json['items_snapshot'],
      notes: json['notes'],
      specialInstructions: json['special_instructions'],
      placedAt: _parseDateTime(json['placed_at']),
      acceptedAt: _parseDateTime(json['accepted_at']),
      preparingAt: _parseDateTime(json['preparing_at']),
      readyAt: _parseDateTime(json['ready_at']),
      pickedAt: _parseDateTime(json['picked_at']),
      deliveredAt: _parseDateTime(json['delivered_at']),
      completedAt: _parseDateTime(json['completed_at']),
      cancelledAt: _parseDateTime(json['cancelled_at']),
      estimatedDeliveryTime: _parseDateTime(json['estimated_delivery_time']),
      cancellationReason: json['cancellation_reason'],
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ??
          [],
      statusHistory: (json['status_history'] as List<dynamic>?)
              ?.map((item) => OrderStatusHistory.fromJson(item))
              .toList() ??
          [],
      trackingInfo: json['tracking_info'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  double get totalDouble => double.tryParse(total) ?? 0;
  double get subtotalDouble => double.tryParse(subtotal) ?? 0;
  double get deliveryFeeDouble => double.tryParse(deliveryFee) ?? 0;
  double get discountAmountDouble => double.tryParse(discountAmount) ?? 0;

  bool get isActive => !['completed', 'cancelled', 'delivered'].contains(status);
  bool get isCompleted => status == 'completed' || status == 'delivered';
  bool get isCancelled => status == 'cancelled';
}

class OrderItem {
  final int id;
  final int productId;
  final String productName;
  final String? productImage;
  final int? variationId;
  final String? variationName;
  final int quantity;
  final String unitPrice;
  final String totalPrice;
  final String? specialInstructions;
  final String? productSnapshot;
  final List<OrderItemAddon> addons;

  OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImage,
    this.variationId,
    this.variationName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.specialInstructions,
    this.productSnapshot,
    required this.addons,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? 0,
      productId: json['product'] ?? 0,
      productName: json['product_name'] ?? '',
      productImage: json['product_image'],
      variationId: json['variation'],
      variationName: json['variation_name'],
      quantity: json['quantity'] ?? 1,
      unitPrice: json['unit_price']?.toString() ?? '0',
      totalPrice: json['total_price']?.toString() ?? '0',
      specialInstructions: json['special_instructions'],
      productSnapshot: json['product_snapshot'],
      addons: (json['addons'] as List<dynamic>?)
              ?.map((addon) => OrderItemAddon.fromJson(addon))
              .toList() ??
          [],
    );
  }

  double get unitPriceDouble => double.tryParse(unitPrice) ?? 0;
  double get totalPriceDouble => double.tryParse(totalPrice) ?? 0;
}

class OrderItemAddon {
  final int id;
  final int addonId;
  final String addonName;
  final int quantity;
  final String price;
  final String totalPrice;

  OrderItemAddon({
    required this.id,
    required this.addonId,
    required this.addonName,
    required this.quantity,
    required this.price,
    required this.totalPrice,
  });

  factory OrderItemAddon.fromJson(Map<String, dynamic> json) {
    return OrderItemAddon(
      id: json['id'] ?? 0,
      addonId: json['addon'] ?? 0,
      addonName: json['addon_name'] ?? '',
      quantity: json['quantity'] ?? 1,
      price: json['price']?.toString() ?? '0',
      totalPrice: json['total_price']?.toString() ?? '0',
    );
  }
}

class OrderStatusHistory {
  final int id;
  final String fromStatus;
  final String fromStatusDisplay;
  final String toStatus;
  final String toStatusDisplay;
  final int? changedBy;
  final String? changedByName;
  final String? notes;
  final DateTime createdAt;

  OrderStatusHistory({
    required this.id,
    required this.fromStatus,
    required this.fromStatusDisplay,
    required this.toStatus,
    required this.toStatusDisplay,
    this.changedBy,
    this.changedByName,
    this.notes,
    required this.createdAt,
  });

  factory OrderStatusHistory.fromJson(Map<String, dynamic> json) {
    return OrderStatusHistory(
      id: json['id'] ?? 0,
      fromStatus: json['from_status'] ?? '',
      fromStatusDisplay: json['from_status_display'] ?? '',
      toStatus: json['to_status'] ?? '',
      toStatusDisplay: json['to_status_display'] ?? '',
      changedBy: json['changed_by'],
      changedByName: json['changed_by_name'],
      notes: json['notes'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}

class OrderListItem {
  final int id;
  final String orderNumber;
  final String status;
  final String statusDisplay;
  final int restaurantId;
  final String restaurantName;
  final String? restaurantLogo;
  final String total;
  final String itemsCount;
  final String paymentMethod;
  final String paymentMethodDisplay;
  final DateTime createdAt;
  final DateTime? placedAt;
  final DateTime? deliveredAt;

  OrderListItem({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.statusDisplay,
    required this.restaurantId,
    required this.restaurantName,
    this.restaurantLogo,
    required this.total,
    required this.itemsCount,
    required this.paymentMethod,
    required this.paymentMethodDisplay,
    required this.createdAt,
    this.placedAt,
    this.deliveredAt,
  });

  factory OrderListItem.fromJson(Map<String, dynamic> json) {
    return OrderListItem(
      id: json['id'] ?? 0,
      orderNumber: json['order_number'] ?? '',
      status: json['status'] ?? 'draft',
      statusDisplay: json['status_display'] ?? '',
      restaurantId: json['restaurant'] ?? 0,
      restaurantName: json['restaurant_name'] ?? '',
      restaurantLogo: json['restaurant_logo'],
      total: json['total']?.toString() ?? '0',
      itemsCount: json['items_count']?.toString() ?? '0',
      paymentMethod: json['payment_method'] ?? 'cash',
      paymentMethodDisplay: json['payment_method_display'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      placedAt: json['placed_at'] != null
          ? DateTime.tryParse(json['placed_at'])
          : null,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.tryParse(json['delivered_at'])
          : null,
    );
  }

  double get totalDouble => double.tryParse(total) ?? 0;
  bool get isActive => !['completed', 'cancelled', 'delivered'].contains(status);
  bool get isCompleted => status == 'completed' || status == 'delivered';
  bool get isCancelled => status == 'cancelled';
}

class CreateOrderRequest {
  final int deliveryAddressId;
  final String paymentMethod;
  final String? notes;

  CreateOrderRequest({
    required this.deliveryAddressId,
    this.paymentMethod = 'cash',
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'delivery_address_id': deliveryAddressId,
      'payment_method': paymentMethod,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
    };
  }
}
