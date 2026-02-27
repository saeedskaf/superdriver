import 'package:superdriver/data/env/environment.dart';

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
  final bool isDriverRated;
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
  final RestaurantSnapshot? restaurantSnapshot;
  final AddressSnapshot? addressSnapshot;
  final List<ItemSnapshot>? itemsSnapshot;
  final String? notes;
  final String? specialInstructions;
  final String? contactPhone;
  final bool isScheduled;
  final DateTime? scheduledDeliveryTime;
  final DateTime? placedAt;
  final DateTime? preparingAt;
  final DateTime? pickedAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final DateTime? estimatedDeliveryTime;
  final String? cancellationReason;
  final List<OrderItem> items;
  final List<OrderStatusHistory> statusHistory;
  final TrackingInfo? trackingInfo;
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
    this.isDriverRated = false,
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
    this.contactPhone,
    required this.isScheduled,
    this.scheduledDeliveryTime,
    this.placedAt,
    this.preparingAt,
    this.pickedAt,
    this.deliveredAt,
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
      restaurantLogo: _fixImageUrl(json['restaurant_logo']),
      driverId: json['driver'],
      driverName: json['driver_name'],
      driverPhone: json['driver_phone'],
      isDriverRated: json['is_driver_rated'] == true,
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
      restaurantSnapshot: json['restaurant_snapshot'] != null
          ? RestaurantSnapshot.fromJson(json['restaurant_snapshot'])
          : null,
      addressSnapshot: json['address_snapshot'] != null
          ? AddressSnapshot.fromJson(json['address_snapshot'])
          : null,
      itemsSnapshot: json['items_snapshot'] != null
          ? (json['items_snapshot'] as List)
                .map((item) => ItemSnapshot.fromJson(item))
                .toList()
          : null,
      notes: json['notes'],
      specialInstructions: json['special_instructions'],
      contactPhone: json['contact_phone'],
      isScheduled: json['is_scheduled'] ?? false,
      scheduledDeliveryTime: _parseDateTime(json['scheduled_delivery_time']),
      placedAt: _parseDateTime(json['placed_at']),
      preparingAt: _parseDateTime(json['preparing_at']),
      pickedAt: _parseDateTime(json['picked_at']),
      deliveredAt: _parseDateTime(json['delivered_at']),
      cancelledAt: _parseDateTime(json['cancelled_at']),
      estimatedDeliveryTime: _parseDateTime(json['estimated_delivery_time']),
      cancellationReason: json['cancellation_reason'],
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ??
          [],
      statusHistory:
          (json['status_history'] as List<dynamic>?)
              ?.map((item) => OrderStatusHistory.fromJson(item))
              .toList() ??
          [],
      trackingInfo: json['tracking_info'] != null
          ? TrackingInfo.fromJson(json['tracking_info'])
          : null,
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

  /// Fix relative URLs by prepending base URL from Environment
  static String? _fixImageUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    if (url.startsWith('/')) {
      return '${Environment.baseUrl}$url';
    }
    return '${Environment.baseUrl}/$url';
  }

  double get totalDouble => double.tryParse(total) ?? 0;
  double get subtotalDouble => double.tryParse(subtotal) ?? 0;
  double get deliveryFeeDouble => double.tryParse(deliveryFee) ?? 0;
  double get discountAmountDouble => double.tryParse(discountAmount) ?? 0;

  bool get isActive => !['delivered', 'cancelled'].contains(status);
  bool get isCompleted => status == 'delivered';
  bool get isCancelled => status == 'cancelled';

  /// Check if order can be cancelled (only draft and placed statuses)
  bool get canBeCancelled => canCancel && ['draft', 'placed'].contains(status);
}

class RestaurantSnapshot {
  final int id;
  final String name;
  final String? nameEn;
  final String? logo;
  final String? phone;
  final String? address;
  final String? deliveryTimeEstimate;

