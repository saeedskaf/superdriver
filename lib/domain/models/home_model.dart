/// Home page data containing all sections
class HomeData {
  final List<Banner> banners;
  final List<Category> categories;
  final List<Restaurant> featuredRestaurants;
  final List<Restaurant> popularRestaurants;
  final List<Restaurant> newRestaurants;
  final List<Restaurant> discountRestaurants;
  final List<ProductSimple> popularProducts;

  HomeData({
    required this.banners,
    required this.categories,
    required this.featuredRestaurants,
    required this.popularRestaurants,
    required this.newRestaurants,
    required this.discountRestaurants,
    required this.popularProducts,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      banners: (json['banners'] as List<dynamic>?)
              ?.map((e) => Banner.fromJson(e))
              .toList() ??
          [],
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => Category.fromJson(e))
              .toList() ??
          [],
      featuredRestaurants: (json['featured_restaurants'] as List<dynamic>?)
              ?.map((e) => Restaurant.fromJson(e))
              .toList() ??
          [],
      popularRestaurants: (json['popular_restaurants'] as List<dynamic>?)
              ?.map((e) => Restaurant.fromJson(e))
              .toList() ??
          [],
      newRestaurants: (json['new_restaurants'] as List<dynamic>?)
              ?.map((e) => Restaurant.fromJson(e))
              .toList() ??
          [],
      discountRestaurants: (json['discount_restaurants'] as List<dynamic>?)
              ?.map((e) => Restaurant.fromJson(e))
              .toList() ??
          [],
      popularProducts: (json['popular_products'] as List<dynamic>?)
              ?.map((e) => ProductSimple.fromJson(e))
              .toList() ??
          [],
    );
  }
}

/// Banner model
class Banner {
  final int id;
  final String title;
  final String? subtitle;
  final String? image;
  final String bannerType;
  final String? link;
  final bool isActive;
  final bool isCurrentlyActive;
  final int order;

  Banner({
    required this.id,
    required this.title,
    this.subtitle,
    this.image,
    required this.bannerType,
    this.link,
    required this.isActive,
    required this.isCurrentlyActive,
    required this.order,
  });

  factory Banner.fromJson(Map<String, dynamic> json) {
    return Banner(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      subtitle: json['subtitle'],
      image: json['image'],
      bannerType: json['banner_type'] ?? '',
      link: json['link'],
      isActive: json['is_active'] ?? false,
      isCurrentlyActive: json['is_currently_active'] ?? false,
      order: json['order'] ?? 0,
    );
  }
}

/// Category model
class Category {
  final int id;
  final String name;
  final String? nameEn;
  final String slug;
  final String? icon;
  final String? image;
  final bool isActive;
  final int order;
  final int restaurantsCount;

  Category({
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

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
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

/// Restaurant model
class Restaurant {
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

  Restaurant({
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

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
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

/// Simple product model (for lists)
class ProductSimple {
  final int id;
  final int restaurantId;
  final String restaurantName;
  final int categoryId;
  final String categoryName;
  final String name;
  final String? nameEn;
  final String slug;
  final String? image;
  final String basePrice;
  final String currentPrice;
  final String discountAmount;
  final bool hasDiscount;
  final bool isDiscountActive;
  final bool isAvailable;
  final bool isFeatured;
  final bool isPopular;

  ProductSimple({
    required this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.categoryId,
    required this.categoryName,
    required this.name,
    this.nameEn,
    required this.slug,
    this.image,
    required this.basePrice,
    required this.currentPrice,
    required this.discountAmount,
    required this.hasDiscount,
    required this.isDiscountActive,
    required this.isAvailable,
    required this.isFeatured,
    required this.isPopular,
  });

  factory ProductSimple.fromJson(Map<String, dynamic> json) {
    return ProductSimple(
      id: json['id'] ?? 0,
      restaurantId: json['restaurant'] ?? 0,
      restaurantName: json['restaurant_name'] ?? '',
      categoryId: json['category'] ?? 0,
      categoryName: json['category_name'] ?? '',
      name: json['name'] ?? '',
      nameEn: json['name_en'],
      slug: json['slug'] ?? '',
      image: json['image'],
      basePrice: json['base_price']?.toString() ?? '0',
      currentPrice: json['current_price']?.toString() ?? '0',
      discountAmount: json['discount_amount']?.toString() ?? '0',
      hasDiscount: json['has_discount'] ?? false,
      isDiscountActive: json['is_discount_active'] ?? false,
      isAvailable: json['is_available'] ?? true,
      isFeatured: json['is_featured'] ?? false,
      isPopular: json['is_popular'] ?? false,
    );
  }

  double get basePriceDouble => double.tryParse(basePrice) ?? 0;
  double get currentPriceDouble => double.tryParse(currentPrice) ?? 0;
  double get discountAmountDouble => double.tryParse(discountAmount) ?? 0;
}

/// Trending data
class TrendingData {
  final List<Restaurant> trendingRestaurants;
  final List<ProductSimple> trendingProducts;

  TrendingData({
    required this.trendingRestaurants,
    required this.trendingProducts,
  });

  factory TrendingData.fromJson(Map<String, dynamic> json) {
    return TrendingData(
      trendingRestaurants: (json['trending_restaurants'] as List<dynamic>?)
              ?.map((e) => Restaurant.fromJson(e))
              .toList() ??
          [],
      trendingProducts: (json['trending_products'] as List<dynamic>?)
              ?.map((e) => ProductSimple.fromJson(e))
              .toList() ??
          [],
    );
  }
}

/// Recommended restaurants response
class RecommendedData {
  final List<Restaurant> recommendations;

  RecommendedData({required this.recommendations});

  factory RecommendedData.fromJson(Map<String, dynamic> json) {
    return RecommendedData(
      recommendations: (json['recommendations'] as List<dynamic>?)
              ?.map((e) => Restaurant.fromJson(e))
              .toList() ??
          [],
    );
  }
}

/// Suggestions response
class SuggestionsData {
  final List<String> suggestions;

  SuggestionsData({required this.suggestions});

  factory SuggestionsData.fromJson(Map<String, dynamic> json) {
    return SuggestionsData(
      suggestions: (json['suggestions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}
