import 'package:equatable/equatable.dart';

/// Helper function to parse double from various types
double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    return double.tryParse(value) ?? 0.0;
  }
  return 0.0;
}

// ============================================================
// RESTAURANT CATEGORY ITEM (new — for categories_data list)
// ============================================================

class RestaurantCategoryItem extends Equatable {
  final int category;
  final String categoryName;
  final String categoryNameEn;

  const RestaurantCategoryItem({
    required this.category,
    required this.categoryName,
    required this.categoryNameEn,
  });

  factory RestaurantCategoryItem.fromJson(Map<String, dynamic> json) {
    return RestaurantCategoryItem(
      category: json['category'] ?? 0,
      categoryName: json['category_name'] ?? '',
      categoryNameEn: json['category_name_en'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'category_name': categoryName,
      'category_name_en': categoryNameEn,
    };
  }

  @override
  List<Object?> get props => [category, categoryName, categoryNameEn];
}

// ============================================================
// RESTAURANT DETAIL (full info with working hours)
// ============================================================

class RestaurantDetail extends Equatable {
  final int id;
  final String name;
  final String? nameEn;
  final String slug;
  final String? description;
  final String? descriptionEn;
  final String? logo;
  final String? coverImage;
  final String restaurantType;
  final List<RestaurantCategoryItem> categoriesData;
  final String? address;
  final String? latitude;
  final String? longitude;
  final String? phone;
  final bool isActive;
  final bool isCurrentlyOpen;
  final String? openingTime;
  final String? closingTime;
  final double minimumOrderAmount;
  final double deliveryFee;
  final String? deliveryTimeEstimate;
  final bool hasDiscount;
  final double? discountPercentage;
  final double? currentDiscount;
  final String? discountStartTime;
  final String? discountEndTime;
  final double averageRating;
  final int totalReviews;
  final int totalOrders;
  final bool isFeatured;
  final List<WorkingHours> workingHours;
  final DateTime createdAt;

