// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hausa (`ha`).
class AppLocalizationsHa extends AppLocalizations {
  AppLocalizationsHa([String locale = 'ha']) : super(locale);

  @override
  String get appName => 'AbdoulExpress';

  @override
  String get welcome => 'Barka da zuwa';

  @override
  String get navHome => 'Kasuwanci';

  @override
  String get navCart => 'Katin sayayya';

  @override
  String get navChat => 'Chat';

  @override
  String get navProfile => 'Bayani';

  @override
  String get navCategories => 'Nau\'o\'i';

  @override
  String get categoriesAll => 'Duka';

  @override
  String get search => 'Nema';

  @override
  String get searchProducts => 'Nemo kayayyaki...';

  @override
  String get searchNoResults => 'Ba a sami kayayyaki ba';

  @override
  String get addToCart => 'Saka a katin sayayya';

  @override
  String get buyNow => 'Sayi yanzu';

  @override
  String get price => 'Farashi';

  @override
  String get quantity => 'Adadi';

  @override
  String get inStock => 'Akwai';

  @override
  String get outOfStock => 'Ba shi akwai';

  @override
  String get cartTitle => 'Katin Sayayya';

  @override
  String get cartEmpty => 'Katin sayayya babu kowa';

  @override
  String get cartEmptyMessage => 'Saka kayayyaki don farawa!';

  @override
  String get cartSubtotal => 'Jimlar farashi';

  @override
  String get cartShipping => 'Isar da kaya';

  @override
  String get cartTotal => 'Jimlar';

  @override
  String get checkout => 'Biya kudi';

  @override
  String get continueShoping => 'Ci gaba da sayayya';

  @override
  String get currency => 'F CFA';

  @override
  String currencyFormat(String amount) {
    return '$amount F CFA';
  }

  @override
  String get loginTitle => 'Shiga';

  @override
  String get loginEmail => 'Imel ko waya';

  @override
  String get loginPassword => 'Kalmar sirri';

  @override
  String get loginButton => 'Shiga';

  @override
  String get loginForgotPassword => 'Ka manta kalmar sirri?';

  @override
  String get loginSignupPrompt => 'Ba ka da asusu?';

  @override
  String get loginSignupLink => 'Yi rajista';

  @override
  String get signupTitle => 'Rajista';

  @override
  String get signupFirstName => 'Suna na farko';

  @override
  String get signupLastName => 'Sunan iyali';

  @override
  String get signupName => 'Cikakken suna';

  @override
  String get signupEmail => 'Imel';

  @override
  String get signupPhone => 'Lambar waya';

  @override
  String get signupPassword => 'Kalmar sirri';

  @override
  String get signupConfirmPassword => 'Tabbatar da kalmar sirri';

  @override
  String get signupButton => 'Ƙirƙiri asusu';

  @override
  String get signupLoginPrompt => 'Kana da asusu?';

  @override
  String get signupLoginLink => 'Shiga';

  @override
  String get otpTitle => 'Tabbatar da lambar';

  @override
  String otpMessage(String phone) {
    return 'Shigar da lambar da aka aika zuwa $phone';
  }

  @override
  String get otpResend => 'Sake aika lambar';

  @override
  String get otpVerify => 'Tabbatar';

  @override
  String get otpMessageGeneric => 'Mun aika lamba 6 zuwa wayarka';

  @override
  String get sendCode => 'Aika lambar';

  @override
  String get loginWithoutAccount => 'Shiga ba tare da asusu ba';

  @override
  String get emailTab => 'Imel';

  @override
  String get phoneTab => 'Waya';

  @override
  String get profileTitle => 'Bayani';

  @override
  String get profileOrders => 'Oda\'o\'ina';

  @override
  String get profileAddresses => 'Adireshi';

  @override
  String get profilePayments => 'Tarihin biya kuɗi';

  @override
  String get profileFavorites => 'Abubuwan da na fi so';

  @override
  String get profileSettings => 'Saitunan';

  @override
  String get profileLogout => 'Fita';

