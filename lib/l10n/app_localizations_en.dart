// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'AbdoulExpress';

  @override
  String get welcome => 'Welcome';

  @override
  String get navHome => 'Shop';

  @override
  String get navCart => 'Cart';

  @override
  String get navChat => 'Chat';

  @override
  String get navProfile => 'Profile';

  @override
  String get navCategories => 'Categories';

  @override
  String get categoriesAll => 'All';

  @override
  String get search => 'Search';

  @override
  String get searchProducts => 'Search products...';

  @override
  String get searchNoResults => 'No products found';

  @override
  String get addToCart => 'Add to cart';

  @override
  String get buyNow => 'Buy now';

  @override
  String get price => 'Price';

  @override
  String get quantity => 'Quantity';

  @override
  String get inStock => 'In stock';

  @override
  String get outOfStock => 'Out of stock';

  @override
  String get cartTitle => 'Cart';

  @override
  String get cartEmpty => 'Your cart is empty';

  @override
  String get cartEmptyMessage => 'Add some products to get started!';

  @override
  String get cartSubtotal => 'Subtotal';

  @override
  String get cartShipping => 'Shipping';

  @override
  String get cartTotal => 'Total';

  @override
  String get checkout => 'Proceed to checkout';

  @override
  String get continueShoping => 'Continue shopping';

  @override
  String get currency => 'F CFA';

  @override
  String currencyFormat(String amount) {
    return '$amount F CFA';
  }

  @override
  String get loginTitle => 'Login';

  @override
  String get loginEmail => 'Email or phone';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginButton => 'Log in';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get loginSignupPrompt => 'Don\'t have an account?';

  @override
  String get loginSignupLink => 'Sign up';

  @override
  String get signupTitle => 'Sign up';

  @override
  String get signupFirstName => 'First name';

  @override
  String get signupLastName => 'Last name';

  @override
  String get signupName => 'Full name';

  @override
  String get signupEmail => 'Email';

  @override
  String get signupPhone => 'Phone number';

  @override
  String get signupPassword => 'Password';

  @override
  String get signupConfirmPassword => 'Confirm password';

  @override
  String get signupButton => 'Create account';

  @override
  String get signupLoginPrompt => 'Already have an account?';

  @override
  String get signupLoginLink => 'Log in';

  @override
  String get otpTitle => 'Verify OTP';

  @override
  String otpMessage(String phone) {
    return 'Enter the code sent to $phone';
  }

  @override
  String get otpResend => 'Resend code';

  @override
  String get otpVerify => 'Verify';

  @override
  String get otpMessageGeneric => 'We sent a 6-digit code to your number';

  @override
  String get sendCode => 'Send code';

  @override
  String get loginWithoutAccount => 'Log in without account';

  @override
  String get emailTab => 'Email';

  @override
  String get phoneTab => 'Phone';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileOrders => 'My orders';

  @override
  String get profileAddresses => 'Addresses';

  @override
  String get profilePayments => 'Payment history';

  @override
  String get profileFavorites => 'Favorites';

  @override
  String get profileSettings => 'Settings';

  @override
  String get profileLogout => 'Logout';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageFrench => 'Français';

  @override
  String get settingsLanguageHausa => 'Hausa';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsPrivacy => 'Privacy policy';

  @override
  String get settingsTerms => 'Terms of service';

  @override
  String get ordersTitle => 'My orders';

  @override
  String get ordersEmpty => 'No orders yet';

  @override
  String get ordersEmptyMessage => 'Start shopping to see your orders here';

  @override
  String get orderDetails => 'Order details';

  @override
  String get orderStatus => 'Status';

  @override
  String get orderDate => 'Order date';

  @override
  String get orderTotal => 'Total';

  @override
  String get orderTrack => 'Track order';

  @override
  String get orderCancel => 'Cancel order';

  @override
  String get orderReorder => 'Reorder';

  @override
  String get orderStatusPending => 'Pending';

  @override
  String get orderStatusProcessing => 'Processing';

  @override
  String get orderStatusShipped => 'Shipped';

  @override
  String get orderStatusDelivered => 'Delivered';

  @override
  String get orderStatusCancelled => 'Cancelled';

  @override
  String get favoritesTitle => 'Favorites';

  @override
  String get favoritesEmpty => 'No favorites yet';

  @override
  String get favoritesEmptyMessage => 'Tap the heart icon on products you love';

  @override
  String get categoriesTitle => 'Categories';

  @override
  String get newArrivals => 'New arrivals';

  @override
  String get specialOffers => 'Special offers';

  @override
  String get recentlyViewed => 'Recently viewed';

  @override
  String get errorGeneric => 'An error occurred';

  @override
  String get errorNetwork => 'Check your internet connection';

  @override
  String get errorEmpty => 'No results found';

  @override
  String get errorLoading => 'Failed to load data';

  @override
  String get errorTryAgain => 'Try again';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionOk => 'OK';

  @override
  String get actionYes => 'Yes';

  @override
  String get actionNo => 'No';

  @override
  String get actionConfirm => 'Confirm';

  @override
  String get actionClose => 'Close';

  @override
  String get actionApply => 'Apply';

  @override
  String get actionClear => 'Clear';

  @override
  String get actionFilter => 'Filter';

  @override
  String get actionSort => 'Sort';

  @override
  String testCredentials(String email, String password, String phone) {
    return 'Test: $email / $password\nOr: $phone';
  }

  @override
  String get validationRequired => 'This field is required';

  @override
  String get validationEmail => 'Enter a valid email';

  @override
  String get validationPhone => 'Enter a valid phone number';

  @override
  String get validationPassword => 'Password must be at least 6 characters';

  @override
  String get validationPasswordMismatch => 'Passwords do not match';

  @override
  String get loading => 'Loading...';

  @override
  String get loadingProducts => 'Loading products...';

  @override
  String get loadingOrders => 'Loading orders...';

  @override
  String get processingPayment => 'Processing payment...';
}
