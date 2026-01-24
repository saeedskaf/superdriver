/// Menu category with subcategories
class MenuCategory {
  final int id;
  final String name;
  final String? nameEn;
  final String slug;
  final String? description;
  final String? image;
  final bool isActive;
  final int order;
  final List<SubCategory> subcategories;
  final int productsCount;
  final List<ProductSimpleMenu>? products;

  MenuCategory({
    required this.id,
    required this.name,
    this.nameEn,
    required this.slug,
    this.description,
    this.image,
    required this.isActive,
    required this.order,
    required this.subcategories,
    required this.productsCount,
    this.products,
  });

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    return MenuCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      nameEn: json['name_en'],
      slug: json['slug'] ?? '',
      description: json['description'],
      image: json['image'],
      isActive: json['is_active'] ?? false,
      order: json['order'] ?? 0,
      subcategories: (json['subcategories'] as List<dynamic>?)
              ?.map((e) => SubCategory.fromJson(e))
              .toList() ??
          [],
      productsCount: json['products_count'] ?? 0,
      products: (json['products'] as List<dynamic>?)
          ?.map((e) => ProductSimpleMenu.fromJson(e))
          .toList(),
    );
  }
}

/// Subcategory model
class SubCategory {
  final int id;
  final String name;
  final String? nameEn;
  final String slug;
  final bool isActive;
  final int order;

  SubCategory({
    required this.id,
    required this.name,
    this.nameEn,
    required this.slug,
    required this.isActive,
    required this.order,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      nameEn: json['name_en'],
      slug: json['slug'] ?? '',
      isActive: json['is_active'] ?? false,
      order: json['order'] ?? 0,
    );
  }
}

/// Simple product for menu lists
class ProductSimpleMenu {
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

  ProductSimpleMenu({
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

  factory ProductSimpleMenu.fromJson(Map<String, dynamic> json) {
    return ProductSimpleMenu(
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

/// Detailed product model
class ProductDetail {
  final int id;
  final int restaurantId;
  final String restaurantName;
  final int categoryId;
  final String categoryName;
  final int? subcategoryId;
  final String? subcategoryName;
  final String name;
  final String? nameEn;
  final String slug;
  final String? description;
  final String? image;
  final String basePrice;
  final String currentPrice;
  final String discountAmount;
  final bool hasDiscount;
  final String? discountType;
  final String? discountValue;
  final bool isDiscountActive;
  final DateTime? discountStart;
  final DateTime? discountEnd;
  final int? calories;
  final int? preparationTime;
  final bool isAvailable;
  final bool isFeatured;
  final bool isPopular;
  final List<ProductVariation> variations;
  final List<ProductAddon> addons;
  final List<ProductImage> images;
  final DateTime createdAt;

  ProductDetail({
    required this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.categoryId,
    required this.categoryName,
    this.subcategoryId,
    this.subcategoryName,
    required this.name,
    this.nameEn,
    required this.slug,
    this.description,
    this.image,
    required this.basePrice,
    required this.currentPrice,
    required this.discountAmount,
    required this.hasDiscount,
    this.discountType,
    this.discountValue,
    required this.isDiscountActive,
    this.discountStart,
    this.discountEnd,
    this.calories,
    this.preparationTime,
    required this.isAvailable,
    required this.isFeatured,
    required this.isPopular,
    required this.variations,
    required this.addons,
    required this.images,
    required this.createdAt,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
      id: json['id'] ?? 0,
      restaurantId: json['restaurant'] ?? 0,
      restaurantName: json['restaurant_name'] ?? '',
      categoryId: json['category'] ?? 0,
      categoryName: json['category_name'] ?? '',
      subcategoryId: json['subcategory'],
      subcategoryName: json['subcategory_name'],
      name: json['name'] ?? '',
      nameEn: json['name_en'],
      slug: json['slug'] ?? '',
      description: json['description'],
      image: json['image'],
      basePrice: json['base_price']?.toString() ?? '0',
      currentPrice: json['current_price']?.toString() ?? '0',
      discountAmount: json['discount_amount']?.toString() ?? '0',
      hasDiscount: json['has_discount'] ?? false,
      discountType: json['discount_type'],
      discountValue: json['discount_value']?.toString(),
      isDiscountActive: json['is_discount_active'] ?? false,
      discountStart: json['discount_start'] != null
          ? DateTime.tryParse(json['discount_start'])
          : null,
      discountEnd: json['discount_end'] != null
          ? DateTime.tryParse(json['discount_end'])
          : null,
      calories: json['calories'],
      preparationTime: json['preparation_time'],
      isAvailable: json['is_available'] ?? true,
      isFeatured: json['is_featured'] ?? false,
      isPopular: json['is_popular'] ?? false,
      variations: (json['variations'] as List<dynamic>?)
              ?.map((e) => ProductVariation.fromJson(e))
              .toList() ??
          [],
      addons: (json['addons'] as List<dynamic>?)
              ?.map((e) => ProductAddon.fromJson(e))
              .toList() ??
          [],
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => ProductImage.fromJson(e))
              .toList() ??
          [],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  double get basePriceDouble => double.tryParse(basePrice) ?? 0;
  double get currentPriceDouble => double.tryParse(currentPrice) ?? 0;
  double get discountAmountDouble => double.tryParse(discountAmount) ?? 0;

  bool get hasVariations => variations.isNotEmpty;
  bool get hasAddons => addons.isNotEmpty;
}

/// Product variation
class ProductVariation {
  final int id;
  final String name;
  final String? nameEn;
  final String priceAdjustment;
  final String totalPrice;
  final bool isAvailable;
  final int order;

  ProductVariation({
    required this.id,
    required this.name,
    this.nameEn,
    required this.priceAdjustment,
    required this.totalPrice,
    required this.isAvailable,
    required this.order,
  });

  factory ProductVariation.fromJson(Map<String, dynamic> json) {
    return ProductVariation(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      nameEn: json['name_en'],
      priceAdjustment: json['price_adjustment']?.toString() ?? '0',
      totalPrice: json['total_price']?.toString() ?? '0',
      isAvailable: json['is_available'] ?? true,
      order: json['order'] ?? 0,
    );
  }

  double get priceAdjustmentDouble => double.tryParse(priceAdjustment) ?? 0;
  double get totalPriceDouble => double.tryParse(totalPrice) ?? 0;
}

/// Product addon
class ProductAddon {
  final int id;
  final String name;
  final String? nameEn;
  final String price;
  final bool isAvailable;
  final int maxQuantity;
  final int order;

  ProductAddon({
    required this.id,
    required this.name,
    this.nameEn,
    required this.price,
    required this.isAvailable,
    required this.maxQuantity,
    required this.order,
  });

  factory ProductAddon.fromJson(Map<String, dynamic> json) {
    return ProductAddon(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      nameEn: json['name_en'],
      price: json['price']?.toString() ?? '0',
      isAvailable: json['is_available'] ?? true,
      maxQuantity: json['max_quantity'] ?? 10,
      order: json['order'] ?? 0,
    );
  }

  double get priceDouble => double.tryParse(price) ?? 0;
}

/// Product image
class ProductImage {
  final int id;
  final String image;
  final int order;

  ProductImage({
    required this.id,
    required this.image,
    required this.order,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'] ?? 0,
      image: json['image'] ?? '',
      order: json['order'] ?? 0,
    );
  }
}
