# AbdoulExpress - Screen Improvements & Localization Plan

**Created:** 2025-12-13
**Status:** Planning Phase
**Supported Languages:**
- French (Français) - Primary
- English (English) - Primary
- Hausa (Hausa) - Secondary

---

## 1. SCREENS TO IMPROVE (Priority Order)

### 🔴 Critical Improvements (Week 1)

#### 1.1 Home Page ([lib/features/home/presentation/pages/home_page.dart](lib/features/home/presentation/pages/home_page.dart))
**Current Issues:**
- Hardcoded French strings ("Tous", "Erreur")
- Limited search functionality visibility
- No empty state messaging
- Category filtering needs UX improvement

**Improvements Needed:**
- [ ] Replace all hardcoded strings with l10n keys
- [ ] Add prominent search bar at top
- [ ] Add banner/carousel for promotions
- [ ] Improve category chip design with icons
- [ ] Add pull-to-refresh functionality
- [ ] Better loading states with shimmer effects
- [ ] Empty state with helpful messaging

#### 1.2 Cart Page ([lib/features/cart/presentation/pages/cart_page.dart](lib/features/cart/presentation/pages/cart_page.dart))
**Current Issues:**
- Hardcoded strings ("Panier", "F CFA")
- Fixed shipping calculation (1000 F CFA)
- Limited quantity controls

**Improvements Needed:**
- [ ] Full l10n support for all text
- [ ] Currency formatting based on locale
- [ ] Enhanced quantity controls (+ / - buttons)
- [ ] Swipe-to-delete cart items
- [ ] Show savings/discounts prominently
- [ ] Add cart summary breakdown
- [ ] "Save for later" functionality
- [ ] Estimated delivery time display

#### 1.3 Product Detail Page ([lib/features/products/presentation/pages/product_detail_page.dart](lib/features/products/presentation/pages/product_detail_page.dart))
**Improvements Needed:**
- [ ] Full l10n implementation
- [ ] Image gallery with zoom capability
- [ ] Product specifications section
- [ ] Related products carousel
- [ ] Stock availability indicator
- [ ] Size/variant selection (if applicable)
- [ ] Share product functionality
- [ ] Customer reviews section (future)

#### 1.4 Checkout Page ([lib/features/cart/presentation/pages/checkout_page.dart](lib/features/cart/presentation/pages/checkout_page.dart))
**Improvements Needed:**
- [ ] Localize all form labels and validation messages
- [ ] Step indicator (1. Address → 2. Payment → 3. Confirm)
- [ ] Delivery time slot selection
- [ ] Order notes/special instructions field
- [ ] Promo code/coupon input
- [ ] Save address for future use
- [ ] Payment method preview

#### 1.5 Profile Page ([lib/features/profile/presentation/pages/profile_page.dart](lib/features/profile/presentation/pages/profile_page.dart))
**Current Issues:**
- Mock user data hardcoded
- Static French strings

**Improvements Needed:**
- [ ] Full l10n support
- [ ] **Language selector (French/Hausa)**
- [ ] Edit profile capability
- [ ] Profile photo upload
- [ ] Notification preferences
- [ ] App version and terms/privacy links
- [ ] Logout confirmation dialog

---

### 🟡 Important Improvements (Week 2)

#### 2.1 Order History Page ([lib/features/orders/presentation/pages/order_history_page.dart](lib/features/orders/presentation/pages/order_history_page.dart))
**Improvements Needed:**
- [ ] Localize order statuses
- [ ] Filter by status (pending, delivered, cancelled)
- [ ] Search orders by product or order ID
- [ ] Pull-to-refresh
- [ ] Empty state when no orders
- [ ] Order status badges with colors

#### 2.2 Order Detail Page ([lib/features/orders/presentation/pages/order_detail_page.dart](lib/features/orders/presentation/pages/order_detail_page.dart))
**Improvements Needed:**
- [ ] Full l10n support
- [ ] Timeline view of order status
- [ ] Download/share invoice
- [ ] Contact support button
- [ ] Reorder functionality
- [ ] Delivery tracking integration

