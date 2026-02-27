import 'package:equatable/equatable.dart';
import 'package:superdriver/domain/models/restaurant_model.dart';

/// Helper function to parse double from various types
double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

// ============================================================
// BANNER
// ============================================================

class Banner extends Equatable {
  final int id;
  final String title;
  final String? titleEn;
  final String? subtitle;
  final String? subtitleEn;
  final String? image;
  final String bannerType;
  final String? link;
  final bool isActive;
  final bool isCurrentlyActive;
  final int order;

  const Banner({
    required this.id,
    required this.title,
    this.titleEn,
    this.subtitle,
    this.subtitleEn,
    this.image,
    required this.bannerType,
    this.link,
    required this.isActive,
    required this.isCurrentlyActive,
    required this.order,
  });

  factory Banner.fromJson(Map<String, dynamic> json) => Banner(
    id: json['id'] ?? 0,
    title: json['title'] ?? '',
    titleEn: json['title_en'],
    subtitle: json['subtitle'],
    subtitleEn: json['subtitle_en'],
    image: json['image'],
    bannerType: json['banner_type'] ?? 'general',
    link: json['link'],
    isActive: json['is_active'] ?? false,
    isCurrentlyActive: json['is_currently_active'] ?? false,
    order: json['order'] ?? 0,
  );

  @override
  List<Object?> get props => [id];
}

// ============================================================
// CATEGORY
// ============================================================

class Category extends Equatable {
  final int id;
  final String name;
  final String? nameEn;
  final String slug;
  final String? icon;
  final String? image;
  final bool isActive;
  final int order;
  final int restaurantsCount;

  const Category({
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

  factory Category.fromJson(Map<String, dynamic> json) => Category(
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

  @override
  List<Object?> get props => [id];
}

// ============================================================
// HOME DATA (main /api/home/ response)
// ============================================================

class HomeData extends Equatable {
  final List<Banner> banners;
  final List<Category> categories;
  final List<RestaurantListItem> featuredRestaurants;
  final List<RestaurantListItem> newRestaurants;

  const HomeData({
    required this.banners,
    required this.categories,
    required this.featuredRestaurants,
    required this.newRestaurants,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) => HomeData(
    banners:
        (json['banners'] as List<dynamic>?)
            ?.map((e) => Banner.fromJson(e))
            .toList() ??
        [],
    categories:
        (json['categories'] as List<dynamic>?)
            ?.map((e) => Category.fromJson(e))
            .toList() ??
        [],
    featuredRestaurants:
        (json['featured_restaurants'] as List<dynamic>?)
            ?.map((e) => RestaurantListItem.fromJson(e))
            .toList() ??
        [],
    newRestaurants:
        (json['new_restaurants'] as List<dynamic>?)
            ?.map((e) => RestaurantListItem.fromJson(e))
            .toList() ??
        [],
  );

  @override
  List<Object?> get props => [
    banners,
    categories,
    featuredRestaurants,
    newRestaurants,
  ];
}

// ============================================================
// REORDER
// ============================================================

class ReorderItem extends Equatable {
  final int orderId;
  final int restaurantId;
  final String restaurantName;
  final String? restaurantLogo;
  final DateTime? orderDate;
  final double totalAmount;
  final List<ReorderProduct> items;

  const ReorderItem({
    required this.orderId,
    required this.restaurantId,
    required this.restaurantName,
    this.restaurantLogo,
    this.orderDate,
    required this.totalAmount,
    required this.items,
  });

  factory ReorderItem.fromJson(Map<String, dynamic> json) => ReorderItem(
    orderId: json['order_id'] ?? json['id'] ?? 0,
    restaurantId: json['restaurant_id'] ?? json['restaurant'] ?? 0,
    restaurantName: json['restaurant_name'] ?? '',
    restaurantLogo: json['restaurant_logo'],
    orderDate: json['order_date'] != null
        ? DateTime.tryParse(json['order_date'])
        : null,
    totalAmount: _parseDouble(json['total_amount'] ?? json['total']),
    items:
        (json['items'] as List<dynamic>?)
            ?.map((e) => ReorderProduct.fromJson(e))
            .toList() ??
        [],
  );

  @override
  List<Object?> get props => [orderId];
}

class ReorderProduct extends Equatable {
  final int id;
  final String name;
  final String? image;
  final int quantity;
  final double price;

  const ReorderProduct({
    required this.id,
    required this.name,
    this.image,
    required this.quantity,
    required this.price,
  });

  factory ReorderProduct.fromJson(Map<String, dynamic> json) => ReorderProduct(
    id: json['id'] ?? json['product_id'] ?? 0,
    name: json['name'] ?? json['product_name'] ?? '',
    image: json['image'],
    quantity: json['quantity'] ?? 1,
    price: _parseDouble(json['price']),
  );

  @override
  List<Object?> get props => [id];
}
