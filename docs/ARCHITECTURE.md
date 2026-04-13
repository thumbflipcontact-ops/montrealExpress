# Architecture Documentation

## Vue d'ensemble

AbdoulExpress suit une architecture **Clean Architecture** combinée avec le pattern **BLoC** (Business Logic Component) pour une séparation claire des responsabilités.

## Principes architecturaux

### 1. Séparation en couches

```
┌─────────────────────────────────────┐
│      Presentation Layer             │
│  (UI, Pages, Widgets, BLoC/Cubit)   │
├─────────────────────────────────────┤
│      Domain Layer                   │
│  (Entities, Use Cases, Interfaces)  │
├─────────────────────────────────────┤
│      Data Layer                     │
│  (Repositories, Data Sources, DTOs) │
└─────────────────────────────────────┘
```

### 2. Organisation par features

Chaque fonctionnalité majeure est isolée dans son propre module :

```
features/
├── home/           # Page d'accueil et catalogue
├── products/       # Gestion des produits
├── cart/           # Panier et checkout
├── chat/           # Messagerie
└── profile/        # Profil utilisateur
```

## Patterns utilisés

### BLoC Pattern

**Avantages** :
- Séparation UI / logique métier
- Testabilité accrue
- Gestion d'état prévisible
- Réactivité via Streams

**Implémentation** :

```dart
// Cubit (version simplifiée de BLoC)
class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartState.initial());
  
  void addToCart(CartItem item) {
    // Logique métier
    emit(state.copyWith(items: [...state.items, item]));
  }
}

// State (immutable)
class CartState extends Equatable {
  final List<CartItem> items;
  
  const CartState({required this.items});
  
  @override
  List<Object> get props => [items];
}
```

### Repository Pattern

Abstraction de la source de données :

```dart
abstract class ProductRepository {
  Future<List<Product>> getProducts();
  Future<Product> getProductById(String id);
}

class MockProductRepository implements ProductRepository {
  @override
  Future<List<Product>> getProducts() async {
    // Retourne des données mock
    return mockProducts;
  }
}
```

### InheritedWidget Pattern

Pour l'état global partagé :

```dart
class AppState extends InheritedWidget {
  final AppController controller;
  
  static AppState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppState>()!;
  }
  
  @override
  bool updateShouldNotify(AppState old) {
    return controller != old.controller;
  }
}
```

## Flux de données

### 1. Chargement des produits

```
User Action (Open App)
    ↓
HomePage Widget
    ↓
ProductsCubit.loadProducts()
    ↓
ProductRepository.getProducts()
    ↓
ProductsCubit emits ProductsState(products: [...])
    ↓
BlocBuilder rebuilds UI
    ↓
Display Products Grid
```

### 2. Ajout au panier

```
User Action (Tap "Add to Cart")
    ↓
ProductDetailsPage
    ↓
CartCubit.addToCart(item)
    ↓
CartCubit emits new CartState
    ↓
BlocBuilder updates Badge
    ↓
Show SnackBar confirmation
```

## Gestion d'état

### États locaux (Widget State)

Pour les états UI simples :
- Sélection de catégorie
- Champs de formulaire
- Animations

```dart
class _HomePageState extends State<HomePage> {
  String _selected = 'Tous';
  
  @override
  Widget build(BuildContext context) {
    // UI qui dépend de _selected
  }
}
```

### États globaux (BLoC/Cubit)

Pour les états partagés entre plusieurs écrans :
- Panier (CartCubit)
- Produits (ProductsCubit)

```dart
BlocProvider(
  create: (_) => CartCubit(),
  child: MyApp(),
)
```

### État applicatif (InheritedWidget)

Pour les données accessibles partout :
- Favoris
- Calculs de prix
- Configuration

```dart
AppState(
  controller: appController,
  child: MaterialApp(...),
)
```

## Navigation

### Structure

```
RootShell (Bottom Navigation)
├── HomePage
├── CartPage
├── ChatPage
└── ProfilePage

HomePage → ProductDetailsPage (Push)
CartPage → CheckoutPage (Push)
ProductDetailsPage → CartPage (Push)
```

### Implémentation

```dart
// Navigation simple
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (_) => ProductDetailsPage(product: p),
  ),
);

// Navigation avec animation
Navigator.of(context).push(
  PageRouteBuilder(
    pageBuilder: (_, __, ___) => ProductDetailsPage(product: p),
    transitionsBuilder: (_, anim, __, child) =>
      FadeTransition(opacity: anim, child: child),
  ),
);
```

## Injection de dépendances

### Approche actuelle

Utilisation de `BlocProvider` pour l'injection :

```dart
MultiBlocProvider(
  providers: [
    BlocProvider(
      create: (_) => ProductsCubit(
        repo: MockProductRepository(mockProducts)
      )..loadProducts(),
    ),
    BlocProvider(
      create: (_) => CartCubit(controller: appController),
    ),
  ],
  child: AppState(...),
)
```

### Évolution future

Pour une app en production, considérer :
- **get_it** pour Service Locator
- **injectable** pour génération de code
- Injection au niveau des repositories

## Gestion des erreurs

### Stratégie

1. **États d'erreur dans BLoC**
```dart
class ProductsState {
  final bool isLoading;
  final bool hasError;
  final String? error;
  final List<Product> products;
}
```

2. **Affichage conditionnel**
```dart
if (state.hasError) {
  return Center(child: Text('Erreur: ${state.error}'));
}
```

3. **Try-catch dans les Cubits**
```dart
Future<void> loadProducts() async {
  emit(state.copyWith(isLoading: true));
  try {
    final products = await repository.getProducts();
    emit(state.copyWith(products: products, isLoading: false));
  } catch (e) {
    emit(state.copyWith(hasError: true, error: e.toString()));
  }
}
```

## Performance

### Optimisations

1. **Const constructors** partout où possible
2. **ListView.builder** pour listes longues
3. **Cached images** avec `cached_network_image`
4. **Lazy loading** des données
5. **Keys** pour optimiser rebuilds

### Monitoring

```dart
// BlocObserver pour debug
class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print('${bloc.runtimeType} $change');
  }
}
```

## Tests

### Structure de tests

```dart
// Unit test - Cubit
void main() {
  group('CartCubit', () {
    late CartCubit cubit;
    
    setUp(() {
      cubit = CartCubit();
    });
    
    test('initial state is empty', () {
      expect(cubit.state.items, isEmpty);
    });
    
    test('addToCart adds item', () {
      final item = CartItem(...);
      cubit.addToCart(item);
      expect(cubit.state.items, contains(item));
    });
  });
}
```

## Évolutions futures

### Court terme
- [ ] API réelle (remplacer MockRepository)
- [ ] Authentification utilisateur
- [ ] Paiements mobiles (Wave, Orange Money)

### Moyen terme
- [ ] Cache local (Hive/SQLite)
- [ ] Synchronisation offline
- [ ] Notifications push

### Long terme
- [ ] Multi-vendor
- [ ] Recommandations IA
- [ ] AR pour essai produits