#### 2.3 Authentication Pages
**Files:**
- [lib/features/auth/presentation/pages/login_page.dart](lib/features/auth/presentation/pages/login_page.dart)
- [lib/features/auth/presentation/pages/signup_page.dart](lib/features/auth/presentation/pages/signup_page.dart)
- [lib/features/auth/presentation/pages/otp_page.dart](lib/features/auth/presentation/pages/otp_page.dart)

**Improvements Needed:**
- [ ] Complete l10n for all auth flows
- [ ] Phone number validation with Niger format (+227)
- [ ] Password strength indicator
- [ ] Social login options (Google, Facebook)
- [ ] Forgot password flow
- [ ] OTP resend with countdown timer
- [ ] Terms & privacy policy checkboxes

---

### 🟢 Nice-to-Have Improvements (Week 3)

#### 3.1 Search Results Page ([lib/features/search/presentation/pages/search_results_page.dart](lib/features/search/presentation/pages/search_results_page.dart))
**Improvements Needed:**
- [ ] Localization support
- [ ] Search suggestions/autocomplete
- [ ] Recent searches
- [ ] Filters (price, category, rating)
- [ ] Sort options (price, popularity, newest)
- [ ] Voice search (future)

#### 3.2 Favorites Page ([lib/features/favorites/presentation/pages/favorites_page.dart](lib/features/favorites/presentation/pages/favorites_page.dart))
**Improvements Needed:**
- [ ] Full l10n
- [ ] Bulk add to cart
- [ ] Share favorites list
- [ ] Empty state with suggestions
- [ ] Price drop notifications

#### 3.3 Payment Pages
**Files:**
- [lib/features/payment/presentation/pages/payment_method_selection_page.dart](lib/features/payment/presentation/pages/payment_method_selection_page.dart)
- [lib/features/payment/presentation/pages/receipt_upload_page.dart](lib/features/payment/presentation/pages/receipt_upload_page.dart)
- [lib/features/payment/presentation/pages/payment_history_page.dart](lib/features/payment/presentation/pages/payment_history_page.dart)

**Improvements Needed:**
- [ ] Localize payment methods and instructions
- [ ] Popular payment methods highlighted
- [ ] Receipt camera with crop/rotate
- [ ] Payment status filters
- [ ] Export payment history

---

## 2. NEW SCREENS TO CREATE

### 🔴 Critical New Screens (Week 2-3)

#### 2.1 Settings Page **NEW**
**File:** `lib/features/settings/presentation/pages/settings_page.dart`

**Features:**
- [ ] Language selection (French/Hausa) with visual flags
- [ ] Notification preferences
- [ ] Currency preference
- [ ] App theme (future: dark mode)
- [ ] About app (version, licenses)
- [ ] Terms & conditions
- [ ] Privacy policy
- [ ] Help & support
- [ ] Logout option

#### 2.2 Notifications Page **NEW**
**File:** `lib/features/notifications/presentation/pages/notifications_page.dart`

**Features:**
- [ ] List of all notifications
- [ ] Mark as read/unread
- [ ] Clear all notifications
- [ ] Notification categories (orders, promotions, updates)
- [ ] Empty state when no notifications
- [ ] Deep links to related pages (order detail, product, etc.)

#### 2.3 Help & Support Page **NEW**
**File:** `lib/features/support/presentation/pages/help_support_page.dart`

**Features:**
- [ ] FAQ accordion (localized)
- [ ] Contact support form
- [ ] WhatsApp direct contact
- [ ] Phone support
- [ ] Email support
- [ ] Common issues solutions

### 🟡 Important New Screens (Week 3-4)

#### 2.4 Product Reviews Page **NEW**
**File:** `lib/features/reviews/presentation/pages/product_reviews_page.dart`

**Features:**
- [ ] View all reviews for a product
- [ ] Write a review (text + rating)
- [ ] Upload review photos
- [ ] Filter by rating
- [ ] Helpful/unhelpful vote
- [ ] Report inappropriate reviews

