import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Super Driver'**
  String get appName;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Your Orders, Our Commands'**
  String get welcomeMessage;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Failed to connect to server'**
  String get networkError;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'SYP'**
  String get currency;

  /// No description provided for @currencyCode.
  ///
  /// In en, this message translates to:
  /// **'SYP'**
  String get currencyCode;

  /// No description provided for @minuteShort.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get minuteShort;

  /// No description provided for @secondShort.
  ///
  /// In en, this message translates to:
  /// **'s'**
  String get secondShort;

  /// No description provided for @minute.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minute;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minutes;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hours;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get seconds;

  /// No description provided for @ago.
  ///
  /// In en, this message translates to:
  /// **'ago'**
  String get ago;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @am.
  ///
  /// In en, this message translates to:
  /// **'AM'**
  String get am;

  /// No description provided for @pm.
  ///
  /// In en, this message translates to:
  /// **'PM'**
  String get pm;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} minutes ago'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} hours ago'**
  String hoursAgo(int count);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String daysAgo(int count);

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @enterDetailsToStart.
  ///
  /// In en, this message translates to:
  /// **'Enter your details to get started'**
  String get enterDetailsToStart;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @byCreatingAccount.
  ///
  /// In en, this message translates to:
  /// **'By creating an account, you agree to our'**
  String get byCreatingAccount;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @signInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInToContinue;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @verifyPhone.
  ///
  /// In en, this message translates to:
  /// **'Verify Phone Number'**
  String get verifyPhone;

  /// No description provided for @enterOtpSent.
  ///
  /// In en, this message translates to:
  /// **'Enter the verification code sent to'**
  String get enterOtpSent;

  /// No description provided for @enterOtpSentTo.
  ///
  /// In en, this message translates to:
  /// **'Please enter the verification code sent to'**
  String get enterOtpSentTo;

  /// No description provided for @changePhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Change phone number?'**
  String get changePhoneNumber;

  /// No description provided for @verificationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Verified successfully! Please sign in'**
  String get verificationSuccess;

  /// No description provided for @enterPhoneToReset.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number to reset your password'**
  String get enterPhoneToReset;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get sendCode;

  /// No description provided for @rememberPassword.
  ///
  /// In en, this message translates to:
  /// **'Remember your password?'**
  String get rememberPassword;

  /// No description provided for @resettingPassword.
  ///
  /// In en, this message translates to:
  /// **'Resetting password...'**
  String get resettingPassword;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully! Please sign in with your new password'**
  String get passwordResetSuccess;

  /// No description provided for @loginRequired.
  ///
  /// In en, this message translates to:
  /// **'Login Required'**
  String get loginRequired;

  /// No description provided for @loginRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Please login to access this feature'**
  String get loginRequiredMessage;

  /// No description provided for @continueBrowsing.
  ///
  /// In en, this message translates to:
  /// **'Continue Browsing'**
  String get continueBrowsing;

  /// No description provided for @loginToViewCart.
  ///
  /// In en, this message translates to:
  /// **'Please login to view your cart'**
  String get loginToViewCart;

  /// No description provided for @loginToAddToCart.
  ///
  /// In en, this message translates to:
  /// **'Please login first to add products to cart'**
  String get loginToAddToCart;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @verificationCode.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get verificationCode;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneRequired;

  /// No description provided for @phoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get phoneInvalid;

  /// No description provided for @phoneTooShort.
  ///
  /// In en, this message translates to:
  /// **'Phone number is too short'**
  String get phoneTooShort;

  /// No description provided for @phoneTooLong.
  ///
  /// In en, this message translates to:
  /// **'Phone number is too long'**
  String get phoneTooLong;

  /// No description provided for @phoneOnlyNumbers.
  ///
  /// In en, this message translates to:
  /// **'Phone number must contain only numbers'**
  String get phoneOnlyNumbers;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get emailInvalid;

  /// No description provided for @firstNameRequired.
  ///
  /// In en, this message translates to:
  /// **'First name is required'**
  String get firstNameRequired;

  /// No description provided for @firstNameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get firstNameTooShort;

  /// No description provided for @firstNameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Name is too long'**
  String get firstNameTooLong;

  /// No description provided for @lastNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Last name is required'**
  String get lastNameRequired;

  /// No description provided for @lastNameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get lastNameTooShort;

  /// No description provided for @lastNameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Name is too long'**
  String get lastNameTooLong;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMinLength;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password confirmation is required'**
  String get confirmPasswordRequired;

  /// No description provided for @passwordsNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsNotMatch;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @currentPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Current password is required'**
  String get currentPasswordRequired;

  /// No description provided for @newPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'New password is required'**
  String get newPasswordRequired;

  /// No description provided for @otpRequired.
  ///
  /// In en, this message translates to:
  /// **'Verification code is required'**
  String get otpRequired;

  /// No description provided for @otpInvalid.
  ///
  /// In en, this message translates to:
  /// **'Verification code must be 6 digits'**
  String get otpInvalid;

  /// No description provided for @otpOnlyNumbers.
  ///
  /// In en, this message translates to:
  /// **'Verification code must contain only numbers'**
  String get otpOnlyNumbers;

  /// No description provided for @invalidOtp.
  ///
  /// In en, this message translates to:
  /// **'Invalid verification code'**
  String get invalidOtp;

  /// No description provided for @otpSent.
  ///
  /// In en, this message translates to:
  /// **'Verification code sent'**
  String get otpSent;

  /// No description provided for @verifyingCode.
  ///
  /// In en, this message translates to:
  /// **'Verifying code...'**
  String get verifyingCode;

  /// No description provided for @otpResent.
  ///
  /// In en, this message translates to:
  /// **'Verification code resent successfully'**
  String get otpResent;

  /// No description provided for @sendingVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Sending verification code...'**
  String get sendingVerificationCode;

  /// No description provided for @didntReceiveCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code?'**
  String get didntReceiveCode;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in'**
  String get resendIn;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @homeScreen.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeScreen;

  /// No description provided for @deliverTo.
  ///
  /// In en, this message translates to:
  /// **'Deliver to'**
  String get deliverTo;

  /// No description provided for @deliveryTo.
  ///
  /// In en, this message translates to:
  /// **'Deliver to'**
  String get deliveryTo;

  /// No description provided for @selectLocation.
  ///
  /// In en, this message translates to:
  /// **'Select your location'**
  String get selectLocation;

  /// No description provided for @changeAddress.
  ///
  /// In en, this message translates to:
  /// **'Change Address'**
  String get changeAddress;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search for restaurants or dishes...'**
  String get searchPlaceholder;

  /// No description provided for @searchRestaurantsAndFood.
  ///
  /// In en, this message translates to:
  /// **'Search restaurants and food'**
  String get searchRestaurantsAndFood;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Burgers, pizza, shawarma...'**
  String get searchHint;

  /// No description provided for @searchRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Search restaurants...'**
  String get searchRestaurants;

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'Search Results'**
  String get searchResults;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @tryDifferentKeywords.
  ///
  /// In en, this message translates to:
  /// **'Try different keywords'**
  String get tryDifferentKeywords;

  /// No description provided for @tryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get tryDifferentSearch;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent Searches'**
  String get recentSearches;

  /// No description provided for @clearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get clearHistory;

  /// No description provided for @searchFailed.
  ///
  /// In en, this message translates to:
  /// **'Search failed, try again'**
  String get searchFailed;

  /// No description provided for @results.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get results;

  /// No description provided for @searchInMenu.
  ///
  /// In en, this message translates to:
  /// **'Search in menu...'**
  String get searchInMenu;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No search results'**
  String get noSearchResults;

  /// No description provided for @noResultsFor.
  ///
  /// In en, this message translates to:
  /// **'No results for'**
  String get noResultsFor;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @featuredRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Featured Restaurants'**
  String get featuredRestaurants;

  /// No description provided for @popularRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Popular Restaurants'**
  String get popularRestaurants;

  /// No description provided for @newRestaurants.
  ///
  /// In en, this message translates to:
  /// **'New on SuperDriver'**
  String get newRestaurants;

  /// No description provided for @discountRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Offers & Discounts'**
  String get discountRestaurants;

  /// No description provided for @nearbyRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Nearby Restaurants'**
  String get nearbyRestaurants;

  /// No description provided for @recommendedForYou.
  ///
  /// In en, this message translates to:
  /// **'Recommended for You'**
  String get recommendedForYou;

  /// No description provided for @popularDishes.
  ///
  /// In en, this message translates to:
  /// **'Popular Dishes'**
  String get popularDishes;

  /// No description provided for @popularProducts.
  ///
  /// In en, this message translates to:
  /// **'Popular Dishes'**
  String get popularProducts;

  /// No description provided for @trending.
  ///
  /// In en, this message translates to:
  /// **'Trending'**
  String get trending;

  /// No description provided for @trendingNow.
  ///
  /// In en, this message translates to:
  /// **'Trending Now'**
  String get trendingNow;

  /// No description provided for @deals.
  ///
  /// In en, this message translates to:
  /// **'Deals'**
  String get deals;

  /// No description provided for @offer.
  ///
  /// In en, this message translates to:
  /// **'Offer'**
  String get offer;

  /// No description provided for @seasonal.
  ///
  /// In en, this message translates to:
  /// **'Seasonal'**
  String get seasonal;

  /// No description provided for @newLabel.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newLabel;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @featured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get featured;

  /// No description provided for @freeDelivery.
  ///
  /// In en, this message translates to:
  /// **'Free Delivery'**
  String get freeDelivery;

  /// No description provided for @deliveryTime.
  ///
  /// In en, this message translates to:
  /// **'Delivery Time'**
  String get deliveryTime;

  /// No description provided for @minOrder.
  ///
  /// In en, this message translates to:
  /// **'Minimum Order'**
  String get minOrder;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'reviews'**
  String get reviews;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'OFF'**
  String get off;

  /// No description provided for @noRestaurants.
  ///
  /// In en, this message translates to:
  /// **'No restaurants found'**
  String get noRestaurants;

  /// No description provided for @noProducts.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProducts;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'orders'**
  String get orders;

  /// No description provided for @restaurant.
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get restaurant;

  /// No description provided for @dish.
  ///
  /// In en, this message translates to:
  /// **'Dish'**
  String get dish;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @locationPermission.
  ///
  /// In en, this message translates to:
  /// **'We need location permission to find nearby restaurants'**
  String get locationPermission;

  /// No description provided for @enableLocation.
  ///
  /// In en, this message translates to:
  /// **'Enable Location'**
  String get enableLocation;

  /// No description provided for @enableLocationService.
  ///
  /// In en, this message translates to:
  /// **'Please enable location service'**
  String get enableLocationService;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied'**
  String get locationPermissionDenied;

  /// No description provided for @locationPermissionPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission permanently denied'**
  String get locationPermissionPermanentlyDenied;

  /// No description provided for @locationServiceDisabled.
  ///
  /// In en, this message translates to:
  /// **'Please enable location service'**
  String get locationServiceDisabled;

  /// No description provided for @locationServicesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled. Please enable them.'**
  String get locationServicesDisabled;

  /// No description provided for @locationError.
  ///
  /// In en, this message translates to:
  /// **'Error getting location'**
  String get locationError;

  /// No description provided for @failedToGetLocation.
  ///
  /// In en, this message translates to:
  /// **'Failed to get current location'**
  String get failedToGetLocation;

  /// No description provided for @deliveryLocation.
  ///
  /// In en, this message translates to:
  /// **'Delivery Location'**
  String get deliveryLocation;

  /// No description provided for @selectDeliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Where should we deliver?'**
  String get selectDeliveryAddress;

  /// No description provided for @selectDeliveryLocation.
  ///
  /// In en, this message translates to:
  /// **'Select delivery location'**
  String get selectDeliveryLocation;

  /// No description provided for @whereToDeliver.
  ///
  /// In en, this message translates to:
  /// **'Where should we deliver?'**
  String get whereToDeliver;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get currentLocation;

  /// No description provided for @usingGPS.
  ///
  /// In en, this message translates to:
  /// **'Using GPS'**
  String get usingGPS;

  /// No description provided for @useCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use Current Location'**
  String get useCurrentLocation;

  /// No description provided for @detectMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Detect my location automatically'**
  String get detectMyLocation;

  /// No description provided for @detectAutomatically.
  ///
  /// In en, this message translates to:
  /// **'Detect automatically'**
  String get detectAutomatically;

  /// No description provided for @detectYourLocation.
  ///
  /// In en, this message translates to:
  /// **'Using GPS to detect your location'**
  String get detectYourLocation;

  /// No description provided for @searchForLocation.
  ///
  /// In en, this message translates to:
  /// **'Search for a location...'**
  String get searchForLocation;

  /// No description provided for @searchAddress.
  ///
  /// In en, this message translates to:
  /// **'Search address'**
  String get searchAddress;

  /// No description provided for @searchByStreetOrArea.
  ///
  /// In en, this message translates to:
  /// **'Search by street or area name'**
  String get searchByStreetOrArea;

  /// No description provided for @savedAddresses.
  ///
  /// In en, this message translates to:
  /// **'Saved Addresses'**
  String get savedAddresses;

  /// No description provided for @selectFromSaved.
  ///
  /// In en, this message translates to:
  /// **'Select from your saved addresses'**
  String get selectFromSaved;

  /// No description provided for @selectAddress.
  ///
  /// In en, this message translates to:
  /// **'Select Address'**
  String get selectAddress;

  /// No description provided for @tapToSelectAddress.
  ///
  /// In en, this message translates to:
  /// **'Tap to select delivery address'**
  String get tapToSelectAddress;

  /// No description provided for @addNew.
  ///
  /// In en, this message translates to:
  /// **'Add New'**
  String get addNew;

  /// No description provided for @noSavedAddresses.
  ///
  /// In en, this message translates to:
  /// **'No Saved Addresses'**
  String get noSavedAddresses;

  /// No description provided for @addAddressForFasterDelivery.
  ///
  /// In en, this message translates to:
  /// **'Add an address for faster delivery'**
  String get addAddressForFasterDelivery;

  /// No description provided for @addAddressForFasterCheckout.
  ///
  /// In en, this message translates to:
  /// **'Add an address for faster checkout'**
  String get addAddressForFasterCheckout;

  /// No description provided for @defaultLabel.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultLabel;

  /// No description provided for @manage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manage;

  /// No description provided for @restaurants.
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get restaurants;

  /// No description provided for @restaurantDetails.
  ///
  /// In en, this message translates to:
  /// **'Restaurant Details'**
  String get restaurantDetails;

  /// No description provided for @allRestaurants.
  ///
  /// In en, this message translates to:
  /// **'All Restaurants'**
  String get allRestaurants;

  /// No description provided for @filterRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Filter Restaurants'**
  String get filterRestaurants;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @deliveryFeeSort.
  ///
  /// In en, this message translates to:
  /// **'Delivery Fee'**
  String get deliveryFeeSort;

  /// No description provided for @mostOrdered.
  ///
  /// In en, this message translates to:
  /// **'Most Ordered'**
  String get mostOrdered;

  /// No description provided for @defaultSort.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultSort;

  /// No description provided for @minimumOrderSort.
  ///
  /// In en, this message translates to:
  /// **'Minimum Order'**
  String get minimumOrderSort;

  /// No description provided for @newest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get newest;

  /// No description provided for @openNow.
  ///
  /// In en, this message translates to:
  /// **'Open Now'**
  String get openNow;

  /// No description provided for @hasOffers.
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get hasOffers;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get loadMore;

  /// No description provided for @noMoreRestaurants.
  ///
  /// In en, this message translates to:
  /// **'No more restaurants'**
  String get noMoreRestaurants;

  /// No description provided for @tryChangingFilters.
  ///
  /// In en, this message translates to:
  /// **'Try changing filters or search'**
  String get tryChangingFilters;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// No description provided for @workingHours.
  ///
  /// In en, this message translates to:
  /// **'Working Hours'**
  String get workingHours;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @closedDay.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closedDay;

  /// No description provided for @callRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Call Restaurant'**
  String get callRestaurant;

  /// No description provided for @viewMenu.
  ///
  /// In en, this message translates to:
  /// **'View Menu'**
  String get viewMenu;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @restaurantInfo.
  ///
  /// In en, this message translates to:
  /// **'Restaurant Info'**
  String get restaurantInfo;

  /// No description provided for @restaurantAddress.
  ///
  /// In en, this message translates to:
  /// **'Restaurant Address'**
  String get restaurantAddress;

  /// No description provided for @discountOnAllProducts.
  ///
  /// In en, this message translates to:
  /// **'Discount on all products'**
  String get discountOnAllProducts;

  /// No description provided for @delivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get delivery;

  /// No description provided for @minimum.
  ///
  /// In en, this message translates to:
  /// **'Minimum'**
  String get minimum;

  /// No description provided for @loadingMenu.
  ///
  /// In en, this message translates to:
  /// **'Loading menu...'**
  String get loadingMenu;

  /// No description provided for @noMenuAvailable.
  ///
  /// In en, this message translates to:
  /// **'No menu available'**
  String get noMenuAvailable;

  /// No description provided for @noProductsInCategory.
  ///
  /// In en, this message translates to:
  /// **'No products in this category'**
  String get noProductsInCategory;

  /// No description provided for @unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailable;

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @myCart.
  ///
  /// In en, this message translates to:
  /// **'My Cart'**
  String get myCart;

  /// No description provided for @cartDetails.
  ///
  /// In en, this message translates to:
  /// **'Cart Details'**
  String get cartDetails;

  /// No description provided for @emptyCart.
  ///
  /// In en, this message translates to:
  /// **'Cart is Empty'**
  String get emptyCart;

  /// No description provided for @emptyCartMessage.
  ///
  /// In en, this message translates to:
  /// **'Start adding products to your cart'**
  String get emptyCartMessage;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCart;

  /// No description provided for @removeFromCart.
  ///
  /// In en, this message translates to:
  /// **'Remove from Cart'**
  String get removeFromCart;

  /// No description provided for @viewCart.
  ///
  /// In en, this message translates to:
  /// **'View Cart'**
  String get viewCart;

  /// No description provided for @browseRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Browse Restaurants'**
  String get browseRestaurants;

  /// No description provided for @noCart.
  ///
  /// In en, this message translates to:
  /// **'No cart'**
  String get noCart;

  /// No description provided for @cartDeleted.
  ///
  /// In en, this message translates to:
  /// **'Cart deleted'**
  String get cartDeleted;

  /// No description provided for @deleteCart.
  ///
  /// In en, this message translates to:
  /// **'Delete Cart'**
  String get deleteCart;

  /// No description provided for @deleteCartConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this cart? This action cannot be undone.'**
  String get deleteCartConfirmation;

  /// No description provided for @cartExpired.
  ///
  /// In en, this message translates to:
  /// **'This cart has expired'**
  String get cartExpired;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'remaining'**
  String get remaining;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'more'**
  String get more;

  /// No description provided for @moreItems.
  ///
  /// In en, this message translates to:
  /// **'more items'**
  String get moreItems;

  /// No description provided for @otherItems.
  ///
  /// In en, this message translates to:
  /// **'other items'**
  String get otherItems;

  /// No description provided for @moreOtherItems.
  ///
  /// In en, this message translates to:
  /// **'more items'**
  String get moreOtherItems;

  /// No description provided for @clearCart.
  ///
  /// In en, this message translates to:
  /// **'Clear Cart'**
  String get clearCart;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @clearCartConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove all items from your cart?'**
  String get clearCartConfirmation;

  /// No description provided for @cartCleared.
  ///
  /// In en, this message translates to:
  /// **'Cart cleared'**
  String get cartCleared;

  /// No description provided for @itemAdded.
  ///
  /// In en, this message translates to:
  /// **'Item added'**
  String get itemAdded;

  /// No description provided for @itemRemoved.
  ///
  /// In en, this message translates to:
  /// **'Item removed from cart'**
  String get itemRemoved;

  /// No description provided for @itemUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Item unavailable'**
  String get itemUnavailable;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @quantityUpdated.
  ///
  /// In en, this message translates to:
  /// **'Quantity updated'**
  String get quantityUpdated;

  /// No description provided for @addCoupon.
  ///
  /// In en, this message translates to:
  /// **'Add Coupon'**
  String get addCoupon;

  /// No description provided for @enterCouponCode.
  ///
  /// In en, this message translates to:
  /// **'Enter coupon code'**
  String get enterCouponCode;

  /// No description provided for @couponApplied.
  ///
  /// In en, this message translates to:
  /// **'Coupon applied successfully'**
  String get couponApplied;

  /// No description provided for @couponRemoved.
  ///
  /// In en, this message translates to:
  /// **'Coupon removed'**
  String get couponRemoved;

  /// No description provided for @invalidCoupon.
  ///
  /// In en, this message translates to:
  /// **'Invalid coupon'**
  String get invalidCoupon;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @deliveryFee.
  ///
  /// In en, this message translates to:
  /// **'Delivery Fee'**
  String get deliveryFee;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @continueToCheckout.
  ///
  /// In en, this message translates to:
  /// **'Continue to Checkout'**
  String get continueToCheckout;

  /// No description provided for @proceedToCheckout.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Checkout'**
  String get proceedToCheckout;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @orderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get orderSummary;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @deliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Delivery Address'**
  String get deliveryAddress;

  /// No description provided for @orderNotes.
  ///
  /// In en, this message translates to:
  /// **'Order Notes'**
  String get orderNotes;

  /// No description provided for @addOrderNotes.
  ///
  /// In en, this message translates to:
  /// **'Add special instructions (optional)'**
  String get addOrderNotes;

  /// No description provided for @confirmOrder.
  ///
  /// In en, this message translates to:
  /// **'Confirm Order'**
  String get confirmOrder;

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'Place Order'**
  String get placeOrder;

  /// No description provided for @orderPlacedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Order placed successfully!'**
  String get orderPlacedSuccessfully;

  /// No description provided for @orderConfirmedMessage.
  ///
  /// In en, this message translates to:
  /// **'Thank you! Your order will be prepared soon'**
  String get orderConfirmedMessage;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @cashOnDelivery.
  ///
  /// In en, this message translates to:
  /// **'Cash on Delivery'**
  String get cashOnDelivery;

  /// No description provided for @payWhenReceive.
  ///
  /// In en, this message translates to:
  /// **'Pay when you receive your order'**
  String get payWhenReceive;

  /// No description provided for @creditCard.
  ///
  /// In en, this message translates to:
  /// **'Credit Card'**
  String get creditCard;

  /// No description provided for @wallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// No description provided for @contactPhone.
  ///
  /// In en, this message translates to:
  /// **'Contact Phone'**
  String get contactPhone;

  /// No description provided for @contactNumber.
  ///
  /// In en, this message translates to:
  /// **'Contact Number'**
  String get contactNumber;

  /// No description provided for @phoneWillBeUsed.
  ///
  /// In en, this message translates to:
  /// **'This number will be used to contact you for this order'**
  String get phoneWillBeUsed;

  /// No description provided for @phoneContactMessage.
  ///
  /// In en, this message translates to:
  /// **'You will be contacted on this number for this order'**
  String get phoneContactMessage;

  /// No description provided for @enterPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get enterPhone;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get invalidPhone;

  /// No description provided for @invalidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get invalidPhoneNumber;

  /// No description provided for @pleaseEnterPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number'**
  String get pleaseEnterPhone;

  /// No description provided for @immediateDelivery.
  ///
  /// In en, this message translates to:
  /// **'Immediate Delivery'**
  String get immediateDelivery;

  /// No description provided for @within30to45min.
  ///
  /// In en, this message translates to:
  /// **'Within 30-45 minutes'**
  String get within30to45min;

  /// No description provided for @within30To45Minutes.
  ///
  /// In en, this message translates to:
  /// **'Within 30-45 minutes'**
  String get within30To45Minutes;

  /// No description provided for @scheduleDelivery.
  ///
  /// In en, this message translates to:
  /// **'Schedule Delivery'**
  String get scheduleDelivery;

  /// No description provided for @chooseSpecificTime.
  ///
  /// In en, this message translates to:
  /// **'Choose a specific time'**
  String get chooseSpecificTime;

  /// No description provided for @selectDateAndTime.
  ///
  /// In en, this message translates to:
  /// **'Select date and time'**
  String get selectDateAndTime;

  /// No description provided for @pleaseSelectDeliveryTime.
  ///
  /// In en, this message translates to:
  /// **'Please select delivery time'**
  String get pleaseSelectDeliveryTime;

  /// No description provided for @scheduledDelivery.
  ///
  /// In en, this message translates to:
  /// **'Scheduled Delivery'**
  String get scheduledDelivery;

  /// No description provided for @atTime.
  ///
  /// In en, this message translates to:
  /// **'at'**
  String get atTime;

  /// No description provided for @estimatedArrival.
  ///
  /// In en, this message translates to:
  /// **'Estimated Arrival'**
  String get estimatedArrival;

  /// No description provided for @noAddressSelected.
  ///
  /// In en, this message translates to:
  /// **'No address selected'**
  String get noAddressSelected;

  /// No description provided for @noAddressesSaved.
  ///
  /// In en, this message translates to:
  /// **'No addresses saved'**
  String get noAddressesSaved;

  /// No description provided for @addAddressToCheckout.
  ///
  /// In en, this message translates to:
  /// **'Please add a delivery address to continue'**
  String get addAddressToCheckout;

  /// No description provided for @addAddress.
  ///
  /// In en, this message translates to:
  /// **'Add Address'**
  String get addAddress;

  /// No description provided for @addNewAddress.
  ///
  /// In en, this message translates to:
  /// **'Add New Address'**
  String get addNewAddress;

  /// No description provided for @addNewAddressToStart.
  ///
  /// In en, this message translates to:
  /// **'Add a new address to start'**
  String get addNewAddressToStart;

  /// No description provided for @manageAddresses.
  ///
  /// In en, this message translates to:
  /// **'Manage Addresses'**
  String get manageAddresses;

  /// No description provided for @defaultAddress.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultAddress;

  /// No description provided for @setAsDefault.
  ///
  /// In en, this message translates to:
  /// **'Set as Default'**
  String get setAsDefault;

  /// No description provided for @addressesTitle.
  ///
  /// In en, this message translates to:
  /// **'Addresses'**
  String get addressesTitle;

  /// No description provided for @addressDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Address deleted successfully'**
  String get addressDeletedSuccessfully;

  /// No description provided for @addressSetAsDefault.
  ///
  /// In en, this message translates to:
  /// **'Address set as default'**
  String get addressSetAsDefault;

  /// No description provided for @addressAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Address added successfully'**
  String get addressAddedSuccessfully;

  /// No description provided for @addressUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Address updated successfully'**
  String get addressUpdatedSuccessfully;

  /// No description provided for @deleteAddress.
  ///
  /// In en, this message translates to:
  /// **'Delete Address'**
  String get deleteAddress;

  /// No description provided for @deleteAddressConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this address?'**
  String get deleteAddressConfirmation;

  /// No description provided for @addressTitle.
  ///
  /// In en, this message translates to:
  /// **'Address Title'**
  String get addressTitle;

  /// No description provided for @addressTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Example: Home, Work'**
  String get addressTitleHint;

  /// No description provided for @addressTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Address title is required'**
  String get addressTitleRequired;

  /// No description provided for @governorate.
  ///
  /// In en, this message translates to:
  /// **'Governorate'**
  String get governorate;

  /// No description provided for @selectGovernorate.
  ///
  /// In en, this message translates to:
  /// **'Select governorate'**
  String get selectGovernorate;

  /// No description provided for @selectGovernorateFirst.
  ///
  /// In en, this message translates to:
  /// **'Select governorate first'**
  String get selectGovernorateFirst;

  /// No description provided for @pleaseSelectGovernorate.
  ///
  /// In en, this message translates to:
  /// **'Please select a governorate'**
  String get pleaseSelectGovernorate;

  /// No description provided for @area.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get area;

  /// No description provided for @selectArea.
  ///
  /// In en, this message translates to:
  /// **'Select area'**
  String get selectArea;

  /// No description provided for @pleaseSelectArea.
  ///
  /// In en, this message translates to:
  /// **'Please select an area'**
  String get pleaseSelectArea;

  /// No description provided for @street.
  ///
  /// In en, this message translates to:
  /// **'Street'**
  String get street;

  /// No description provided for @streetName.
  ///
  /// In en, this message translates to:
  /// **'Street name'**
  String get streetName;

  /// No description provided for @streetRequired.
  ///
  /// In en, this message translates to:
  /// **'Street name is required'**
  String get streetRequired;

  /// No description provided for @buildingNumber.
  ///
  /// In en, this message translates to:
  /// **'Building Number'**
  String get buildingNumber;

  /// No description provided for @floor.
  ///
  /// In en, this message translates to:
  /// **'Floor'**
  String get floor;

  /// No description provided for @floorNumber.
  ///
  /// In en, this message translates to:
  /// **'Floor number'**
  String get floorNumber;

  /// No description provided for @apartment.
  ///
  /// In en, this message translates to:
  /// **'Apartment'**
  String get apartment;

  /// No description provided for @apartmentNumber.
  ///
  /// In en, this message translates to:
  /// **'Apartment number'**
  String get apartmentNumber;

  /// No description provided for @landmark.
  ///
  /// In en, this message translates to:
  /// **'Landmark'**
  String get landmark;

  /// No description provided for @landmarkHint.
  ///
  /// In en, this message translates to:
  /// **'Example: Next to pharmacy...'**
  String get landmarkHint;

  /// No description provided for @additionalNotes.
  ///
  /// In en, this message translates to:
  /// **'Additional Notes'**
  String get additionalNotes;

  /// No description provided for @additionalNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Any additional notes...'**
  String get additionalNotesHint;

  /// No description provided for @setAsDefaultAddress.
  ///
  /// In en, this message translates to:
  /// **'Set as default address'**
  String get setAsDefaultAddress;

  /// No description provided for @saveAddress.
  ///
  /// In en, this message translates to:
  /// **'Save Address'**
  String get saveAddress;

  /// No description provided for @addressDetails.
  ///
  /// In en, this message translates to:
  /// **'Address Details'**
  String get addressDetails;

  /// No description provided for @theDefaultAddress.
  ///
  /// In en, this message translates to:
  /// **'Default Address'**
  String get theDefaultAddress;

  /// No description provided for @fullAddress.
  ///
  /// In en, this message translates to:
  /// **'Full Address'**
  String get fullAddress;

  /// No description provided for @setAsDefaultAddressButton.
  ///
  /// In en, this message translates to:
  /// **'Set as Default Address'**
  String get setAsDefaultAddressButton;

  /// No description provided for @editAddress.
  ///
  /// In en, this message translates to:
  /// **'Edit Address'**
  String get editAddress;

  /// No description provided for @addressSetAsDefaultSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Address set as default'**
  String get addressSetAsDefaultSuccessfully;

  /// No description provided for @errorLoadingAddress.
  ///
  /// In en, this message translates to:
  /// **'Error loading address'**
  String get errorLoadingAddress;

  /// No description provided for @addressNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Delivery address not available'**
  String get addressNotAvailable;

  /// No description provided for @areaLabel.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get areaLabel;

  /// No description provided for @streetLabel.
  ///
  /// In en, this message translates to:
  /// **'Street'**
  String get streetLabel;

  /// No description provided for @buildingDetailsLabel.
  ///
  /// In en, this message translates to:
  /// **'Building Details'**
  String get buildingDetailsLabel;

  /// No description provided for @landmarkLabel.
  ///
  /// In en, this message translates to:
  /// **'Landmark'**
  String get landmarkLabel;

  /// No description provided for @selectLocationOnMap.
  ///
  /// In en, this message translates to:
  /// **'Select location on map'**
  String get selectLocationOnMap;

  /// No description provided for @latitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get latitude;

  /// No description provided for @longitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get longitude;

  /// No description provided for @pleaseSelectLocation.
  ///
  /// In en, this message translates to:
  /// **'Please select a location on the map'**
  String get pleaseSelectLocation;

  /// No description provided for @tapToSelectLocation.
  ///
  /// In en, this message translates to:
  /// **'Tap to select location'**
  String get tapToSelectLocation;

  /// No description provided for @confirmLocation.
  ///
  /// In en, this message translates to:
  /// **'Confirm Location'**
  String get confirmLocation;

  /// No description provided for @openFullMap.
  ///
  /// In en, this message translates to:
  /// **'Open full map'**
  String get openFullMap;

  /// No description provided for @deliveryAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'Delivery address is required'**
  String get deliveryAddressRequired;

  /// No description provided for @deliveryAddressTooShort.
  ///
  /// In en, this message translates to:
  /// **'Address is too short'**
  String get deliveryAddressTooShort;

  /// No description provided for @deliveryAddressTooLong.
  ///
  /// In en, this message translates to:
  /// **'Address is too long'**
  String get deliveryAddressTooLong;

  /// No description provided for @myOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get myOrders;

  /// No description provided for @orderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetails;

  /// No description provided for @orderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order Number'**
  String get orderNumber;

  /// No description provided for @orderDate.
  ///
  /// In en, this message translates to:
  /// **'Order Date'**
  String get orderDate;

  /// No description provided for @orderStatus.
  ///
  /// In en, this message translates to:
  /// **'Order Status'**
  String get orderStatus;

  /// No description provided for @orderTotal.
  ///
  /// In en, this message translates to:
  /// **'Order Total'**
  String get orderTotal;

  /// No description provided for @orderItems.
  ///
  /// In en, this message translates to:
  /// **'Order Items'**
  String get orderItems;

  /// No description provided for @noOrders.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get noOrders;

  /// No description provided for @noActiveOrders.
  ///
  /// In en, this message translates to:
  /// **'No active orders'**
  String get noActiveOrders;

  /// No description provided for @noCompletedOrders.
  ///
  /// In en, this message translates to:
  /// **'No completed orders'**
  String get noCompletedOrders;

  /// No description provided for @noCancelledOrders.
  ///
  /// In en, this message translates to:
  /// **'No cancelled orders'**
  String get noCancelledOrders;

  /// No description provided for @noItems.
  ///
  /// In en, this message translates to:
  /// **'No items'**
  String get noItems;

  /// No description provided for @trackYourOrders.
  ///
  /// In en, this message translates to:
  /// **'Track your orders'**
  String get trackYourOrders;

  /// No description provided for @trackOrder.
  ///
  /// In en, this message translates to:
  /// **'Track Order'**
  String get trackOrder;

  /// No description provided for @cancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Cancel Order'**
  String get cancelOrder;

  /// No description provided for @cancelOrderConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this order?'**
  String get cancelOrderConfirmation;

  /// No description provided for @cancellationReason.
  ///
  /// In en, this message translates to:
  /// **'Cancellation reason'**
  String get cancellationReason;

  /// No description provided for @cancellationReasonTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancellation Reason'**
  String get cancellationReasonTitle;

  /// No description provided for @confirmCancel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Cancel'**
  String get confirmCancel;

  /// No description provided for @orderCancelled.
  ///
  /// In en, this message translates to:
  /// **'Order cancelled'**
  String get orderCancelled;

  /// No description provided for @cancelledByUser.
  ///
  /// In en, this message translates to:
  /// **'Cancelled by user'**
  String get cancelledByUser;

  /// No description provided for @reorder.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get reorder;

  /// No description provided for @reorderPrevious.
  ///
  /// In en, this message translates to:
  /// **'Order Again'**
  String get reorderPrevious;

  /// No description provided for @orderReordered.
  ///
  /// In en, this message translates to:
  /// **'New order created'**
  String get orderReordered;

  /// No description provided for @currentStatus.
  ///
  /// In en, this message translates to:
  /// **'Current Status'**
  String get currentStatus;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @noOrderHistory.
  ///
  /// In en, this message translates to:
  /// **'No order history'**
  String get noOrderHistory;

  /// No description provided for @orderNotFound.
  ///
  /// In en, this message translates to:
  /// **'Order not found'**
  String get orderNotFound;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @statusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get statusDraft;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusPlaced.
  ///
  /// In en, this message translates to:
  /// **'Placed'**
  String get statusPlaced;

  /// No description provided for @statusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get statusAccepted;

  /// No description provided for @statusPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get statusPreparing;

  /// No description provided for @statusReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get statusReady;

  /// No description provided for @statusPicked.
  ///
  /// In en, this message translates to:
  /// **'On The Way'**
  String get statusPicked;

  /// No description provided for @statusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get statusDelivered;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @orderCreated.
  ///
  /// In en, this message translates to:
  /// **'Order Created'**
  String get orderCreated;

  /// No description provided for @orderAssigned.
  ///
  /// In en, this message translates to:
  /// **'Assigned to Hero'**
  String get orderAssigned;

  /// No description provided for @driverOnWay.
  ///
  /// In en, this message translates to:
  /// **'Hero On the Way'**
  String get driverOnWay;

  /// No description provided for @orderDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get orderDelivered;

  /// No description provided for @invoicesUploaded.
  ///
  /// In en, this message translates to:
  /// **'Invoices Uploaded'**
  String get invoicesUploaded;

  /// No description provided for @orderClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get orderClosed;

  /// No description provided for @orderSubmittedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Order submitted successfully'**
  String get orderSubmittedSuccess;

  /// No description provided for @driver.
  ///
  /// In en, this message translates to:
  /// **'Hero'**
  String get driver;

  /// No description provided for @driverInfo.
  ///
  /// In en, this message translates to:
  /// **'Hero Info'**
  String get driverInfo;

  /// No description provided for @driverName.
  ///
  /// In en, this message translates to:
  /// **'Hero Name'**
  String get driverName;

  /// No description provided for @driverPhone.
  ///
  /// In en, this message translates to:
  /// **'Hero Phone'**
  String get driverPhone;

  /// No description provided for @contactDriver.
  ///
  /// In en, this message translates to:
  /// **'Contact Hero'**
  String get contactDriver;

  /// No description provided for @callDriver.
  ///
  /// In en, this message translates to:
  /// **'Call Hero'**
  String get callDriver;

  /// No description provided for @reviewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviewsTitle;

  /// No description provided for @writeReview.
  ///
  /// In en, this message translates to:
  /// **'Write Review'**
  String get writeReview;

  /// No description provided for @rateDriver.
  ///
  /// In en, this message translates to:
  /// **'Rate Hero'**
  String get rateDriver;

  /// No description provided for @rateRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Rate Restaurant'**
  String get rateRestaurant;

  /// No description provided for @rateYourExperience.
  ///
  /// In en, this message translates to:
  /// **'Rate your experience with the hero'**
  String get rateYourExperience;

  /// No description provided for @overallRating.
  ///
  /// In en, this message translates to:
  /// **'Overall Rating'**
  String get overallRating;

  /// No description provided for @deliverySpeed.
  ///
  /// In en, this message translates to:
  /// **'Delivery Speed'**
  String get deliverySpeed;

  /// No description provided for @professionalism.
  ///
  /// In en, this message translates to:
  /// **'Professionalism'**
  String get professionalism;

  /// No description provided for @addComment.
  ///
  /// In en, this message translates to:
  /// **'Add comment'**
  String get addComment;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'(Optional)'**
  String get optional;

  /// No description provided for @shareYourThoughts.
  ///
  /// In en, this message translates to:
  /// **'Share your thoughts...'**
  String get shareYourThoughts;

  /// No description provided for @addTip.
  ///
  /// In en, this message translates to:
  /// **'Add tip for hero'**
  String get addTip;

  /// No description provided for @tipAmount.
  ///
  /// In en, this message translates to:
  /// **'Tip Amount'**
  String get tipAmount;

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get submitReview;

  /// No description provided for @reviewSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your review!'**
  String get reviewSubmitted;

  /// No description provided for @thankYouForReview.
  ///
  /// In en, this message translates to:
  /// **'Your review helps us improve'**
  String get thankYouForReview;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @rate.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get rate;

  /// No description provided for @veryPoor.
  ///
  /// In en, this message translates to:
  /// **'Very Poor'**
  String get veryPoor;

  /// No description provided for @poor.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get poor;

  /// No description provided for @average.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get average;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// No description provided for @excellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get excellent;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsAndConditions;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout from your account?'**
  String get logoutConfirmation;

  /// No description provided for @manageYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Manage your account'**
  String get manageYourAccount;

  /// No description provided for @defaultUserName.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get defaultUserName;

  /// No description provided for @defaultUserInitial.
  ///
  /// In en, this message translates to:
  /// **'U'**
  String get defaultUserInitial;

  /// No description provided for @accountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountSection;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// No description provided for @addresses.
  ///
  /// In en, this message translates to:
  /// **'Addresses'**
  String get addresses;

  /// No description provided for @preferencesSection.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferencesSection;

  /// No description provided for @currentLanguage.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get currentLanguage;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @supportSection.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get supportSection;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @enterFirstName.
  ///
  /// In en, this message translates to:
  /// **'Enter first name'**
  String get enterFirstName;

  /// No description provided for @enterLastName.
  ///
  /// In en, this message translates to:
  /// **'Enter last name'**
  String get enterLastName;

  /// No description provided for @phoneNumberCannotBeChanged.
  ///
  /// In en, this message translates to:
  /// **'Phone number cannot be changed'**
  String get phoneNumberCannotBeChanged;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordTitle;

  /// No description provided for @useStrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Make sure to use a strong password'**
  String get useStrongPassword;

  /// No description provided for @enterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter current password'**
  String get enterCurrentPassword;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get enterNewPassword;

  /// No description provided for @reEnterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Re-enter new password'**
  String get reEnterNewPassword;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangedSuccessfully;

  /// No description provided for @homeTab.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTab;

  /// No description provided for @ordersTab.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get ordersTab;

  /// No description provided for @cartTab.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cartTab;

  /// No description provided for @chatTab.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatTab;

  /// No description provided for @supportTab.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get supportTab;

  /// No description provided for @profileTab.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTab;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @newOrder.
  ///
  /// In en, this message translates to:
  /// **'New Order'**
  String get newOrder;

  /// No description provided for @liveChat.
  ///
  /// In en, this message translates to:
  /// **'Live Chat'**
  String get liveChat;

  /// No description provided for @chatWithSupport.
  ///
  /// In en, this message translates to:
  /// **'Chat with support team'**
  String get chatWithSupport;

  /// No description provided for @supportTickets.
  ///
  /// In en, this message translates to:
  /// **'Support Tickets'**
  String get supportTickets;

  /// No description provided for @reportIssues.
  ///
  /// In en, this message translates to:
  /// **'Report technical issues'**
  String get reportIssues;

  /// No description provided for @chatSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Support Team'**
  String get chatSupportTitle;

  /// No description provided for @chatOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get chatOnline;

  /// No description provided for @chatHint.
  ///
  /// In en, this message translates to:
  /// **'Type your message...'**
  String get chatHint;

  /// No description provided for @chatCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get chatCamera;

  /// No description provided for @chatGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get chatGallery;

  /// No description provided for @chatToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get chatToday;

  /// No description provided for @chatYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get chatYesterday;

  /// No description provided for @chatEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Start a new conversation'**
  String get chatEmptyTitle;

  /// No description provided for @chatEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send us a message and we\'ll reply as soon as possible. You can also create a custom order or ask about anything.'**
  String get chatEmptySubtitle;

  /// No description provided for @chatLoginRequired.
  ///
  /// In en, this message translates to:
  /// **'Login to chat'**
  String get chatLoginRequired;

  /// No description provided for @chatLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You need to login to contact the support team'**
  String get chatLoginSubtitle;

  /// No description provided for @chatSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get chatSend;

  /// No description provided for @chatImageSendError.
  ///
  /// In en, this message translates to:
  /// **'Failed to send image'**
  String get chatImageSendError;

  /// No description provided for @chatMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get chatMessage;

  /// No description provided for @chatMessageRequired.
  ///
  /// In en, this message translates to:
  /// **'Message cannot be empty'**
  String get chatMessageRequired;

  /// No description provided for @chatMessageTooLong.
  ///
  /// In en, this message translates to:
  /// **'Message is too long'**
  String get chatMessageTooLong;

  /// No description provided for @orderDescription.
  ///
  /// In en, this message translates to:
  /// **'Order Description'**
  String get orderDescription;

  /// No description provided for @orderDescriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Order description is required'**
  String get orderDescriptionRequired;

  /// No description provided for @orderDescriptionTooShort.
  ///
  /// In en, this message translates to:
  /// **'Please write a more detailed description (at least 10 characters)'**
  String get orderDescriptionTooShort;

  /// No description provided for @orderDescriptionTooLong.
  ///
  /// In en, this message translates to:
  /// **'Description is too long (maximum 500 characters)'**
  String get orderDescriptionTooLong;

  /// No description provided for @notesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (Optional)'**
  String get notesOptional;

  /// No description provided for @notesTooLong.
  ///
  /// In en, this message translates to:
  /// **'Notes are too long (maximum 500 characters)'**
  String get notesTooLong;

  /// No description provided for @ticketTitle.
  ///
  /// In en, this message translates to:
  /// **'Ticket Title'**
  String get ticketTitle;

  /// No description provided for @ticketTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Ticket title is required'**
  String get ticketTitleRequired;

  /// No description provided for @ticketTitleTooShort.
  ///
  /// In en, this message translates to:
  /// **'Title is too short'**
  String get ticketTitleTooShort;

  /// No description provided for @ticketTitleTooLong.
  ///
  /// In en, this message translates to:
  /// **'Title is too long'**
  String get ticketTitleTooLong;

  /// No description provided for @ticketDescription.
  ///
  /// In en, this message translates to:
  /// **'Problem Description'**
  String get ticketDescription;

  /// No description provided for @ticketDescriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Problem description is required'**
  String get ticketDescriptionRequired;

  /// No description provided for @ticketDescriptionTooShort.
  ///
  /// In en, this message translates to:
  /// **'Please write a more detailed description (at least 20 characters)'**
  String get ticketDescriptionTooShort;

  /// No description provided for @ticketDescriptionTooLong.
  ///
  /// In en, this message translates to:
  /// **'Description is too long (maximum 1000 characters)'**
  String get ticketDescriptionTooLong;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Support Center'**
  String get helpCenter;

  /// No description provided for @helpHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'How can we assist you?'**
  String get helpHeaderTitle;

  /// No description provided for @helpHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse common questions or contact us directly for help'**
  String get helpHeaderSubtitle;

  /// No description provided for @frequentlyAskedQuestions.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get frequentlyAskedQuestions;

  /// No description provided for @helpOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get helpOrdersTitle;

  /// No description provided for @helpQ1.
  ///
  /// In en, this message translates to:
  /// **'How can I place a new order?'**
  String get helpQ1;

  /// No description provided for @helpA1.
  ///
  /// In en, this message translates to:
  /// **'Select your favorite restaurant from the home screen, browse the menu, and add items to your cart. Once finished, tap the cart to review and complete your order.'**
  String get helpA1;

  /// No description provided for @helpQ1_1.
  ///
  /// In en, this message translates to:
  /// **'What is the \"As You Wish\" feature and how do I use it?'**
  String get helpQ1_1;

  /// No description provided for @helpA1_1.
  ///
  /// In en, this message translates to:
  /// **'The \"As You Wish\" feature lets you order any product directly through chat without browsing menus. Tap the logo icon in the center of the bottom navigation bar, then type the name of the store you want to order from, choose the product you want, or simply send a photo of your order. We\'ll confirm your request and handle it instantly, effortlessly.'**
  String get helpA1_1;

  /// No description provided for @helpQ2.
  ///
  /// In en, this message translates to:
  /// **'How do I cancel my order?'**
  String get helpQ2;

  /// No description provided for @helpA2.
  ///
  /// In en, this message translates to:
  /// **'You can cancel your order from the order details page before the restaurant starts preparing it. If preparation has already begun or you encounter an issue, contact support via chat by tapping the logo in the center of the bottom navigation bar.'**
  String get helpA2;

  /// No description provided for @helpQ3.
  ///
  /// In en, this message translates to:
  /// **'How can I track my order?'**
  String get helpQ3;

  /// No description provided for @helpA3.
  ///
  /// In en, this message translates to:
  /// **'Go to \"My Orders\" to view your current order status. You will receive notifications for every status update.'**
  String get helpA3;

  /// No description provided for @helpChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat & Support'**
  String get helpChatTitle;

  /// No description provided for @helpQ10.
  ///
  /// In en, this message translates to:
  /// **'How can I contact the support team?'**
  String get helpQ10;

  /// No description provided for @helpA10.
  ///
  /// In en, this message translates to:
  /// **'Tap the logo in the center of the bottom navigation bar to open the \"As You Wish\" screen, where you can chat directly with the support team for any inquiry or issue.'**
  String get helpA10;

  /// No description provided for @helpQ11.
  ///
  /// In en, this message translates to:
  /// **'Can I create a custom order via chat?'**
  String get helpQ11;

  /// No description provided for @helpA11.
  ///
  /// In en, this message translates to:
  /// **'Yes! If you can\'t find the product you\'re looking for in the app, you can contact us through the \"As You Wish\" feature to create a custom order. We provide a variety of food products, health and pharmaceutical supplies, household essentials, and more.'**
  String get helpA11;

  /// No description provided for @helpQ12.
  ///
  /// In en, this message translates to:
  /// **'How are prices confirmed for custom orders?'**
  String get helpQ12;

  /// No description provided for @helpA12.
  ///
  /// In en, this message translates to:
  /// **'When you place an order through the \"As You Wish\" feature, the delivery hero will provide you with the purchase receipt upon delivery. We follow this process to ensure full transparency and to give you an official reference in case you want to raise any inquiry or complaint later.'**
  String get helpA12;

  /// No description provided for @helpQ13.
  ///
  /// In en, this message translates to:
  /// **'What should I do if I have an issue with my order?'**
  String get helpQ13;

  /// No description provided for @helpA13.
  ///
  /// In en, this message translates to:
  /// **'Open the \"As You Wish\" screen by tapping the logo in the bottom navigation bar and describe the issue. Our support team will assist you promptly.'**
  String get helpA13;

  /// No description provided for @helpDeliveryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get helpDeliveryTitle;

  /// No description provided for @helpQ4.
  ///
  /// In en, this message translates to:
  /// **'Which delivery areas are covered?'**
  String get helpQ4;

  /// No description provided for @helpA4.
  ///
  /// In en, this message translates to:
  /// **'We deliver to all areas displayed in the app. Delivery fees and estimated arrival times are calculated based on the distance between you and the restaurant.'**
  String get helpA4;

  /// No description provided for @helpQ5.
  ///
  /// In en, this message translates to:
  /// **'How long does delivery usually take?'**
  String get helpQ5;

  /// No description provided for @helpA5.
  ///
  /// In en, this message translates to:
  /// **'Delivery times vary depending on the restaurant and distance. The estimated delivery time is shown on each restaurant\'s page before placing your order.'**
  String get helpA5;

  /// No description provided for @helpPaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get helpPaymentTitle;

  /// No description provided for @helpQ6.
  ///
  /// In en, this message translates to:
  /// **'What payment methods are currently available?'**
  String get helpQ6;

  /// No description provided for @helpA6.
  ///
  /// In en, this message translates to:
  /// **'We currently offer Cash on Delivery. Online payment methods will be introduced soon.'**
  String get helpA6;

  /// No description provided for @helpQ7.
  ///
  /// In en, this message translates to:
  /// **'Is there a minimum order requirement?'**
  String get helpQ7;

  /// No description provided for @helpA7.
  ///
  /// In en, this message translates to:
  /// **'Yes, each restaurant has a minimum order amount displayed on its page. Orders below this amount cannot be completed.'**
  String get helpA7;

  /// No description provided for @helpAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get helpAccountTitle;

  /// No description provided for @helpQ8.
  ///
  /// In en, this message translates to:
  /// **'How can I update my account information?'**
  String get helpQ8;

  /// No description provided for @helpA8.
  ///
  /// In en, this message translates to:
  /// **'Go to your profile page and tap \"Edit Profile\" to update your details. You can also change your password from the same section. Your phone number cannot be modified as it is linked to your account.'**
  String get helpA8;

  /// No description provided for @helpQ9.
  ///
  /// In en, this message translates to:
  /// **'How do I add or edit delivery addresses?'**
  String get helpQ9;

  /// No description provided for @helpA9.
  ///
  /// In en, this message translates to:
  /// **'From your profile page, tap \"My Addresses\" to manage your delivery locations. You can add new addresses, edit existing ones, or set a default address.'**
  String get helpA9;

  /// No description provided for @contactUsTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUsTitle;

  /// No description provided for @contactUsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Have a question or suggestion? We\'re here to help'**
  String get contactUsSubtitle;

  /// No description provided for @sendEmail.
  ///
  /// In en, this message translates to:
  /// **'Send Email'**
  String get sendEmail;

  /// No description provided for @emailCopied.
  ///
  /// In en, this message translates to:
  /// **'Email copied successfully'**
  String get emailCopied;

  /// No description provided for @whatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsapp;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @phoneCopied.
  ///
  /// In en, this message translates to:
  /// **'Phone number copied'**
  String get phoneCopied;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @noNotificationsMessage.
  ///
  /// In en, this message translates to:
  /// **'Your order updates and offers will appear here'**
  String get noNotificationsMessage;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountDescription.
  ///
  /// In en, this message translates to:
  /// **'Your account will be deactivated and all your data will be deleted. This action cannot be undone.'**
  String get deleteAccountDescription;

  /// No description provided for @deleteAccountPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get deleteAccountPasswordHint;

  /// No description provided for @deleteAccountPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get deleteAccountPasswordRequired;

  /// No description provided for @deleteAccountReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Reason for deletion (optional)'**
  String get deleteAccountReasonHint;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete Account Permanently'**
  String get deleteAccountConfirm;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
