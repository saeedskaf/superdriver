/// Restaurant detail model (full info with working hours)
class RestaurantDetail {
  final int id;
  final String name;
  final String? nameEn;
  final String slug;
  final String? description;
  final String? logo;
  final String? coverImage;
  final String restaurantType;
  final int? categoryId;
  final String? categoryName;
  final String? address;
  final String? latitude;
  final String? longitude;
  final String? phone;
  final bool isActive;
  final bool isOpen;
  final bool isCurrentlyOpen;
  final String? openingTime;
  final String? closingTime;
  final String minimumOrderAmount;
  final String deliveryFee;
  final String? deliveryTimeEstimate;
  final bool hasDiscount;
  final String? discountPercentage;
  final String? currentDiscount;
  final String? discountStartTime;
  final String? discountEndTime;
  final String averageRating;
  final int totalReviews;
  final int totalOrders;
  final bool isFeatured;
  final List<WorkingHours> workingHours;
  final DateTime createdAt;

  RestaurantDetail({
    required this.id,
    required this.name,
    this.nameEn,
    required this.slug,
    this.description,
    this.logo,
    this.coverImage,
    required this.restaurantType,
    this.categoryId,
    this.categoryName,
    this.address,
    this.latitude,
    this.longitude,
    this.phone,
    required this.isActive,
    required this.isOpen,
    required this.isCurrentlyOpen,
    this.openingTime,
    this.closingTime,
    required this.minimumOrderAmount,
    required this.deliveryFee,
    this.deliveryTimeEstimate,
    required this.hasDiscount,
    this.discountPercentage,
    this.currentDiscount,
    this.discountStartTime,
    this.discountEndTime,
    required this.averageRating,
    required this.totalReviews,
    required this.totalOrders,
    required this.isFeatured,
    required this.workingHours,
    required this.createdAt,
  });

  factory RestaurantDetail.fromJson(Map<String, dynamic> json) {
    return RestaurantDetail(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      nameEn: json['name_en'],
      slug: json['slug'] ?? '',
      description: json['description'],
      logo: json['logo'],
      coverImage: json['cover_image'],
      restaurantType: json['restaurant_type'] ?? 'food',
      categoryId: json['category'],
      categoryName: json['category_name'],
      address: json['address'],
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      phone: json['phone'],
      isActive: json['is_active'] ?? false,
      isOpen: json['is_open'] ?? false,
      isCurrentlyOpen: json['is_currently_open'] ?? false,
      openingTime: json['opening_time'],
      closingTime: json['closing_time'],
      minimumOrderAmount: json['minimum_order_amount']?.toString() ?? '0',
      deliveryFee: json['delivery_fee']?.toString() ?? '0',
      deliveryTimeEstimate: json['delivery_time_estimate'],
      hasDiscount: json['has_discount'] ?? false,
      discountPercentage: json['discount_percentage']?.toString(),
      currentDiscount: json['current_discount']?.toString(),
      discountStartTime: json['discount_start_time'],
      discountEndTime: json['discount_end_time'],
      averageRating: json['average_rating']?.toString() ?? '0',
      totalReviews: json['total_reviews'] ?? 0,
      totalOrders: json['total_orders'] ?? 0,
      isFeatured: json['is_featured'] ?? false,
      workingHours: (json['working_hours'] as List<dynamic>?)
              ?.map((e) => WorkingHours.fromJson(e))
              .toList() ??
          [],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  double get deliveryFeeDouble => double.tryParse(deliveryFee) ?? 0;
  double get minimumOrderDouble => double.tryParse(minimumOrderAmount) ?? 0;
  double get ratingDouble => double.tryParse(averageRating) ?? 0;
  double get discountDouble => double.tryParse(currentDiscount ?? '0') ?? 0;
}

/// Working hours model
class WorkingHours {
  final int id;
  final int day;
  final String dayName;
  final String openingTime;
  final String closingTime;
  final bool isClosed;

  WorkingHours({
    required this.id,
    required this.day,
    required this.dayName,
    required this.openingTime,
    required this.closingTime,
    required this.isClosed,
  });

  factory WorkingHours.fromJson(Map<String, dynamic> json) {
    return WorkingHours(
      id: json['id'] ?? 0,
      day: json['day'] ?? 0,
      dayName: json['day_name'] ?? '',
      openingTime: json['opening_time'] ?? '',
      closingTime: json['closing_time'] ?? '',
      isClosed: json['is_closed'] ?? false,
    );
  }
}

/// Restaurant category model
class RestaurantCategory {
  final int id;
  final String name;
  final String? nameEn;
  final String slug;
  final String? icon;
  final String? image;
  final bool isActive;
  final int order;
  final int restaurantsCount;

  RestaurantCategory({
    required this.id,
    required this.name,
    this.nameEn,
    required this.slug,
    this.icon,
    this.image,
    required this.isActive,
    required this.order,
    required this.restaurantsCount,
  });

  factory RestaurantCategory.fromJson(Map<String, dynamic> json) {
    return RestaurantCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      nameEn: json['name_en'],
      slug: json['slug'] ?? '',
      icon: json['icon'],
      image: json['image'],
      isActive: json['is_active'] ?? false,
      order: json['order'] ?? 0,
      restaurantsCount: json['restaurants_count'] ?? 0,
    );
  }
}

/// Restaurant list item (simplified for lists)
class RestaurantListItem {
  final int id;
  final String name;
  final String? nameEn;
  final String slug;
  final String? logo;
  final String restaurantType;
  final int? categoryId;
  final String? categoryName;
  final bool isActive;
  final bool isOpen;
  final bool isCurrentlyOpen;
  final String minimumOrderAmount;
  final String deliveryFee;
  final String? deliveryTimeEstimate;
  final bool hasDiscount;
  final String? currentDiscount;
  final String averageRating;
  final int totalReviews;
  final int totalOrders;
  final bool isFeatured;