#### 2.5 Wishlist/Favorites Management **NEW** (Enhanced)
**File:** `lib/features/favorites/presentation/pages/favorites_management_page.dart`

**Features:**
- [ ] Create multiple wishlists
- [ ] Share wishlist with friends
- [ ] Move items between lists
- [ ] Set price alerts

#### 2.6 Delivery Tracking Page (Enhanced) **NEW**
**File:** `lib/features/tracking/presentation/pages/live_tracking_page.dart`

**Features:**
- [ ] Real-time delivery tracking
- [ ] Map view with delivery person location
- [ ] Estimated arrival time
- [ ] Contact delivery person
- [ ] Delivery proof photo

---

## 3. LOCALIZATION (l10n) IMPLEMENTATION PLAN

### Phase 1: Infrastructure Setup (Day 1-2)

#### 3.1 Add Dependencies to `pubspec.yaml`
```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0

flutter:
  generate: true
```

#### 3.2 Create l10n Configuration
**File:** `l10n.yaml`
```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
```
**Note:** English is used as the template file for code generation, but French and English are both primary languages for users.

#### 3.3 Create Directory Structure
```
lib/
  l10n/
    app_en.arb          # English (template - base for code generation)
    app_fr.arb          # French (primary user language)
    app_ha.arb          # Hausa (secondary)
```

### Phase 2: Primary Language Translations (Day 3-6)

#### 3.4 Core Translation Categories

**General App Strings:**
- App name, navigation, common actions
- Error messages, success messages
- Loading states, empty states

**Authentication:**
- Login, signup, OTP, password reset
- Validation messages

**Shopping:**
- Product listings, categories, filters
- Cart, checkout, payment
- Orders, tracking, delivery

**Profile & Settings:**
- User profile, addresses
- Settings, preferences
- Help & support

**Create Translation Files (~300-400 strings each):**
1. `lib/l10n/app_en.arb` (English - Template for code generation)
2. `lib/l10n/app_fr.arb` (French - Primary user language)

### Phase 3: Hausa Translations (Day 7-8) - SECONDARY LANGUAGE

#### 3.5 Translate all strings to Hausa
**Create:** `lib/l10n/app_ha.arb` (Mirror of English/French with Hausa translations)

**Priority Sections:**
1. Navigation and core UI
2. Shopping flow (browse, cart, checkout)
3. Authentication
4. Orders and tracking
5. Profile and settings

### Phase 4: Integration (Day 9-12)

#### 3.6 Update `main.dart`
```dart
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:abdoul_express/l10n/app_localizations.dart';

MaterialApp(
  localizationsDelegates: [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: [
    Locale('en'), // English
    Locale('fr', 'NE'), // French (Niger)
    Locale('ha', 'NE'), // Hausa (Niger)
  ],
  locale: _currentLocale, // From settings/preferences
  // Default to French for Niger market
  // ...
)
```

#### 3.7 Create Language Manager
**File:** `lib/core/l10n/language_manager.dart`

**Features:**
- [ ] Get current language
- [ ] Set language (persist to SharedPreferences)
- [ ] Language change notifier
- [ ] Default to French

#### 3.8 Update All Screens
- [ ] Replace all hardcoded strings with `AppLocalizations.of(context)!.stringKey`
- [ ] Test both languages on each screen
- [ ] Handle RTL if needed (not for French/Hausa, but architecture support)

---

## 4. IMPLEMENTATION PRIORITIES

### Week 1: Critical Improvements + l10n Infrastructure
1. Setup l10n infrastructure
2. Create English translation file (template)
3. Create French translation file (primary user language)
4. Improve Home Page
5. Improve Cart Page
6. Improve Product Detail Page

### Week 2: Core Translations + New Critical Screens
1. Complete English and French translations for all existing screens
2. Create Hausa translations
3. Create Settings Page with language selector (English/French/Hausa)
4. Improve Checkout Page
5. Improve Profile Page