  const RestaurantDetail({
    required this.id,
    required this.name,
    this.nameEn,
    required this.slug,
    this.description,
    this.descriptionEn,
    this.logo,
    this.coverImage,
    required this.restaurantType,
    required this.categoriesData,
    this.address,
    this.latitude,
    this.longitude,
    this.phone,
    required this.isActive,
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

  /// Whether delivery is free
  bool get isFreeDelivery => deliveryFee == 0;

  factory RestaurantDetail.fromJson(Map<String, dynamic> json) {
    return RestaurantDetail(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      nameEn: json['name_en'],
      slug: json['slug'] ?? '',
      description: json['description'],
      descriptionEn: json['description_en'],
      logo: json['logo'],
      coverImage: json['cover_image'],
      restaurantType: json['restaurant_type'] ?? 'food',
      categoriesData:
          (json['categories_data'] as List<dynamic>?)
              ?.map((e) => RestaurantCategoryItem.fromJson(e))
              .toList() ??
          [],
      address: json['address'],
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      phone: json['phone'],
      isActive: json['is_active'] ?? false,
      isCurrentlyOpen: json['is_currently_open'] ?? false,
      openingTime: json['opening_time'],
      closingTime: json['closing_time'],
      minimumOrderAmount: _parseDouble(json['minimum_order_amount']),
      deliveryFee: _parseDouble(json['delivery_fee']),
      deliveryTimeEstimate: json['delivery_time_estimate'],
      hasDiscount: json['has_discount'] ?? false,
      discountPercentage: json['discount_percentage'] != null
          ? _parseDouble(json['discount_percentage'])
          : null,
      currentDiscount: json['current_discount'] != null
          ? _parseDouble(json['current_discount'])
          : null,
      discountStartTime: json['discount_start_time'],
      discountEndTime: json['discount_end_time'],
      averageRating: _parseDouble(json['average_rating']),
      totalReviews: json['total_reviews'] ?? 0,
      totalOrders: json['total_orders'] ?? 0,
      isFeatured: json['is_featured'] ?? false,
      workingHours:
          (json['working_hours'] as List<dynamic>?)
              ?.map((e) => WorkingHours.fromJson(e))
              .toList() ??
          [],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_en': nameEn,
      'slug': slug,
      'description': description,
      'description_en': descriptionEn,
      'logo': logo,
      'cover_image': coverImage,
      'restaurant_type': restaurantType,
      'categories_data': categoriesData.map((e) => e.toJson()).toList(),
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'is_active': isActive,
      'is_currently_open': isCurrentlyOpen,
      'opening_time': openingTime,
      'closing_time': closingTime,
      'minimum_order_amount': minimumOrderAmount.toString(),
      'delivery_fee': deliveryFee.toString(),
      'delivery_time_estimate': deliveryTimeEstimate,
      'has_discount': hasDiscount,
      'discount_percentage': discountPercentage?.toString(),
      'current_discount': currentDiscount?.toString(),
      'discount_start_time': discountStartTime,
      'discount_end_time': discountEndTime,
      'average_rating': averageRating.toString(),
      'total_reviews': totalReviews,
      'total_orders': totalOrders,
      'is_featured': isFeatured,
      'working_hours': workingHours.map((e) => e.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    nameEn,
    slug,
    description,
    descriptionEn,
    logo,
    coverImage,
    restaurantType,
    categoriesData,
    address,
    latitude,
    longitude,
    phone,
    isActive,
    isCurrentlyOpen,
    openingTime,
    closingTime,
    minimumOrderAmount,
    deliveryFee,
    deliveryTimeEstimate,
    hasDiscount,
    discountPercentage,
    currentDiscount,
    discountStartTime,
    discountEndTime,
    averageRating,
    totalReviews,
    totalOrders,
    isFeatured,
    workingHours,
    createdAt,
  ];
}

// ============================================================
// WORKING HOURS
// ============================================================

class WorkingHours extends Equatable {
  final int id;
  final int day;
  final String dayName;
  final String openingTime;
  final String closingTime;
  final bool isClosed;

  const WorkingHours({
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'day': day,
      'day_name': dayName,
      'opening_time': openingTime,
      'closing_time': closingTime,
      'is_closed': isClosed,
    };
  }

  @override
  List<Object?> get props => [
    id,
    day,
    dayName,
    openingTime,
    closingTime,
    isClosed,
  ];
}

// ============================================================
// RESTAURANT CATEGORY (for /restaurants/categories/ endpoint)
// ============================================================

class RestaurantCategory extends Equatable {
  final int id;
  final String name;
  final String? nameEn;
  final String slug;
  final String? icon;
  final String? image;
  final bool isActive;
  final int order;
  final int restaurantsCount;

  const RestaurantCategory({
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_en': nameEn,
      'slug': slug,
      'icon': icon,
      'image': image,
      'is_active': isActive,
      'order': order,
      'restaurants_count': restaurantsCount,
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    nameEn,
    slug,
    icon,
    image,
    isActive,
    order,
    restaurantsCount,
  ];
}

// ============================================================
// RESTAURANT LIST ITEM (simplified for lists)
// ============================================================

class RestaurantListItem extends Equatable {
  final int id;
  final String name;
  final String? nameEn;
  final String slug;
  final String? description;
  final String? descriptionEn;
  final String? logo;
  final String? coverImage;
  final String restaurantType;
  final List<RestaurantCategoryItem> categoriesData;
  final bool isActive;
  final bool isCurrentlyOpen;
  final double minimumOrderAmount;
  final double? deliveryFee;
  final double? distanceKm;
  final String? deliveryTimeEstimate;
  final bool hasDiscount;
  final double? currentDiscount;
  final double averageRating;
  final int totalReviews;
  final int totalOrders;
  final bool isFeatured;

  const RestaurantListItem({
    required this.id,
    required this.name,
    this.nameEn,
    required this.slug,
    this.description,
    this.descriptionEn,
    this.logo,
    this.coverImage,
    required this.restaurantType,
    required this.categoriesData,
    required this.isActive,
    required this.isCurrentlyOpen,
    required this.minimumOrderAmount,
    this.deliveryFee,
    this.distanceKm,
    this.deliveryTimeEstimate,
    required this.hasDiscount,
    this.currentDiscount,
    required this.averageRating,
    required this.totalReviews,
    required this.totalOrders,
    required this.isFeatured,
  });

  /// Whether delivery is explicitly free (not unknown/null)
  bool get isFreeDelivery => deliveryFee != null && deliveryFee == 0;

  factory RestaurantListItem.fromJson(Map<String, dynamic> json) {
    return RestaurantListItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      nameEn: json['name_en'],
      slug: json['slug'] ?? '',
      description: json['description'],
      descriptionEn: json['description_en'],
      logo: json['logo'],
      coverImage: json['cover_image'],
      restaurantType: json['restaurant_type'] ?? 'food',
      categoriesData:
          (json['categories_data'] as List<dynamic>?)
              ?.map((e) => RestaurantCategoryItem.fromJson(e))
              .toList() ??
          [],
      isActive: json['is_active'] ?? false,
      isCurrentlyOpen: json['is_currently_open'] ?? false,
      minimumOrderAmount: _parseDouble(json['minimum_order_amount']),
      deliveryFee: json['delivery_fee'] != null
          ? _parseDouble(json['delivery_fee'])
          : null,
      distanceKm: json['distance_km'] != null
          ? _parseDouble(json['distance_km'])
          : null,
      deliveryTimeEstimate: json['delivery_time_estimate'],
      hasDiscount: json['has_discount'] ?? false,
      currentDiscount: json['current_discount'] != null
          ? _parseDouble(json['current_discount'])
          : null,
      averageRating: _parseDouble(json['average_rating']),
      totalReviews: json['total_reviews'] ?? 0,
      totalOrders: json['total_orders'] ?? 0,
      isFeatured: json['is_featured'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_en': nameEn,
      'slug': slug,
      'description': description,
      'description_en': descriptionEn,
      'logo': logo,
      'cover_image': coverImage,
      'restaurant_type': restaurantType,
      'categories_data': categoriesData.map((e) => e.toJson()).toList(),
      'is_active': isActive,
      'is_currently_open': isCurrentlyOpen,
      'minimum_order_amount': minimumOrderAmount.toString(),
      'delivery_fee': deliveryFee?.toString(),
      'distance_km': distanceKm,
      'delivery_time_estimate': deliveryTimeEstimate,
      'has_discount': hasDiscount,
      'current_discount': currentDiscount?.toString(),
      'average_rating': averageRating.toString(),
      'total_reviews': totalReviews,
      'total_orders': totalOrders,
      'is_featured': isFeatured,
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    nameEn,
    slug,
    description,
    descriptionEn,
    logo,
    coverImage,
    restaurantType,
    categoriesData,
    isActive,
    isCurrentlyOpen,
    minimumOrderAmount,
    deliveryFee,
    distanceKm,
    deliveryTimeEstimate,
    hasDiscount,
    currentDiscount,
    averageRating,
    totalReviews,
    totalOrders,
    isFeatured,
  ];
}

// ============================================================
// RESTAURANT FILTER PARAMS
// ============================================================

class RestaurantFilterParams extends Equatable {
  final int? categoryId;
  final bool? hasDiscount;
  final bool? isFeatured;
  final bool? isCurrentlyOpen;
  final String? ordering;
  final String? restaurantType;
  final String? search;
  final double? lat;
  final double? lng;
  final int? page;
  final int? pageSize;

  const RestaurantFilterParams({
    this.categoryId,
    this.hasDiscount,
    this.isFeatured,
    this.isCurrentlyOpen,
    this.ordering,
    this.restaurantType,
    this.search,
    this.lat,
    this.lng,
    this.page,
    this.pageSize,
  });

  Map<String, String> toQueryParams() {
    final params = <String, String>{};
    if (categoryId != null) params['categories'] = categoryId.toString();
    if (hasDiscount != null) params['has_discount'] = hasDiscount.toString();
    if (isFeatured != null) params['is_featured'] = isFeatured.toString();
    if (isCurrentlyOpen != null)
      params['is_currently_open'] = isCurrentlyOpen.toString();
    if (ordering != null) params['ordering'] = ordering!;
    if (restaurantType != null) params['restaurant_type'] = restaurantType!;
    if (search != null && search!.isNotEmpty) params['search'] = search!;
    if (lat != null) params['lat'] = lat.toString();
    if (lng != null) params['lng'] = lng.toString();
    if (page != null) params['page'] = page.toString();
    if (pageSize != null) params['page_size'] = pageSize.toString();
    return params;
  }

  RestaurantFilterParams copyWith({
    int? categoryId,
    bool? hasDiscount,
    bool? isFeatured,
    bool? isCurrentlyOpen,
    String? ordering,
    String? restaurantType,
    String? search,
    double? lat,
    double? lng,
    int? page,
    int? pageSize,
  }) {
    return RestaurantFilterParams(
      categoryId: categoryId ?? this.categoryId,
      hasDiscount: hasDiscount ?? this.hasDiscount,
      isFeatured: isFeatured ?? this.isFeatured,
      isCurrentlyOpen: isCurrentlyOpen ?? this.isCurrentlyOpen,
      ordering: ordering ?? this.ordering,
      restaurantType: restaurantType ?? this.restaurantType,
      search: search ?? this.search,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  @override
  List<Object?> get props => [
    categoryId,
    hasDiscount,
    isFeatured,
    isCurrentlyOpen,
    ordering,
    restaurantType,
    search,
    lat,
    lng,
    page,
    pageSize,
  ];
}