  RestaurantSnapshot({
    required this.id,
    required this.name,
    this.nameEn,
    this.logo,
    this.phone,
    this.address,
    this.deliveryTimeEstimate,
  });

  factory RestaurantSnapshot.fromJson(Map<String, dynamic> json) {
    return RestaurantSnapshot(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      nameEn: json['name_en'],
      logo: Order._fixImageUrl(json['logo']),
      phone: json['phone'],
      address: json['address'],
      deliveryTimeEstimate: json['delivery_time_estimate'],
    );
  }
}

class AddressSnapshot {
  final int id;
  final String title;
  final String governorate;
  final String area;
  final String street;
  final String? buildingNumber;
  final String? floor;
  final String? apartment;
  final String? landmark;
  final String fullAddress;
  final String? latitude;
  final String? longitude;

  AddressSnapshot({
    required this.id,
    required this.title,
    required this.governorate,
    required this.area,
    required this.street,
    this.buildingNumber,
    this.floor,
    this.apartment,
    this.landmark,
    required this.fullAddress,
    this.latitude,
    this.longitude,
  });

  factory AddressSnapshot.fromJson(Map<String, dynamic> json) {
    return AddressSnapshot(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      governorate: json['governorate'] ?? '',
      area: json['area'] ?? '',
      street: json['street'] ?? '',
      buildingNumber: json['building_number'],
      floor: json['floor'],
      apartment: json['apartment'],
      landmark: json['landmark'],
      fullAddress: json['full_address'] ?? '',
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  /// Get formatted address for display
  String get formattedAddress {
    List<String> parts = [];

    if (governorate.isNotEmpty) parts.add(governorate);
    if (area.isNotEmpty) parts.add(area);
    if (street.isNotEmpty) parts.add(street);

    return parts.join('، ');
  }

  /// Get building details if available
  String? get buildingDetails {
    List<String> details = [];

    if (buildingNumber != null && buildingNumber!.isNotEmpty) {
      details.add('مبنى $buildingNumber');
    }
    if (floor != null && floor!.isNotEmpty) {
      details.add('طابق $floor');
    }
    if (apartment != null && apartment!.isNotEmpty) {
      details.add('شقة $apartment');
    }

    return details.isNotEmpty ? details.join(' - ') : null;
  }
}

class ItemSnapshot {
  final int productId;
  final String productName;
  final String? productImage;
  final String basePrice;
  final String currentPrice;
  final int quantity;
  final dynamic variation;
  final List<dynamic> addons;
  final String? specialInstructions;
  final String unitPrice;
  final String totalPrice;

  ItemSnapshot({
    required this.productId,
    required this.productName,
    this.productImage,
    required this.basePrice,
    required this.currentPrice,
    required this.quantity,
    this.variation,
    required this.addons,
    this.specialInstructions,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory ItemSnapshot.fromJson(Map<String, dynamic> json) {
    return ItemSnapshot(
      productId: json['product_id'] ?? 0,
      productName: json['product_name'] ?? '',
      productImage: json['product_image'],
      basePrice: json['base_price']?.toString() ?? '0',
      currentPrice: json['current_price']?.toString() ?? '0',
      quantity: json['quantity'] ?? 1,
      variation: json['variation'],
      addons: json['addons'] ?? [],
      specialInstructions: json['special_instructions'],
      unitPrice: json['unit_price']?.toString() ?? '0',
      totalPrice: json['total_price']?.toString() ?? '0',
    );
  }
}

class TrackingInfo {
  final String orderNumber;
  final String status;
  final String statusDisplay;
  final DateTime? placedAt;
  final DateTime? preparingAt;
  final DateTime? pickedAt;
  final DateTime? deliveredAt;
  final DateTime? estimatedDeliveryTime;
  final bool isScheduled;
  final DateTime? scheduledDeliveryTime;
  final dynamic driver;

  TrackingInfo({
    required this.orderNumber,
    required this.status,
    required this.statusDisplay,
    this.placedAt,
    this.preparingAt,
    this.pickedAt,
    this.deliveredAt,
    this.estimatedDeliveryTime,
    required this.isScheduled,
    this.scheduledDeliveryTime,
    this.driver,
  });

  factory TrackingInfo.fromJson(Map<String, dynamic> json) {
    return TrackingInfo(
      orderNumber: json['order_number'] ?? '',
      status: json['status'] ?? '',
      statusDisplay: json['status_display'] ?? '',
      placedAt: json['placed_at'] != null
          ? DateTime.tryParse(json['placed_at'])
          : null,
      preparingAt: json['preparing_at'] != null
          ? DateTime.tryParse(json['preparing_at'])
          : null,
      pickedAt: json['picked_at'] != null
          ? DateTime.tryParse(json['picked_at'])
          : null,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.tryParse(json['delivered_at'])
          : null,
      estimatedDeliveryTime: json['estimated_delivery_time'] != null
          ? DateTime.tryParse(json['estimated_delivery_time'])
          : null,
      isScheduled: json['is_scheduled'] ?? false,
      scheduledDeliveryTime: json['scheduled_delivery_time'] != null
          ? DateTime.tryParse(json['scheduled_delivery_time'])
          : null,
      driver: json['driver'],
    );
  }
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
  final ProductSnapshot? productSnapshot;
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
      productSnapshot: json['product_snapshot'] != null
          ? ProductSnapshot.fromJson(json['product_snapshot'])
          : null,
      addons:
          (json['addons'] as List<dynamic>?)
              ?.map((addon) => OrderItemAddon.fromJson(addon))
              .toList() ??
          [],
    );
  }

  double get unitPriceDouble => double.tryParse(unitPrice) ?? 0;
  double get totalPriceDouble => double.tryParse(totalPrice) ?? 0;
}

class ProductSnapshot {
  final int id;
  final String name;
  final String? nameEn;
  final String? image;
  final String basePrice;

  ProductSnapshot({
    required this.id,
    required this.name,
    this.nameEn,
    this.image,
    required this.basePrice,
  });

  factory ProductSnapshot.fromJson(Map<String, dynamic> json) {
    return ProductSnapshot(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      nameEn: json['name_en'],
      image: json['image'],
      basePrice: json['base_price']?.toString() ?? '0',
    );
  }
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
  final bool isScheduled;
  final DateTime? scheduledDeliveryTime;
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
    required this.isScheduled,
    this.scheduledDeliveryTime,
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
      restaurantLogo: Order._fixImageUrl(json['restaurant_logo']),
      total: json['total']?.toString() ?? '0',
      itemsCount: json['items_count']?.toString() ?? '0',
      paymentMethod: json['payment_method'] ?? 'cash',
      paymentMethodDisplay: json['payment_method_display'] ?? '',
      isScheduled: json['is_scheduled'] ?? false,
      scheduledDeliveryTime: json['scheduled_delivery_time'] != null
          ? DateTime.tryParse(json['scheduled_delivery_time'])
          : null,
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
  bool get isActive => !['delivered', 'cancelled'].contains(status);
  bool get isCompleted => status == 'delivered';
  bool get isCancelled => status == 'cancelled';
}

class CreateOrderRequest {
  final int cartId;
  final int deliveryAddressId;
  final String paymentMethod;
  final String? contactPhone;
  final DateTime? scheduledDeliveryTime;
  final String? notes;

  CreateOrderRequest({
    required this.cartId,
    required this.deliveryAddressId,
    this.paymentMethod = 'cash',
    this.contactPhone,
    this.scheduledDeliveryTime,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'cart_id': cartId,
      'delivery_address_id': deliveryAddressId,
      'payment_method': paymentMethod,
      if (contactPhone != null && contactPhone!.isNotEmpty)
        'contact_phone': contactPhone,
      if (scheduledDeliveryTime != null)
        'scheduled_delivery_time': scheduledDeliveryTime!.toIso8601String(),
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
    };
  }
}