### Week 3: Authentication + Orders
1. Integrate l10n in all screens
2. Improve Authentication pages
3. Improve Order pages
4. Create Notifications Page
5. Create Help & Support Page

### Week 4: Polish + New Features
1. Testing both languages thoroughly
2. Create Product Reviews Page
3. Enhanced Delivery Tracking
4. Performance optimization
5. Final QA

---

## 5. TRANSLATION STRING EXAMPLES

### Sample `app_en.arb` Structure (Template):
```json
{
  "@@locale": "en",

  "appName": "AbdoulExpress",
  "welcome": "Welcome",

  "navHome": "Home",
  "navCategories": "Categories",
  "navCart": "Cart",
  "navProfile": "Profile",

  "categoriesAll": "All",
  "search": "Search",
  "searchProducts": "Search products...",

  "addToCart": "Add to cart",
  "buyNow": "Buy now",
  "price": "Price",
  "quantity": "Quantity",

  "cartTitle": "Cart",
  "cartEmpty": "Your cart is empty",
  "cartSubtotal": "Subtotal",
  "cartShipping": "Shipping",
  "cartTotal": "Total",
  "checkout": "Checkout",

  "currency": "F CFA",
  "currencyFormat": "{amount} F CFA",
  "@currencyFormat": {
    "placeholders": {
      "amount": {"type": "String"}
    }
  },

  "loginTitle": "Login",
  "loginEmail": "Email or phone",
  "loginPassword": "Password",
  "loginButton": "Log in",
  "loginForgotPassword": "Forgot password?",
  "loginSignupPrompt": "Don't have an account?",
  "loginSignupLink": "Sign up",

  "settingsLanguage": "Language",
  "settingsLanguageEnglish": "English",
  "settingsLanguageFrench": "French",
  "settingsLanguageHausa": "Hausa",

  "errorGeneric": "An error occurred",
  "errorNetwork": "Check your internet connection",
  "errorEmpty": "No results found",

  "actionSave": "Save",
  "actionCancel": "Cancel",
  "actionDelete": "Delete",
  "actionEdit": "Edit",
  "actionOk": "OK"
}
```

### Sample `app_fr.arb` Structure:
```json
{
  "@@locale": "fr",

  "appName": "AbdoulExpress",
  "welcome": "Bienvenue",

  "navHome": "Accueil",
  "navCategories": "Catégories",
  "navCart": "Panier",
  "navProfile": "Profil",

  "categoriesAll": "Tous",
  "search": "Rechercher",
  "searchProducts": "Rechercher des produits...",

  "addToCart": "Ajouter au panier",
  "buyNow": "Acheter maintenant",
  "price": "Prix",
  "quantity": "Quantité",

  "cartTitle": "Panier",
  "cartEmpty": "Votre panier est vide",
  "cartSubtotal": "Sous-total",
  "cartShipping": "Livraison",
  "cartTotal": "Total",
  "checkout": "Commander",

  "currency": "F CFA",
  "currencyFormat": "{amount} F CFA",
  "@currencyFormat": {
    "placeholders": {
      "amount": {"type": "String"}
    }
  },

  "loginTitle": "Connexion",
  "loginEmail": "Email ou téléphone",
  "loginPassword": "Mot de passe",
  "loginButton": "Se connecter",
  "loginForgotPassword": "Mot de passe oublié?",
  "loginSignupPrompt": "Pas encore de compte?",
  "loginSignupLink": "S'inscrire",

  "settingsLanguage": "Langue",
  "settingsLanguageEnglish": "Anglais",
  "settingsLanguageFrench": "Français",
  "settingsLanguageHausa": "Hausa",

  "errorGeneric": "Une erreur s'est produite",
  "errorNetwork": "Vérifiez votre connexion Internet",
  "errorEmpty": "Aucun résultat trouvé",

  "actionSave": "Enregistrer",
  "actionCancel": "Annuler",
  "actionDelete": "Supprimer",
  "actionEdit": "Modifier",
  "actionOk": "OK"
}
```

