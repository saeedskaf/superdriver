class Environment {
  static const String baseUrl = "https://delivery.hamzaekhwan.com";

  // Auth endpoints
  static const String loginEndpoint = "$baseUrl/api/auth/login/";
  static const String registerEndpoint = "$baseUrl/api/auth/signup/";
  static const String verifyOtpEndpoint = "$baseUrl/api/auth/verify-otp/";
  static const String resendOtpEndpoint = "$baseUrl/api/auth/resend-otp/";
  static const String forgotPasswordEndpoint =
      "$baseUrl/api/auth/forgot-password/";
  static const String resetPasswordEndpoint =
      "$baseUrl/api/auth/reset-password/";
  static const String profileEndpoint = '$baseUrl/api/auth/profile/';
  static const String changePasswordEndpoint =
      '$baseUrl/api/auth/change-password/';

  // Account endpoints
  static const String deleteAccountEndpoint =
      '$baseUrl/api/auth/delete-account/';

  // Address endpoints
  static const String addressesEndpoint = '$baseUrl/api/addresses/';
  static const String currentAddressEndpoint =
      '$baseUrl/api/addresses/current/';
  static const String governoratesEndpoint =
      '$baseUrl/api/addresses/locations/governorates/';
  static String addressByIdEndpoint(int id) => '$baseUrl/api/addresses/$id/';
  static String setCurrentAddressEndpoint(int id) =>
      '$baseUrl/api/addresses/$id/set_current/';

  // Cart endpoints
  static const String cartEndpoint = '$baseUrl/api/cart/';
  static const String allCartsEndpoint = '$baseUrl/api/cart/all/';
  static const String addToCartEndpoint = '$baseUrl/api/cart/add/';
  static const String deleteCartEndpoint = '$baseUrl/api/cart/delete/';
  static const String validateCartEndpoint = '$baseUrl/api/cart/validate/';
  static String clearCartEndpoint(int cartId) =>
      '$baseUrl/api/cart/$cartId/clear/';
  static String cartItemEndpoint(int itemId) =>
      '$baseUrl/api/cart/item/$itemId/';
  static String applyCouponEndpoint(int cartId) =>
      '$baseUrl/api/cart/$cartId/coupon/';
  static String removeCouponEndpoint(int cartId) =>
      '$baseUrl/api/cart/$cartId/coupon/';

  // Order endpoints
  static const String ordersEndpoint = '$baseUrl/api/orders/';
  static const String activeOrdersEndpoint = '$baseUrl/api/orders/active/';
  static const String ordersHistoryEndpoint = '$baseUrl/api/orders/history/';
  static const String createOrderEndpoint = '$baseUrl/api/orders/create/';
  static String orderDetailsEndpoint(int orderId) =>
      '$baseUrl/api/orders/$orderId/';
  static String placeOrderEndpoint(int orderId) =>
      '$baseUrl/api/orders/$orderId/place/';
  static String cancelOrderEndpoint(int orderId) =>
      '$baseUrl/api/orders/$orderId/cancel/';
  static String reorderEndpoint(int orderId) =>
      '$baseUrl/api/orders/$orderId/reorder/';
  static String trackOrderEndpoint(int orderId) =>
      '$baseUrl/api/orders/$orderId/track/';

  // Home endpoints
  static const String homeEndpoint = '$baseUrl/api/home/';
  static const String nearbyRestaurantsEndpoint = '$baseUrl/api/home/nearby/';
  static const String recommendedRestaurantsEndpoint =
      '$baseUrl/api/home/recommended/';
  static const String reorderSuggestionsEndpoint = '$baseUrl/api/home/reorder/';
  static const String searchSuggestionsEndpoint =
      '$baseUrl/api/home/suggestions/';
  static const String trendingEndpoint = '$baseUrl/api/home/trending/';

  // Menu endpoints
  static const String menuCategoriesEndpoint = '$baseUrl/api/menu/categories/';
  static const String menuProductsEndpoint = '$baseUrl/api/menu/products/';
  static const String menuDealsEndpoint = '$baseUrl/api/menu/products/deals/';
  static const String menuFeaturedEndpoint =
      '$baseUrl/api/menu/products/featured/';
  static const String menuPopularEndpoint =
      '$baseUrl/api/menu/products/popular/';
  static String menuCategoryDetailsEndpoint(int id) =>
      '$baseUrl/api/menu/categories/$id/';
  static String menuProductDetailsEndpoint(String slug) =>
      '$baseUrl/api/menu/products/$slug/';

  // Restaurant endpoints
  static const String restaurantsEndpoint = '$baseUrl/api/restaurants/';
  static const String restaurantCategoriesEndpoint =
      '$baseUrl/api/restaurants/categories/';
  static const String restaurantsNearbyEndpoint =
      '$baseUrl/api/restaurants/nearby/';
  static const String restaurantsSearchEndpoint =
      '$baseUrl/api/restaurants/search/';
  static String restaurantDetailsEndpoint(String slug) =>
      '$baseUrl/api/restaurants/$slug/';
  static String restaurantMenuEndpoint(String slug) =>
      '$baseUrl/api/restaurants/$slug/menu/';
  static String restaurantReviewsEndpoint(String slug) =>
      '$baseUrl/api/restaurants/$slug/reviews/';
  static String restaurantCategoryDetailsEndpoint(String slug) =>
      '$baseUrl/api/restaurants/categories/$slug/';
  static String restaurantCategoryRestaurantsEndpoint(String slug) =>
      '$baseUrl/api/restaurants/categories/$slug/restaurants/';

  // Review endpoints
  static const String createDriverReviewEndpoint =
      '$baseUrl/api/reviews/driver/create/';

  // Notification endpoints
  static const String notificationsEndpoint = '$baseUrl/api/notifications/';
  static String notificationDetailEndpoint(int id) =>
      '$baseUrl/api/notifications/$id/';
  static String notificationReadEndpoint(int id) =>
      '$baseUrl/api/notifications/$id/read/';
  static const String notificationsReadAllEndpoint =
      '$baseUrl/api/notifications/read-all/';
  static const String notificationsUnreadCountEndpoint =
      '$baseUrl/api/notifications/unread-count/';
  static const String registerDeviceEndpoint =
      '$baseUrl/api/notifications/devices/register/';
  static const String unregisterDeviceEndpoint =
      '$baseUrl/api/notifications/devices/unregister/';
}
