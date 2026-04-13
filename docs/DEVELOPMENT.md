# Guide de Développement

## Configuration de l'environnement

### Prérequis

1. **Flutter SDK**
   ```bash
   # Vérifier l'installation
   flutter doctor
   
   # Version requise
   Flutter ≥ 3.0.0
   Dart ≥ 3.0.0
   ```

2. **IDE recommandé**
   - VS Code avec extensions :
     - Flutter
     - Dart
     - Bloc
     - Error Lens
   - Android Studio (alternative)

3. **Outils**
   - Git
   - Android SDK (pour Android)
   - Xcode (pour iOS, Mac uniquement)

### Installation du projet

```bash
# 1. Cloner le repository
git clone <repository-url>
cd abdoul_express

# 2. Installer les dépendances
flutter pub get

# 3. Générer les fichiers (si nécessaire)
flutter pub run build_runner build

# 4. Vérifier la configuration
flutter doctor -v

# 5. Lancer l'app
flutter run
```

## Workflow de développement

### 1. Créer une nouvelle feature

```bash
# Créer une branche
git checkout -b feature/nom-de-la-feature

# Structure de la feature
lib/features/ma_feature/
├── data/
│   ├── models/
│   ├── repositories/
│   └── datasources/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── bloc/ ou cubit/
    ├── pages/
    └── widgets/
```

### 2. Ajouter un nouveau Cubit

```dart
// 1. Créer le state
class MaFeatureState extends Equatable {
  final bool isLoading;
  final String? error;
  final List<Data> data;
  
  const MaFeatureState({
    this.isLoading = false,
    this.error,
    this.data = const [],
  });
  
  @override
  List<Object?> get props => [isLoading, error, data];
  
  MaFeatureState copyWith({
    bool? isLoading,
    String? error,
    List<Data>? data,
  }) {
    return MaFeatureState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      data: data ?? this.data,
    );
  }
}

// 2. Créer le cubit
class MaFeatureCubit extends Cubit<MaFeatureState> {
  final Repository repository;
  
  MaFeatureCubit({required this.repository}) 
    : super(const MaFeatureState());
  
  Future<void> loadData() async {
    emit(state.copyWith(isLoading: true));
    try {
      final data = await repository.getData();
      emit(state.copyWith(data: data, isLoading: false));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }
}

// 3. Fournir le cubit
BlocProvider(
  create: (_) => MaFeatureCubit(repository: repo)..loadData(),
  child: MaFeaturePage(),
)

// 4. Consommer dans l'UI
BlocBuilder<MaFeatureCubit, MaFeatureState>(
  builder: (context, state) {
    if (state.isLoading) {
      return CircularProgressIndicator();
    }
    if (state.error != null) {
      return Text('Erreur: ${state.error}');
    }
    return ListView(children: state.data.map(...).toList());
  },
)
```

### 3. Ajouter une nouvelle page

```dart
// 1. Créer le fichier
// lib/features/ma_feature/presentation/pages/ma_page.dart

class MaPage extends StatelessWidget {
  const MaPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ma Page'),
        centerTitle: true,
      ),
      body: BlocBuilder<MaFeatureCubit, MaFeatureState>(
        builder: (context, state) {
          // UI logic
        },
      ),
    );
  }
}

// 2. Ajouter la navigation
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (_) => const MaPage(),
  ),
);
```

### 4. Créer un widget réutilisable

```dart
// lib/core/widgets/mon_widget.dart

class MonWidget extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  
  const MonWidget({
    super.key,
    required this.title,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Text(title),
      ),
    );
  }
}

// Exporter dans core/widgets.dart
export 'widgets/mon_widget.dart';
```

## Bonnes pratiques

### Code Style

```dart
// ✅ BON
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            // ...
          ],
        ),
      ),
    );
  }
}

// ❌ MAUVAIS
class productcard extends StatelessWidget {
  Product? p;
  Function? tap;
  
  productcard({this.p, this.tap});
  
  @override
  Widget build(context) {
    // ...
  }
}
```

### Gestion d'état