### Sample `app_ha.arb` Structure:
```json
{
  "@@locale": "ha",

  "appName": "AbdoulExpress",
  "welcome": "Barka da zuwa",

  "navHome": "Gida",
  "navCategories": "Nau'o'i",
  "navCart": "Katin sayayya",
  "navProfile": "Bayani",

  "categoriesAll": "Duka",
  "search": "Nema",
  "searchProducts": "Nemo kayayyaki...",

  "addToCart": "Saka a katin sayayya",
  "buyNow": "Sayi yanzu",
  "price": "Farashi",
  "quantity": "Adadi",

  "cartTitle": "Katin Sayayya",
  "cartEmpty": "Katin sayayya babu kowa",
  "cartSubtotal": "Jimlar farashi",
  "cartShipping": "Isar da kaya",
  "cartTotal": "Jimlar",
  "checkout": "Biya kudi",

  "currency": "F CFA",
  "currencyFormat": "{amount} F CFA",
  "@currencyFormat": {
    "placeholders": {
      "amount": {"type": "String"}
    }
  },

  "loginTitle": "Shiga",
  "loginEmail": "Imel ko waya",
  "loginPassword": "Kalmar sirri",
  "loginButton": "Shiga",
  "loginForgotPassword": "Ka manta kalmar sirri?",
  "loginSignupPrompt": "Ba ka da asusu?",
  "loginSignupLink": "Yi rajista",

  "settingsLanguage": "Harshe",
  "settingsLanguageEnglish": "Turanci",
  "settingsLanguageFrench": "Faransanci",
  "settingsLanguageHausa": "Hausa",

  "errorGeneric": "An sami kuskure",
  "errorNetwork": "Duba haɗin yanar gizo",
  "errorEmpty": "Babu sakamako",

  "actionSave": "Ajiye",
  "actionCancel": "Soke",
  "actionDelete": "Share",
  "actionEdit": "Gyara",
  "actionOk": "To"
}
```

---

## 6. TESTING CHECKLIST

### Language Testing
- [ ] All screens display correctly in English
- [ ] All screens display correctly in French
- [ ] All screens display correctly in Hausa
- [ ] Language can be changed in Settings
- [ ] Language preference persists after app restart
- [ ] Default language is French for Niger market
- [ ] Currency formatting works for all languages (F CFA)
- [ ] Date/time formatting appropriate for locale
- [ ] Number formatting (thousands separator)

### Screen Testing
- [ ] All improved screens tested on small phones (360px)
- [ ] All improved screens tested on tablets (600px+)
- [ ] Empty states display correctly
- [ ] Loading states with shimmer
- [ ] Error states with retry options
- [ ] Offline behavior graceful

### Flow Testing
- [ ] Complete shopping flow (browse → cart → checkout → order)
- [ ] Authentication flow (signup → OTP → login)
- [ ] Profile management (edit, addresses, orders)
- [ ] Payment flow with receipt upload

---

## 7. DELIVERABLES

1. **Updated Screens:** All existing screens with l10n support
2. **New Screens:** Settings, Notifications, Help & Support, Reviews
3. **Translation Files:** Complete English, French, and Hausa .arb files
4. **Language Manager:** Core service for language switching between 3 languages
5. **Documentation:** This plan + implementation notes
6. **Testing:** QA checklist completed for all three languages

---

## Notes

- **Niger Context:** Primary users speak French (official) and Hausa (widely spoken)
- **Language Priority:**
  - **English:** International/template language for code generation
  - **French:** Primary user language (default for Niger market)
  - **Hausa:** Secondary user language (widely spoken in Niger)
- **Currency:** West African CFA franc (F CFA, XOF)
- **Phone Format:** +227 XX XX XX XX
- **Date Format:** DD/MM/YYYY (French standard)
- **Default Language:** French (can be changed in Settings to English or Hausa)
- **Future Languages:** Consider adding more local languages (Zarma, Fulfulde, Tamashek)

---

**End of Plan**
