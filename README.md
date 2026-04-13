# AbdoulExpress - E-Commerce Mobile Application

> Une application e-commerce moderne et performante pour l'Afrique francophone, optimisée pour les connexions 2G/3G.

## 📱 Vue d'ensemble

**AbdoulExpress** est une application mobile Flutter conçue spécifiquement pour le marché africain francophone. Elle offre une expérience d'achat simple, rapide et fiable, même avec des connexions internet limitées.

### Caractéristiques principales

- 🛍️ **Catalogue produits** avec recherche et filtres par catégorie
- 🛒 **Panier intelligent** avec gestion des quantités
- 💬 **Chat en direct** avec l'équipe AbdoulExpress
- 👤 **Profil utilisateur** avec historique et paramètres
- 🎯 **Promotions** affichées en carousel
- 📱 **Offline-first** - Fonctionne avec connexion limitée
- 🎨 **Design moderne** adapté au contexte africain

## 🏗️ Architecture

L'application suit les principes de **Clean Architecture** avec le pattern **BLoC** pour la gestion d'état.

### Structure du projet

```
lib/
├── core/                          # Fonctionnalités partagées
│   ├── constants/                 # Constantes (couleurs, etc.)
│   ├── theme/                     # Thème de l'application
│   ├── utils/                     # Utilitaires (offline queue, etc.)
│   ├── widgets/                   # Widgets réutilisables
│   ├── app_state.dart            # État global de l'app
│   ├── data.dart                 # Données mock
│   └── widgets.dart              # Export des widgets
│
├── features/                      # Fonctionnalités par domaine
│   ├── home/                     # Page d'accueil
│   │   └── presentation/
│   │       └── pages/
│   │           └── home_page.dart
│   │
│   ├── products/                 # Gestion des produits
│   │   ├── data/
│   │   │   └── product_repository.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── products_cubit.dart
│   │       │   └── products_state.dart
│   │       └── pages/
│   │           └── product_detail_page.dart
│   │
│   ├── cart/                     # Panier et paiement
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   ├── cart_cubit.dart
│   │       │   └── cart_state.dart
│   │       └── pages/
│   │           ├── cart_page.dart
│   │           └── checkout_page.dart
│   │
│   ├── chat/                     # Chat avec l'équipe
│   │   └── presentation/
│   │       └── pages/
│   │           └── chat_page.dart
│   │
│   └── profile/                  # Profil utilisateur
│       └── presentation/
│           └── pages/
│               └── profile_page.dart
│
├── model/                        # Modèles de données
│   └── product.dart
│
└── main.dart                     # Point d'entrée
```

## 🎨 Design System

### Palette de couleurs

L'application utilise un thème adapté au marché africain avec des couleurs vives et modernes :