```dart
// ✅ BON - État immutable
class CartState extends Equatable {
  final List<CartItem> items;
  
  const CartState({required this.items});
  
  @override
  List<Object> get props => [items];
  
  CartState copyWith({List<CartItem>? items}) {
    return CartState(items: items ?? this.items);
  }
}

// ❌ MAUVAIS - État mutable
class CartState {
  List<CartItem> items = [];
  
  void addItem(CartItem item) {
    items.add(item); // Mutation directe
  }
}
```

### Performance

```dart
// ✅ BON - Const constructors
const Text('Hello')
const SizedBox(height: 16)
const Icon(Icons.star)

// ✅ BON - ListView.builder pour listes longues
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ItemWidget(item: items[index]);
  },
)

// ❌ MAUVAIS - ListView avec children pour listes longues
ListView(
  children: items.map((item) => ItemWidget(item: item)).toList(),
)
```

### Navigation

```dart
// ✅ BON - Navigation typée
Navigator.of(context).push(
  MaterialPageRoute<void>(
    builder: (_) => const ProductDetailsPage(product: product),
  ),
);

// ✅ BON - Navigation avec résultat
final result = await Navigator.of(context).push<bool>(
  MaterialPageRoute(
    builder: (_) => const ConfirmationPage(),
  ),
);
if (result == true) {
  // Action confirmée
}
```

## Tests

### Tests unitaires (Cubit)

```dart
// test/unit/cart_cubit_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';

void main() {
  group('CartCubit', () {
    late CartCubit cubit;
    
    setUp(() {
      cubit = CartCubit(controller: MockAppController());
    });
    
    tearDown(() {
      cubit.close();
    });
    
    test('initial state is empty', () {
      expect(cubit.state.items, isEmpty);
    });
    
    blocTest<CartCubit, CartState>(
      'addToCart adds item to cart',
      build: () => cubit,
      act: (cubit) => cubit.addToCart(
        CartItem(product: mockProduct, quantity: 1),
      ),
      expect: () => [
        isA<CartState>()
          .having((s) => s.items.length, 'items length', 1),
      ],
    );
  });
}
```

### Tests de widgets

```dart
// test/widget/product_card_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('ProductCard displays product info', (tester) async {
    final product = Product(
      id: '1',
      title: 'Test Product',
      price: 1000,
      // ...
    );
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductCard(
            product: product,
            onTap: () {},
          ),
        ),
      ),
    );
    
    expect(find.text('Test Product'), findsOneWidget);
    expect(find.text('1000 F CFA'), findsOneWidget);
  });
}
```

### Lancer les tests

```bash
# Tous les tests
flutter test

# Tests avec coverage
flutter test --coverage

# Tests spécifiques
flutter test test/unit/cart_cubit_test.dart

# Voir le coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Debugging

### Flutter DevTools

```bash
# Lancer l'app en mode debug
flutter run

# Ouvrir DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

### Logs

```dart
// Debug print
debugPrint('Message de debug');

// Logger dans BLoC
class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    debugPrint('${bloc.runtimeType} $change');
  }
  
  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    debugPrint('${bloc.runtimeType} $error $stackTrace');
    super.onError(bloc, error, stackTrace);
  }
}

// Dans main.dart
void main() {
  Bloc.observer = AppBlocObserver();
  runApp(const MyApp());
}
```

## Build et Release

### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle (pour Play Store)
flutter build appbundle --release

# Fichiers générés
build/app/outputs/flutter-apk/app-release.apk
build/app/outputs/bundle/release/app-release.aab
```

### iOS

```bash
# Build
flutter build ios --release

# Archive (dans Xcode)
# Product > Archive
```

### Configuration

```yaml
# pubspec.yaml
name: abdoul_express
description: E-commerce app for Africa
version: 1.0.0+1  # version+build

# android/app/build.gradle
defaultConfig {
    applicationId "com.abdoulexpress.app"
    minSdkVersion 21
    targetSdkVersion 33
    versionCode 1
    versionName "1.0.0"
}
```

## Outils utiles

### Génération de code

```bash
# Icons
flutter pub run flutter_launcher_icons:main

# Splash screen
flutter pub run flutter_native_splash:create
```

### Analyse de code

```bash
# Analyse statique
flutter analyze

# Formater le code
dart format lib/

# Vérifier les dépendances
flutter pub outdated
```

## Ressources

- [Flutter Documentation](https://docs.flutter.dev/)
- [BLoC Library](https://bloclibrary.dev/)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Material Design](https://material.io/design)