  @override
  String get settingsTitle => 'Saitunan';

  @override
  String get settingsLanguage => 'Harshe';

  @override
  String get settingsLanguageEnglish => 'Turanci';

  @override
  String get settingsLanguageFrench => 'Faransanci';

  @override
  String get settingsLanguageHausa => 'Hausa';

  @override
  String get settingsNotifications => 'Sanarwa';

  @override
  String get settingsTheme => 'Jigogi';

  @override
  String get settingsAbout => 'Game da';

  @override
  String get settingsPrivacy => 'Manufar sirri';

  @override
  String get settingsTerms => 'Sharuɗɗan sabis';

  @override
  String get ordersTitle => 'Oda\'o\'ina';

  @override
  String get ordersEmpty => 'Babu oda';

  @override
  String get ordersEmptyMessage => 'Fara sayayya don ganin oda\'o\'inka a nan';

  @override
  String get orderDetails => 'Bayanan oda';

  @override
  String get orderStatus => 'Matsayi';

  @override
  String get orderDate => 'Ranar oda';

  @override
  String get orderTotal => 'Jimlar';

  @override
  String get orderTrack => 'Bi diddigin oda';

  @override
  String get orderCancel => 'Soke oda';

  @override
  String get orderReorder => 'Sake oda';

  @override
  String get orderStatusPending => 'Ana jira';

  @override
  String get orderStatusProcessing => 'Ana aiki';

  @override
  String get orderStatusShipped => 'An aika';

  @override
  String get orderStatusDelivered => 'An kawo';

  @override
  String get orderStatusCancelled => 'An soke';

  @override
  String get favoritesTitle => 'Abubuwan da na fi so';

  @override
  String get favoritesEmpty => 'Babu abubuwan da ka fi so';

  @override
  String get favoritesEmptyMessage =>
      'Danna alamar zuciya akan kayayyakin da kake so';

  @override
  String get categoriesTitle => 'Nau\'o\'i';

  @override
  String get newArrivals => 'Sababbin kayayyaki';

  @override
  String get specialOffers => 'Tayin musamman';

  @override
  String get recentlyViewed => 'Na baya-bayan nan';

  @override
  String get errorGeneric => 'An sami kuskure';

  @override
  String get errorNetwork => 'Duba haɗin yanar gizo';

  @override
  String get errorEmpty => 'Babu sakamako';

  @override
  String get errorLoading => 'An kasa loda bayanai';

  @override
  String get errorTryAgain => 'Sake gwadawa';

  @override
  String get actionSave => 'Ajiye';

  @override
  String get actionCancel => 'Soke';

  @override
  String get actionDelete => 'Share';

  @override
  String get actionEdit => 'Gyara';

  @override
  String get actionOk => 'To';

  @override
  String get actionYes => 'Eh';

  @override
  String get actionNo => 'A\'a';

  @override
  String get actionConfirm => 'Tabbatar';

  @override
  String get actionClose => 'Rufe';

  @override
  String get actionApply => 'Yi amfani';

  @override
  String get actionClear => 'Goge';

  @override
  String get actionFilter => 'Tace';

  @override
  String get actionSort => 'Jera';

  @override
  String testCredentials(String email, String password, String phone) {
    return 'Gwada: $email / $password\nKo: $phone';
  }

  @override
  String get validationRequired => 'Ana buƙatar wannan filin';

  @override
  String get validationEmail => 'Shigar da ingantaccen imel';

  @override
  String get validationPhone => 'Shigar da ingantaccen lambar waya';

  @override
  String get validationPassword =>
      'Kalmar sirri dole ta kasance akalla haruffa 6';

  @override
  String get validationPasswordMismatch => 'Kalmomin sirri ba su dace ba';

  @override
  String get loading => 'Ana lodawa...';

  @override
  String get loadingProducts => 'Ana lodar kayayyaki...';

  @override
  String get loadingOrders => 'Ana lodar oda\'o\'i...';

  @override
  String get processingPayment => 'Ana aiwatar da biya kuɗi...';
}
