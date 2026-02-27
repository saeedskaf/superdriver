// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Super Driver';

  @override
  String get welcomeMessage => 'Your Orders, Our Commands';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get networkError => 'Failed to connect to server';

  @override
  String get tryAgain => 'Try again';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get save => 'Save';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get close => 'Close';

  @override
  String get search => 'Search';

  @override
  String get retry => 'Retry';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get done => 'Done';

  @override
  String get apply => 'Apply';

  @override
  String get submit => 'Submit';

  @override
  String get send => 'Send';

  @override
  String get continueButton => 'Continue';

  @override
  String get or => 'or';

  @override
  String get and => 'and';

  @override
  String get copy => 'Copy';

  @override
  String get free => 'Free';

  @override
  String get currency => 'SYP';

  @override
  String get currencyCode => 'SYP';

  @override
  String get minuteShort => 'm';

  @override
  String get secondShort => 's';

  @override
  String get minute => 'min';

  @override
  String get minutes => 'min';

  @override
  String get hours => 'hours';

  @override
  String get days => 'days';

  @override
  String get seconds => 'seconds';

  @override
  String get ago => 'ago';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get am => 'AM';

  @override
  String get pm => 'PM';

  @override
  String minutesAgo(int count) {
    return '$count minutes ago';
  }

  @override
  String hoursAgo(int count) {
    return '$count hours ago';
  }

  @override
  String daysAgo(int count) {
    return '$count days ago';
  }

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get register => 'Register';

  @override
  String get signUp => 'Sign Up';

  @override
  String get signIn => 'Sign In';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get changePassword => 'Change Password';

  @override
  String get createAccount => 'Create Account';

  @override
  String get enterDetailsToStart => 'Enter your details to get started';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get byCreatingAccount => 'By creating an account, you agree to our';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get signInToContinue => 'Sign in to continue';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get verifyPhone => 'Verify Phone Number';

  @override
  String get enterOtpSent => 'Enter the verification code sent to';

  @override
  String get enterOtpSentTo => 'Please enter the verification code sent to';

  @override
  String get changePhoneNumber => 'Change phone number?';

  @override
  String get verificationSuccess => 'Verified successfully! Please sign in';

  @override
  String get enterPhoneToReset =>
      'Enter your phone number to reset your password';

  @override
  String get sendCode => 'Send Code';

  @override
  String get rememberPassword => 'Remember your password?';

  @override
  String get resettingPassword => 'Resetting password...';

  @override
  String get passwordResetSuccess =>
      'Password reset successfully! Please sign in with your new password';

  @override
  String get loginRequired => 'Login Required';

  @override
  String get loginRequiredMessage => 'Please login to access this feature';

  @override
  String get continueBrowsing => 'Continue Browsing';

  @override
  String get loginToViewCart => 'Please login to view your cart';

  @override
  String get loginToAddToCart => 'Please login first to add products to cart';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get verificationCode => 'Verification Code';

  @override
  String get newPassword => 'New Password';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get phoneRequired => 'Phone number is required';

  @override
  String get phoneInvalid => 'Invalid phone number';

  @override
  String get phoneTooShort => 'Phone number is too short';

  @override
  String get phoneTooLong => 'Phone number is too long';

  @override
  String get phoneOnlyNumbers => 'Phone number must contain only numbers';

  @override
  String get emailInvalid => 'Invalid email address';

  @override
  String get firstNameRequired => 'First name is required';

  @override
  String get firstNameTooShort => 'Name must be at least 2 characters';

  @override
  String get firstNameTooLong => 'Name is too long';

  @override
  String get lastNameRequired => 'Last name is required';

  @override
  String get lastNameTooShort => 'Name must be at least 2 characters';

  @override
  String get lastNameTooLong => 'Name is too long';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordTooShort => 'Password must be at least 8 characters';

  @override
  String get passwordMinLength => 'Password must be at least 8 characters';

  @override
  String get confirmPasswordRequired => 'Password confirmation is required';

  @override
  String get passwordsNotMatch => 'Passwords do not match';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get currentPasswordRequired => 'Current password is required';

  @override
  String get newPasswordRequired => 'New password is required';

  @override
  String get otpRequired => 'Verification code is required';

  @override
  String get otpInvalid => 'Verification code must be 6 digits';

  @override
  String get otpOnlyNumbers => 'Verification code must contain only numbers';

  @override
  String get invalidOtp => 'Invalid verification code';

  @override
  String get otpSent => 'Verification code sent';

  @override
  String get verifyingCode => 'Verifying code...';

  @override
  String get otpResent => 'Verification code resent successfully';

  @override
  String get sendingVerificationCode => 'Sending verification code...';

  @override
  String get didntReceiveCode => 'Didn\'t receive the code?';

  @override
  String get resend => 'Resend';

  @override
  String get resendIn => 'Resend in';

  @override
  String get verify => 'Verify';

  @override
  String get homeScreen => 'Home';

  @override
  String get deliverTo => 'Deliver to';

  @override
  String get deliveryTo => 'Deliver to';

  @override
  String get selectLocation => 'Select your location';

  @override
  String get changeAddress => 'Change Address';

  @override
  String get searchPlaceholder => 'Search for restaurants or dishes...';

  @override
  String get searchRestaurantsAndFood => 'Search restaurants and food';

  @override
  String get searchHint => 'Burgers, pizza, shawarma...';

  @override
  String get searchRestaurants => 'Search restaurants...';

  @override
  String get searchResults => 'Search Results';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get tryDifferentKeywords => 'Try different keywords';

  @override
  String get tryDifferentSearch => 'Try a different search term';

  @override
  String get recentSearches => 'Recent Searches';

  @override
  String get clearHistory => 'Clear History';

  @override
  String get searchFailed => 'Search failed, try again';

  @override
  String get results => 'Results';

  @override
  String get searchInMenu => 'Search in menu...';

  @override
  String get noSearchResults => 'No search results';

  @override
  String get noResultsFor => 'No results for';

  @override
  String get categories => 'Categories';

  @override
  String get seeAll => 'See All';

  @override
  String get featuredRestaurants => 'Featured Restaurants';

  @override
  String get popularRestaurants => 'Popular Restaurants';

  @override
  String get newRestaurants => 'New on SuperDriver';

  @override
  String get discountRestaurants => 'Offers & Discounts';

  @override
  String get nearbyRestaurants => 'Nearby Restaurants';

  @override
  String get recommendedForYou => 'Recommended for You';

  @override
  String get popularDishes => 'Popular Dishes';

  @override
  String get popularProducts => 'Popular Dishes';

  @override
  String get trending => 'Trending';

  @override
  String get trendingNow => 'Trending Now';

  @override
  String get deals => 'Deals';

  @override
  String get offer => 'Offer';

  @override
  String get seasonal => 'Seasonal';

  @override
  String get newLabel => 'New';

  @override
  String get open => 'Open';

  @override
  String get closed => 'Closed';

  @override
  String get featured => 'Featured';

  @override
  String get freeDelivery => 'Free Delivery';

  @override
  String get deliveryTime => 'Delivery Time';

  @override
  String get minOrder => 'Minimum Order';

  @override
  String get reviews => 'reviews';

  @override
  String get off => 'OFF';

  @override
  String get noRestaurants => 'No restaurants found';

  @override
  String get noProducts => 'No products found';

  @override
  String get orders => 'orders';

  @override
  String get restaurant => 'Restaurant';

  @override
  String get dish => 'Dish';

  @override
  String get items => 'Items';

  @override
  String get locationPermission =>
      'We need location permission to find nearby restaurants';

  @override
  String get enableLocation => 'Enable Location';

  @override
  String get enableLocationService => 'Please enable location service';

  @override
  String get locationPermissionDenied => 'Location permission denied';

  @override
  String get locationPermissionPermanentlyDenied =>
      'Location permission permanently denied';

  @override
  String get locationServiceDisabled => 'Please enable location service';

  @override
  String get locationServicesDisabled =>
      'Location services are disabled. Please enable them.';

  @override
  String get locationError => 'Error getting location';

  @override
  String get failedToGetLocation => 'Failed to get current location';

  @override
  String get deliveryLocation => 'Delivery Location';

  @override
  String get selectDeliveryAddress => 'Where should we deliver?';

  @override
  String get selectDeliveryLocation => 'Select delivery location';

  @override
  String get whereToDeliver => 'Where should we deliver?';

  @override
  String get currentLocation => 'Current Location';

  @override
  String get usingGPS => 'Using GPS';

  @override
  String get useCurrentLocation => 'Use Current Location';

  @override
  String get detectMyLocation => 'Detect my location automatically';

  @override
  String get detectAutomatically => 'Detect automatically';

  @override
  String get detectYourLocation => 'Using GPS to detect your location';

  @override
  String get searchForLocation => 'Search for a location...';

  @override
  String get searchAddress => 'Search address';

  @override
  String get searchByStreetOrArea => 'Search by street or area name';

  @override
  String get savedAddresses => 'Saved Addresses';

  @override
  String get selectFromSaved => 'Select from your saved addresses';

  @override
  String get selectAddress => 'Select Address';

  @override
  String get tapToSelectAddress => 'Tap to select delivery address';

  @override
  String get addNew => 'Add New';

  @override
  String get noSavedAddresses => 'No Saved Addresses';

  @override
  String get addAddressForFasterDelivery =>
      'Add an address for faster delivery';

  @override
  String get addAddressForFasterCheckout =>
      'Add an address for faster checkout';

  @override
  String get defaultLabel => 'Default';

  @override
  String get manage => 'Manage';

  @override
  String get restaurants => 'Restaurants';

  @override
  String get restaurantDetails => 'Restaurant Details';

  @override
  String get allRestaurants => 'All Restaurants';

  @override
  String get filterRestaurants => 'Filter Restaurants';

  @override
  String get sortBy => 'Sort by';

  @override
  String get rating => 'Rating';

  @override
  String get distance => 'Distance';

  @override
  String get deliveryFeeSort => 'Delivery Fee';

  @override
  String get mostOrdered => 'Most Ordered';

  @override
  String get defaultSort => 'Default';

  @override
  String get minimumOrderSort => 'Minimum Order';

  @override
  String get newest => 'Newest';

  @override
  String get openNow => 'Open Now';

  @override
  String get hasOffers => 'Offers';

  @override
  String get loadMore => 'Load more';

  @override
  String get noMoreRestaurants => 'No more restaurants';

  @override
  String get tryChangingFilters => 'Try changing filters or search';

  @override
  String get clearFilters => 'Clear Filters';

  @override
  String get workingHours => 'Working Hours';

  @override
  String get sunday => 'Sunday';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get closedDay => 'Closed';

  @override
  String get callRestaurant => 'Call Restaurant';

  @override
  String get viewMenu => 'View Menu';

  @override
  String get menu => 'Menu';

  @override
  String get info => 'Info';

  @override
  String get about => 'About';

  @override
  String get restaurantInfo => 'Restaurant Info';

  @override
  String get restaurantAddress => 'Restaurant Address';

  @override
  String get discountOnAllProducts => 'Discount on all products';

  @override
  String get delivery => 'Delivery';

  @override
  String get minimum => 'Minimum';

  @override
  String get loadingMenu => 'Loading menu...';

  @override
  String get noMenuAvailable => 'No menu available';

  @override
  String get noProductsInCategory => 'No products in this category';

  @override
  String get unavailable => 'Unavailable';

  @override
  String get cart => 'Cart';

  @override
  String get myCart => 'My Cart';

  @override
  String get cartDetails => 'Cart Details';

  @override
  String get emptyCart => 'Cart is Empty';

  @override
  String get emptyCartMessage => 'Start adding products to your cart';

  @override
  String get addToCart => 'Add to Cart';

  @override
  String get removeFromCart => 'Remove from Cart';

  @override
  String get viewCart => 'View Cart';

  @override
  String get browseRestaurants => 'Browse Restaurants';

  @override
  String get noCart => 'No cart';

  @override
  String get cartDeleted => 'Cart deleted';

  @override
  String get deleteCart => 'Delete Cart';

  @override
  String get deleteCartConfirmation =>
      'Are you sure you want to delete this cart? This action cannot be undone.';

  @override
  String get cartExpired => 'This cart has expired';

  @override
  String get remaining => 'remaining';

  @override
  String get more => 'more';

  @override
  String get moreItems => 'more items';

  @override
  String get otherItems => 'other items';

  @override
  String get moreOtherItems => 'more items';

  @override
  String get clearCart => 'Clear Cart';

  @override
  String get clearAll => 'Clear All';

  @override
  String get clearCartConfirmation =>
      'Are you sure you want to remove all items from your cart?';

  @override
  String get cartCleared => 'Cart cleared';

  @override
  String get itemAdded => 'Item added';

  @override
  String get itemRemoved => 'Item removed from cart';

  @override
  String get itemUnavailable => 'Item unavailable';

  @override
  String get quantity => 'Quantity';

  @override
  String get quantityUpdated => 'Quantity updated';

  @override
  String get addCoupon => 'Add Coupon';

  @override
  String get enterCouponCode => 'Enter coupon code';

  @override
  String get couponApplied => 'Coupon applied successfully';

  @override
  String get couponRemoved => 'Coupon removed';

  @override
  String get invalidCoupon => 'Invalid coupon';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get deliveryFee => 'Delivery Fee';

  @override
  String get discount => 'Discount';

  @override
  String get total => 'Total';

  @override
  String get continueToCheckout => 'Continue to Checkout';

  @override
  String get proceedToCheckout => 'Proceed to Checkout';

  @override
  String get checkout => 'Checkout';

  @override
  String get orderSummary => 'Order Summary';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get deliveryAddress => 'Delivery Address';

  @override
  String get orderNotes => 'Order Notes';

  @override
  String get addOrderNotes => 'Add special instructions (optional)';

  @override
  String get confirmOrder => 'Confirm Order';

  @override
  String get placeOrder => 'Place Order';

  @override
  String get orderPlacedSuccessfully => 'Order placed successfully!';

  @override
  String get orderConfirmedMessage =>
      'Thank you! Your order will be prepared soon';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get cashOnDelivery => 'Cash on Delivery';

  @override
  String get payWhenReceive => 'Pay when you receive your order';

  @override
  String get creditCard => 'Credit Card';

  @override
  String get wallet => 'Wallet';

  @override
  String get contactPhone => 'Contact Phone';

  @override
  String get contactNumber => 'Contact Number';

  @override
  String get phoneWillBeUsed =>
      'This number will be used to contact you for this order';

  @override
  String get phoneContactMessage =>
      'You will be contacted on this number for this order';

  @override
  String get enterPhone => 'Enter phone number';

  @override
  String get invalidPhone => 'Invalid phone number';

  @override
  String get invalidPhoneNumber => 'Invalid phone number';

  @override
  String get pleaseEnterPhone => 'Please enter phone number';

  @override
  String get immediateDelivery => 'Immediate Delivery';

  @override
  String get within30to45min => 'Within 30-45 minutes';

  @override
  String get within30To45Minutes => 'Within 30-45 minutes';

  @override
  String get scheduleDelivery => 'Schedule Delivery';

  @override
  String get chooseSpecificTime => 'Choose a specific time';

  @override
  String get selectDateAndTime => 'Select date and time';

  @override
  String get pleaseSelectDeliveryTime => 'Please select delivery time';

  @override
  String get scheduledDelivery => 'Scheduled Delivery';

  @override
  String get atTime => 'at';

  @override
  String get estimatedArrival => 'Estimated Arrival';

  @override
  String get noAddressSelected => 'No address selected';

  @override
  String get noAddressesSaved => 'No addresses saved';

  @override
  String get addAddressToCheckout =>
      'Please add a delivery address to continue';

  @override
  String get addAddress => 'Add Address';

  @override
  String get addNewAddress => 'Add New Address';

  @override
  String get addNewAddressToStart => 'Add a new address to start';

  @override
  String get manageAddresses => 'Manage Addresses';

  @override
  String get defaultAddress => 'Default';

  @override
  String get setAsDefault => 'Set as Default';

  @override
  String get addressesTitle => 'Addresses';

  @override
  String get addressDeletedSuccessfully => 'Address deleted successfully';

  @override
  String get addressSetAsDefault => 'Address set as default';

  @override
  String get addressAddedSuccessfully => 'Address added successfully';

  @override
  String get addressUpdatedSuccessfully => 'Address updated successfully';

  @override
  String get deleteAddress => 'Delete Address';

  @override
  String get deleteAddressConfirmation =>
      'Are you sure you want to delete this address?';

  @override
  String get addressTitle => 'Address Title';

  @override
  String get addressTitleHint => 'Example: Home, Work';

  @override
  String get addressTitleRequired => 'Address title is required';

  @override
  String get governorate => 'Governorate';

  @override
  String get selectGovernorate => 'Select governorate';

  @override
  String get selectGovernorateFirst => 'Select governorate first';

  @override
  String get pleaseSelectGovernorate => 'Please select a governorate';

  @override
  String get area => 'Area';

  @override
  String get selectArea => 'Select area';

  @override
  String get pleaseSelectArea => 'Please select an area';

  @override
  String get street => 'Street';

  @override
  String get streetName => 'Street name';

  @override
  String get streetRequired => 'Street name is required';

  @override
  String get buildingNumber => 'Building Number';

  @override
  String get floor => 'Floor';

  @override
  String get floorNumber => 'Floor number';

  @override
  String get apartment => 'Apartment';

  @override
  String get apartmentNumber => 'Apartment number';

  @override
  String get landmark => 'Landmark';

  @override
  String get landmarkHint => 'Example: Next to pharmacy...';

  @override
  String get additionalNotes => 'Additional Notes';

  @override
  String get additionalNotesHint => 'Any additional notes...';

  @override
  String get setAsDefaultAddress => 'Set as default address';

  @override
  String get saveAddress => 'Save Address';

  @override
  String get addressDetails => 'Address Details';

  @override
  String get theDefaultAddress => 'Default Address';

  @override
  String get fullAddress => 'Full Address';

  @override
  String get setAsDefaultAddressButton => 'Set as Default Address';

  @override
  String get editAddress => 'Edit Address';

  @override
  String get addressSetAsDefaultSuccessfully => 'Address set as default';

  @override
  String get errorLoadingAddress => 'Error loading address';

  @override
  String get addressNotAvailable => 'Delivery address not available';

  @override
  String get areaLabel => 'Area';

  @override
  String get streetLabel => 'Street';

  @override
  String get buildingDetailsLabel => 'Building Details';

  @override
  String get landmarkLabel => 'Landmark';

  @override
  String get selectLocationOnMap => 'Select location on map';

  @override
  String get latitude => 'Latitude';

  @override
  String get longitude => 'Longitude';

  @override
  String get pleaseSelectLocation => 'Please select a location on the map';

  @override
  String get tapToSelectLocation => 'Tap to select location';

  @override
  String get confirmLocation => 'Confirm Location';

  @override
  String get openFullMap => 'Open full map';

  @override
  String get deliveryAddressRequired => 'Delivery address is required';

  @override
  String get deliveryAddressTooShort => 'Address is too short';

  @override
  String get deliveryAddressTooLong => 'Address is too long';

  @override
  String get myOrders => 'My Orders';

  @override
  String get orderDetails => 'Order Details';

  @override
  String get orderNumber => 'Order Number';

  @override
  String get orderDate => 'Order Date';

  @override
  String get orderStatus => 'Order Status';

  @override
  String get orderTotal => 'Order Total';

  @override
  String get orderItems => 'Order Items';

  @override
  String get noOrders => 'No orders yet';

  @override
  String get noActiveOrders => 'No active orders';

  @override
  String get noCompletedOrders => 'No completed orders';

  @override
  String get noCancelledOrders => 'No cancelled orders';

  @override
  String get noItems => 'No items';

  @override
  String get trackYourOrders => 'Track your orders';

  @override
  String get trackOrder => 'Track Order';

  @override
  String get cancelOrder => 'Cancel Order';

  @override
  String get cancelOrderConfirmation =>
      'Are you sure you want to cancel this order?';

  @override
  String get cancellationReason => 'Cancellation reason';

  @override
  String get cancellationReasonTitle => 'Cancellation Reason';

  @override
  String get confirmCancel => 'Confirm Cancel';

  @override
  String get orderCancelled => 'Order cancelled';

  @override
  String get cancelledByUser => 'Cancelled by user';

  @override
  String get reorder => 'Reorder';

  @override
  String get reorderPrevious => 'Order Again';

  @override
  String get orderReordered => 'New order created';

  @override
  String get currentStatus => 'Current Status';

  @override
  String get history => 'History';

  @override
  String get noOrderHistory => 'No order history';

  @override
  String get orderNotFound => 'Order not found';

  @override
  String get active => 'Active';

  @override
  String get completed => 'Completed';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get statusDraft => 'Draft';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusPlaced => 'Placed';

  @override
  String get statusAccepted => 'Accepted';

  @override
  String get statusPreparing => 'Preparing';

  @override
  String get statusReady => 'Ready';

  @override
  String get statusPicked => 'On The Way';

  @override
  String get statusDelivered => 'Delivered';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get orderCreated => 'Order Created';

  @override
  String get orderAssigned => 'Assigned to Hero';

  @override
  String get driverOnWay => 'Hero On the Way';

  @override
  String get orderDelivered => 'Delivered';

  @override
  String get invoicesUploaded => 'Invoices Uploaded';

  @override
  String get orderClosed => 'Closed';

  @override
  String get orderSubmittedSuccess => 'Order submitted successfully';

  @override
  String get driver => 'Hero';

  @override
  String get driverInfo => 'Hero Info';

  @override
  String get driverName => 'Hero Name';

  @override
  String get driverPhone => 'Hero Phone';

  @override
  String get contactDriver => 'Contact Hero';

  @override
  String get callDriver => 'Call Hero';

  @override
  String get reviewsTitle => 'Reviews';

  @override
  String get writeReview => 'Write Review';

  @override
  String get rateDriver => 'Rate Hero';

  @override
  String get rateRestaurant => 'Rate Restaurant';

  @override
  String get rateYourExperience => 'Rate your experience with the hero';

  @override
  String get overallRating => 'Overall Rating';

  @override
  String get deliverySpeed => 'Delivery Speed';

  @override
  String get professionalism => 'Professionalism';

  @override
  String get addComment => 'Add comment';

  @override
  String get optional => '(Optional)';

  @override
  String get shareYourThoughts => 'Share your thoughts...';

  @override
  String get addTip => 'Add tip for hero';

  @override
  String get tipAmount => 'Tip Amount';

  @override
  String get submitReview => 'Submit Review';

  @override
  String get reviewSubmitted => 'Thank you for your review!';

  @override
  String get thankYouForReview => 'Your review helps us improve';

  @override
  String get skip => 'Skip';

  @override
  String get rate => 'Rate';

  @override
  String get veryPoor => 'Very Poor';

  @override
  String get poor => 'Poor';

  @override
  String get average => 'Average';

  @override
  String get good => 'Good';

  @override
  String get excellent => 'Excellent';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get termsAndConditions => 'Terms & Conditions';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get logoutConfirmation =>
      'Are you sure you want to logout from your account?';

  @override
  String get manageYourAccount => 'Manage your account';

  @override
  String get defaultUserName => 'User';

  @override
  String get defaultUserInitial => 'U';

  @override
  String get accountSection => 'Account';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get addresses => 'Addresses';

  @override
  String get preferencesSection => 'Preferences';

  @override
  String get currentLanguage => 'English';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get supportSection => 'Support';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get enterFirstName => 'Enter first name';

  @override
  String get enterLastName => 'Enter last name';

  @override
  String get phoneNumberCannotBeChanged => 'Phone number cannot be changed';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get profileUpdatedSuccessfully => 'Profile updated successfully';

  @override
  String get changePasswordTitle => 'Change Password';

  @override
  String get useStrongPassword => 'Make sure to use a strong password';

  @override
  String get enterCurrentPassword => 'Enter current password';

  @override
  String get enterNewPassword => 'Enter new password';

  @override
  String get reEnterNewPassword => 'Re-enter new password';

  @override
  String get passwordChangedSuccessfully => 'Password changed successfully';

  @override
  String get homeTab => 'Home';

  @override
  String get ordersTab => 'Orders';

  @override
  String get cartTab => 'Cart';

  @override
  String get chatTab => 'Chat';

  @override
  String get supportTab => 'Support';

  @override
  String get profileTab => 'Profile';

  @override
  String get chat => 'Chat';

  @override
  String get support => 'Support';

  @override
  String get newOrder => 'New Order';

  @override
  String get liveChat => 'Live Chat';

  @override
  String get chatWithSupport => 'Chat with support team';

  @override
  String get supportTickets => 'Support Tickets';

  @override
  String get reportIssues => 'Report technical issues';

  @override
  String get chatSupportTitle => 'Support Team';

  @override
  String get chatOnline => 'Online';

  @override
  String get chatHint => 'Type your message...';

  @override
  String get chatCamera => 'Camera';

  @override
  String get chatGallery => 'Gallery';

  @override
  String get chatToday => 'Today';

  @override
  String get chatYesterday => 'Yesterday';

  @override
  String get chatEmptyTitle => 'Start a new conversation';

  @override
  String get chatEmptySubtitle =>
      'Send us a message and we\'ll reply as soon as possible. You can also create a custom order or ask about anything.';

  @override
  String get chatLoginRequired => 'Login to chat';

  @override
  String get chatLoginSubtitle =>
      'You need to login to contact the support team';

  @override
  String get chatSend => 'Send';

  @override
  String get chatImageSendError => 'Failed to send image';

  @override
  String get chatMessage => 'Message';

  @override
  String get chatMessageRequired => 'Message cannot be empty';

  @override
  String get chatMessageTooLong => 'Message is too long';

  @override
  String get orderDescription => 'Order Description';

  @override
  String get orderDescriptionRequired => 'Order description is required';

  @override
  String get orderDescriptionTooShort =>
      'Please write a more detailed description (at least 10 characters)';

  @override
  String get orderDescriptionTooLong =>
      'Description is too long (maximum 500 characters)';

  @override
  String get notesOptional => 'Notes (Optional)';

  @override
  String get notesTooLong => 'Notes are too long (maximum 500 characters)';

  @override
  String get ticketTitle => 'Ticket Title';

  @override
  String get ticketTitleRequired => 'Ticket title is required';

  @override
  String get ticketTitleTooShort => 'Title is too short';

  @override
  String get ticketTitleTooLong => 'Title is too long';

  @override
  String get ticketDescription => 'Problem Description';

  @override
  String get ticketDescriptionRequired => 'Problem description is required';

  @override
  String get ticketDescriptionTooShort =>
      'Please write a more detailed description (at least 20 characters)';

  @override
  String get ticketDescriptionTooLong =>
      'Description is too long (maximum 1000 characters)';

  @override
  String get helpCenter => 'Support Center';

  @override
  String get helpHeaderTitle => 'How can we assist you?';

  @override
  String get helpHeaderSubtitle =>
      'Browse common questions or contact us directly for help';

  @override
  String get frequentlyAskedQuestions => 'Frequently Asked Questions';

  @override
  String get helpOrdersTitle => 'Orders';

  @override
  String get helpQ1 => 'How can I place a new order?';

  @override
  String get helpA1 =>
      'Select your favorite restaurant from the home screen, browse the menu, and add items to your cart. Once finished, tap the cart to review and complete your order.';

  @override
  String get helpQ1_1 =>
      'What is the \"As You Wish\" feature and how do I use it?';

  @override
  String get helpA1_1 =>
      'The \"As You Wish\" feature lets you order any product directly through chat without browsing menus. Tap the logo icon in the center of the bottom navigation bar, then type the name of the store you want to order from, choose the product you want, or simply send a photo of your order. We\'ll confirm your request and handle it instantly, effortlessly.';

  @override
  String get helpQ2 => 'How do I cancel my order?';

  @override
  String get helpA2 =>
      'You can cancel your order from the order details page before the restaurant starts preparing it. If preparation has already begun or you encounter an issue, contact support via chat by tapping the logo in the center of the bottom navigation bar.';

  @override
  String get helpQ3 => 'How can I track my order?';

  @override
  String get helpA3 =>
      'Go to \"My Orders\" to view your current order status. You will receive notifications for every status update.';

  @override
  String get helpChatTitle => 'Chat & Support';

  @override
  String get helpQ10 => 'How can I contact the support team?';

  @override
  String get helpA10 =>
      'Tap the logo in the center of the bottom navigation bar to open the \"As You Wish\" screen, where you can chat directly with the support team for any inquiry or issue.';

  @override
  String get helpQ11 => 'Can I create a custom order via chat?';

  @override
  String get helpA11 =>
      'Yes! If you can\'t find the product you\'re looking for in the app, you can contact us through the \"As You Wish\" feature to create a custom order. We provide a variety of food products, health and pharmaceutical supplies, household essentials, and more.';

  @override
  String get helpQ12 => 'How are prices confirmed for custom orders?';

  @override
  String get helpA12 =>
      'When you place an order through the \"As You Wish\" feature, the delivery hero will provide you with the purchase receipt upon delivery. We follow this process to ensure full transparency and to give you an official reference in case you want to raise any inquiry or complaint later.';

  @override
  String get helpQ13 => 'What should I do if I have an issue with my order?';

  @override
  String get helpA13 =>
      'Open the \"As You Wish\" screen by tapping the logo in the bottom navigation bar and describe the issue. Our support team will assist you promptly.';

  @override
  String get helpDeliveryTitle => 'Delivery';

  @override
  String get helpQ4 => 'Which delivery areas are covered?';

  @override
  String get helpA4 =>
      'We deliver to all areas displayed in the app. Delivery fees and estimated arrival times are calculated based on the distance between you and the restaurant.';

  @override
  String get helpQ5 => 'How long does delivery usually take?';

  @override
  String get helpA5 =>
      'Delivery times vary depending on the restaurant and distance. The estimated delivery time is shown on each restaurant\'s page before placing your order.';

  @override
  String get helpPaymentTitle => 'Payment';

  @override
  String get helpQ6 => 'What payment methods are currently available?';

  @override
  String get helpA6 =>
      'We currently offer Cash on Delivery. Online payment methods will be introduced soon.';

  @override
  String get helpQ7 => 'Is there a minimum order requirement?';

  @override
  String get helpA7 =>
      'Yes, each restaurant has a minimum order amount displayed on its page. Orders below this amount cannot be completed.';

  @override
  String get helpAccountTitle => 'Account';

  @override
  String get helpQ8 => 'How can I update my account information?';

  @override
  String get helpA8 =>
      'Go to your profile page and tap \"Edit Profile\" to update your details. You can also change your password from the same section. Your phone number cannot be modified as it is linked to your account.';

  @override
  String get helpQ9 => 'How do I add or edit delivery addresses?';

  @override
  String get helpA9 =>
      'From your profile page, tap \"My Addresses\" to manage your delivery locations. You can add new addresses, edit existing ones, or set a default address.';

  @override
  String get contactUsTitle => 'Contact Us';

  @override
  String get contactUsSubtitle =>
      'Have a question or suggestion? We\'re here to help';

  @override
  String get sendEmail => 'Send Email';

  @override
  String get emailCopied => 'Email copied successfully';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get call => 'Call';

  @override
  String get phoneCopied => 'Phone number copied';

  @override
  String get notifications => 'Notifications';

  @override
  String get markAllAsRead => 'Mark all as read';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get noNotificationsMessage =>
      'Your order updates and offers will appear here';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountDescription =>
      'Your account will be deactivated and all your data will be deleted. This action cannot be undone.';

  @override
  String get deleteAccountPasswordHint => 'Password';

  @override
  String get deleteAccountPasswordRequired => 'Please enter your password';

  @override
  String get deleteAccountReasonHint => 'Reason for deletion (optional)';

  @override
  String get deleteAccountConfirm => 'Delete Account Permanently';
}