- **Primary**: Bleu (#2196F3) - Confiance et professionnalisme
- **Secondary**: Orange - Énergie et dynamisme
- **Accent**: Vert - Succès et validation

### Composants UI

#### Widgets réutilisables (`core/widgets.dart`)

- **ProductCard** - Carte produit avec image, prix, favoris
- **PrimaryButton** - Bouton principal avec icône
- **QuantityStepper** - Sélecteur de quantité (+/-)
- **ProductImage** - Gestion intelligente des images (cache, fallback)

## 🚀 Fonctionnalités détaillées

### 1. Page d'accueil (Home)

**Localisation**: `lib/features/home/presentation/pages/home_page.dart`

#### Composants

- **AppBar dynamique**
  - Logo "AbdoulExpress" (disparaît au scroll)
  - Barre de recherche centrale (reste visible)
  - Icône de notifications avec badge
  - Comportement collapsible avec `SliverAppBar`

- **Carousel de promotions**
  - Affichage des deals avec pourcentages
  - Swipe horizontal
  - Disparaît au scroll

- **Filtres par catégorie**
  - Chips horizontaux scrollables
  - Filtre "Tous" + catégories dynamiques

- **Grille de produits**
  - 2 colonnes
  - Animation Hero pour les transitions
  - Bouton favoris et ajout au panier

### 2. Détails produit

**Localisation**: `lib/features/products/presentation/pages/product_detail_page.dart`

#### Fonctionnalités

- Image en plein écran avec Hero animation
- Titre, catégorie, note et description
- Sélecteur de quantité
- Bouton favoris dans l'AppBar
- **Barre d'action inférieure** avec 2 boutons :
  - "Panier" (outlined) - Ajoute au panier
  - "Acheter maintenant" (filled) - Ajoute et va au checkout

### 3. Panier

**Localisation**: `lib/features/cart/presentation/pages/cart_page.dart`

#### Gestion d'état (BLoC)

**CartCubit** (`lib/features/cart/presentation/cubit/cart_cubit.dart`)

```dart
// Actions disponibles
addToCart(CartItem item)      // Ajouter un produit
removeFromCart(String id)     // Retirer un produit
setQuantity(String id, int q) // Modifier la quantité
clearCart()                   // Vider le panier
```

#### Interface

- Liste des articles avec image, titre, prix
- Sélecteur de quantité par article
- Bouton de suppression
- Résumé (sous-total, livraison, total)
- Bouton "Passer au paiement"

### 4. Checkout

**Localisation**: `lib/features/cart/presentation/pages/checkout_page.dart`

#### Formulaire

- Nom complet (requis)
- Adresse (requis)
- Téléphone (validation 8+ caractères)
- Résumé du total
- Modal de confirmation après validation

### 5. Chat

**Localisation**: `lib/features/chat/presentation/pages/chat_page.dart`

#### Fonctionnalités

- Interface style WhatsApp
- Messages avec timestamp
- Bulles différenciées (utilisateur vs équipe)
- Auto-réponse simulée (1 seconde de délai)
- Champ de saisie avec bouton d'envoi

### 6. Profil

**Localisation**: `lib/features/profile/presentation/pages/profile_page.dart`

#### Sections

- En-tête avec avatar et message de bienvenue
- Historique de commandes
- Adresses enregistrées
- Paramètres
- Aide

## 🔧 État global

### AppState

**Localisation**: `lib/core/app_state.dart`

Gère l'état global de l'application via `InheritedWidget` :

```dart
// Favoris
toggleFavorite(Product product)
isFavorite(String productId)

// Calculs panier
double get subtotal
double get shipping
double get total
```

## 📦 Dépendances principales

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.3          # Gestion d'état
  equatable: ^2.0.5             # Comparaison d'objets
  cached_network_image: ^3.3.0  # Cache d'images
```

## 🎯 Navigation

### Bottom Navigation Bar

4 destinations principales :

1. **Shop** (Home) - Catalogue produits
2. **Panier** - Panier avec badge dynamique (nombre d'articles)
3. **Chat** - Communication avec l'équipe
4. **Profil** - Compte utilisateur

**Badge du panier** : Affiche le nombre d'articles via `BlocBuilder<CartCubit, CartState>`

## 🌐 Optimisations réseau

### Offline-first

- **ProductImage** : Cache automatique des images
- **OfflineActionQueue** : File d'attente pour actions hors ligne
- Gestion gracieuse des erreurs réseau

### Performance

- Images optimisées avec `cached_network_image`
- Lazy loading des listes
- Animations légères (Hero, Fade)

## 🎨 Thème

**Localisation**: `lib/core/theme.dart`

### Modes

- **Light mode** : Thème clair par défaut
- **Dark mode** : Disponible (suit les préférences système)

### Personnalisation

```dart
ThemeData lightTheme
ThemeData darkTheme
```

## 🧪 Tests

### Structure

```
test/
├── unit/              # Tests unitaires (Cubits, Repositories)
├── widget/            # Tests de widgets
└── integration/       # Tests d'intégration
```

### Commandes

```bash
# Tous les tests
flutter test

# Tests avec coverage
flutter test --coverage

# Tests spécifiques
flutter test test/unit/cart_cubit_test.dart
```

## 🚀 Lancement

### Prérequis

- Flutter SDK ≥ 3.0.0
- Dart SDK ≥ 3.0.0

### Installation

```bash
# Cloner le projet
git clone <repository-url>
cd abdoul_express

# Installer les dépendances
flutter pub get

# Lancer l'app
flutter run
```

### Build

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## 📝 Conventions de code

### Nommage

- **Fichiers** : `snake_case.dart`
- **Classes** : `PascalCase`
- **Variables/Fonctions** : `camelCase`
- **Constantes** : `SCREAMING_SNAKE_CASE`

### Organisation

- Widgets privés : Préfixe `_` (ex: `_CategoryChips`)
- Imports : Groupés (Flutter, packages, relatifs)
- Commentaires : Français pour la logique métier

## 🌍 Internationalisation

**Langue actuelle** : Français

Tous les textes UI sont en français pour le marché cible (Afrique francophone).

## 📱 Compatibilité

- **Android** : API 21+ (Android 5.0+)
- **iOS** : iOS 11.0+
- **Appareils** : Optimisé pour low-end à high-end

## 🔐 Sécurité

- Validation des entrées utilisateur
- Gestion sécurisée des états
- Pas de données sensibles en clair

## 📄 License

[À définir]

## 👥 Contribution

[Guidelines de contribution à définir]

## 📞 Support

Pour toute question, contactez l'équipe AbdoulExpress via le chat intégré dans l'application.

---

**Version**: 1.0.0  
**Dernière mise à jour**: Décembre 2025