  RestaurantListItem({
    required this.id,
    required this.name,
    this.nameEn,
    required this.slug,
    this.logo,
    required this.restaurantType,
    this.categoryId,
    this.categoryName,
    required this.isActive,
    required this.isOpen,
    required this.isCurrentlyOpen,
    required this.minimumOrderAmount,
    required this.deliveryFee,
    this.deliveryTimeEstimate,
    required this.hasDiscount,
    this.currentDiscount,
    required this.averageRating,
    required this.totalReviews,
    required this.totalOrders,
    required this.isFeatured,
  });

  factory RestaurantListItem.fromJson(Map<String, dynamic> json) {
    return RestaurantListItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      nameEn: json['name_en'],
      slug: json['slug'] ?? '',
      logo: json['logo'],
      restaurantType: json['restaurant_type'] ?? 'food',
      categoryId: json['category'],
      categoryName: json['category_name'],
      isActive: json['is_active'] ?? false,
      isOpen: json['is_open'] ?? false,
      isCurrentlyOpen: json['is_currently_open'] ?? false,
      minimumOrderAmount: json['minimum_order_amount']?.toString() ?? '0',
      deliveryFee: json['delivery_fee']?.toString() ?? '0',
      deliveryTimeEstimate: json['delivery_time_estimate'],
      hasDiscount: json['has_discount'] ?? false,
      currentDiscount: json['current_discount']?.toString(),
      averageRating: json['average_rating']?.toString() ?? '0',
      totalReviews: json['total_reviews'] ?? 0,
      totalOrders: json['total_orders'] ?? 0,
      isFeatured: json['is_featured'] ?? false,
    );
  }

  double get deliveryFeeDouble => double.tryParse(deliveryFee) ?? 0;
  double get minimumOrderDouble => double.tryParse(minimumOrderAmount) ?? 0;
  double get ratingDouble => double.tryParse(averageRating) ?? 0;
  double get discountDouble => double.tryParse(currentDiscount ?? '0') ?? 0;
}

/// Restaurant filter params
class RestaurantFilterParams {
  final int? categoryId;
  final bool? hasDiscount;
  final bool? isFeatured;
  final bool? isOpen;
  final String? ordering;
  final String? restaurantType;
  final String? type;
  final String? search;

  RestaurantFilterParams({
    this.categoryId,
    this.hasDiscount,
    this.isFeatured,
    this.isOpen,
    this.ordering,
    this.restaurantType,
    this.type,
    this.search,
  });

  Map<String, String> toQueryParams() {
    final params = <String, String>{};
    if (categoryId != null) params['category'] = categoryId.toString();
    if (hasDiscount != null) params['has_discount'] = hasDiscount.toString();
    if (isFeatured != null) params['is_featured'] = isFeatured.toString();
    if (isOpen != null) params['is_open'] = isOpen.toString();
    if (ordering != null) params['ordering'] = ordering!;
    if (restaurantType != null) params['restaurant_type'] = restaurantType!;
    if (type != null) params['type'] = type!;
    if (search != null && search!.isNotEmpty) params['search'] = search!;
    return params;
  }
}
