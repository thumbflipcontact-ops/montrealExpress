# Guide: Système de File d'Attente (Queue) avec Flutter et BLoC

## 📚 Table des Matières
1. [Introduction](#introduction)
2. [Architecture du Système de Panier](#architecture-du-système-de-panier)
3. [Composants Principaux](#composants-principaux)
4. [Implémentation de la Queue Offline](#implémentation-de-la-queue-offline)
5. [Gestion d'État avec BLoC](#gestion-détat-avec-bloc)
6. [Synchronisation Controller-Cubit](#synchronisation-controller-cubit)
7. [Cas d'Usage Pratiques](#cas-dusage-pratiques)
8. [Bonnes Pratiques](#bonnes-pratiques)
9. [Tests Unitaires](#tests-unitaires)

---

## 🎯 Introduction

Ce guide démontre comment implémenter un **système de file d'attente (queue)** robuste avec **Flutter** et **BLoC**, basé sur l'implémentation réelle du système de panier de l'application AbdoulExpress.

### Pourquoi une Queue ?
- **Offline-First**: Actions utilisateur mises en queue quand pas de connexion
- **Ordre garanti**: Les opérations s'exécutent dans l'ordre d'ajout
- **Résilience**: Réessai automatique en cas d'échec
- **UX fluide**: L'utilisateur ne voit pas les échecs réseau

---

## 🏗️ Architecture du Système de Panier

Le système de panier d'AbdoulExpress combine **trois couches** :

```
┌─────────────────────────────────────────┐
│         UI (CartPage)                   │
│  - Affiche les items                    │
│  - Interactions utilisateur             │
└──────────────┬──────────────────────────┘
               │ BlocBuilder<CartCubit>
               ↓
┌─────────────────────────────────────────┐
│      CartCubit (State Management)       │
│  - Émet des états immuables             │
│  - Orchestre les actions                │
│  - Synchronise avec AppController       │
└──────────────┬──────────────────────────┘
               │ Utilise
               ↓
┌─────────────────────────────────────────┐
│    AppController (Business Logic)       │
│  - Map<String, CartItem> _cart          │
│  - Logique métier (totaux, shipping)    │
│  - Notifie les changements              │
└──────────────┬──────────────────────────┘
               │ Action queueing
               ↓
┌─────────────────────────────────────────┐
│   OfflineActionQueue (Queue System)     │
│  - Stocke les actions en attente        │
│  - Exécution séquentielle               │
│  - Gestion des erreurs                  │
└─────────────────────────────────────────┘
```

---

## 🔧 Composants Principaux

### 1. **CartItem** - Modèle de Données

```dart
class CartItem {
  CartItem({required this.product, this.quantity = 1});
  final Product product;
  int quantity;

  double get total => product.price * quantity;
}
```

**Points clés** :
- Objet simple, mutable (quantité modifiable)
- Calcul automatique du total
- Lié à un `Product` immuable

### 2. **CartState** - État Immuable

```dart
part of 'cart_cubit.dart';

class CartState extends Equatable {
  const CartState({this.items = const []});

  const CartState.initial() : this(items: const []);

  final List<CartItem> items;

  @override
  List<Object?> get props => [items];
}
```

**Caractéristiques** :
- ✅ **Immuable** grâce à `const` et `final`
- ✅ **Comparable** avec `Equatable` (optimisation des rebuilds)
- ✅ **État initial** avec factory constructor
- ✅ **Liste non-modifiable** passée au widget

### 3. **CartCubit** - Orchestrateur d'État

```dart
class CartCubit extends Cubit<CartState> {
  CartCubit({required this.controller}) : super(CartState.initial()) {
    _syncFromController();
  }

  final AppController controller;

  void _syncFromController() {
    final items = controller.cartItems;
    emit(CartState(items: items));
  }

  void addToCart(CartItem item) {
    // 1. Queue l'action pour offline
    offlineQueue.add(OfflineAction(
      id: 'add-${item.product.id}',
      action: () async {
        controller.addToCart(item.product, quantity: item.quantity);
      }
    ));

    // 2. Applique immédiatement en local (optimistic update)
    controller.addToCart(item.product, quantity: item.quantity);
    
    // 3. Synchronise l'état
    _syncFromController();
  }

  void removeFromCart(String productId) {
    controller.removeFromCart(productId);
    _syncFromController();
  }

  void setQuantity(String productId, int quantity) {
    controller.setQuantity(productId, quantity);
    _syncFromController();
  }
}
```

**Responsabilités** :
- 🎯 Orchestrer les actions (add, remove, update)
- 🔄 Synchroniser état UI ↔ logique métier
- 📱 Gérer la queue offline
- 📢 Émettre des états immuables

---

## 📦 Implémentation de la Queue Offline

### Structure de la Queue

```dart
typedef OfflineActionFn = Future<void> Function();

class OfflineAction {
  final String id;
  final OfflineActionFn action;
  final DateTime createdAt;

  OfflineAction({required this.id, required this.action}) 
      : createdAt = DateTime.now();
}
```

### Gestionnaire de Queue

```dart
class OfflineActionQueue {
  final List<OfflineAction> _queue = [];
  bool _isProcessing = false;

  /// Ajouter une action à la queue
  Future<void> add(OfflineAction action) async {
    _queue.add(action);
  }

  /// Traiter la queue de manière séquentielle
  Future<void> process() async {
    if (_isProcessing) return;
    _isProcessing = true;

    while (_queue.isNotEmpty) {
      final action = _queue.first;
      try {
        await action.action();
        _queue.removeAt(0); // Succès → retirer de la queue
      } catch (e) {
        // Échec → arrêter et réessayer plus tard
        break;
      }
    }

    _isProcessing = false;
  }

  bool get hasPending => _queue.isNotEmpty;
  void clear() => _queue.clear();
}

// Instance globale (singleton)
final OfflineActionQueue offlineQueue = OfflineActionQueue();
```

### Points Importants

1. **Exécution Séquentielle** : Les actions s'exécutent dans l'ordre FIFO
2. **Gestion d'Erreurs** : Arrêt au premier échec (retry plus tard)
3. **État de Traitement** : `_isProcessing` évite les exécutions concurrentes
4. **Timestamps** : `createdAt` pour debug et expiration

---

## 🎭 Gestion d'État avec BLoC

### Pattern Utilisé : Cubit (BLoC simplifié)

**Cubit** = Subset de BLoC sans events explicites

```dart
// Au lieu de :
// Event → Bloc → State

// On a directement :
// Method → Cubit → State
```

### Flux de Données

```
Utilisateur appuie sur "Ajouter au panier"
         ↓
   CartPage appelle context.read<CartCubit>().addToCart(item)
         ↓
   CartCubit.addToCart() exécute :
   1. offlineQueue.add(...)
   2. controller.addToCart(...)
   3. _syncFromController()
         ↓
   emit(CartState(items: newItems))
         ↓
   BlocBuilder reconstruit l'UI
         ↓
   Utilisateur voit la mise à jour
```

### Exemple d'Utilisation dans l'UI

```dart
class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final items = state.items;
        
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, i) {
            final item = items[i];
            return ListTile(
              title: Text(item.product.title),
              subtitle: Text('Quantité: ${item.quantity}'),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  // Action déclenchée
                  context.read<CartCubit>()
                    .removeFromCart(item.product.id);
                },
              ),
            );
          },
        );
      },
    );
  }
}
```

---

## 🔄 Synchronisation Controller-Cubit

### Pourquoi Deux Couches ?

| **AppController**                  | **CartCubit**                    |
|------------------------------------|----------------------------------|
| Logique métier (calculs, rules)    | Gestion d'état UI               |
| Mutable (Map, Set)                 | Immuable (State objects)        |
| ChangeNotifier (legacy)            | BLoC (modern, testable)         |
| Peut être réutilisé ailleurs       | Spécifique à un feature         |

### Méthode de Synchronisation

```dart
void _syncFromController() {
  // Copie la liste pour garantir l'immutabilité
  final items = controller.cartItems; // Retourne une liste non-modifiable
  emit(CartState(items: items));
}
```

**Optimisation** : 
- `controller.cartItems` retourne `_cart.values.toList(growable: false)`
- La liste est non-extensible mais les items restent mutables
- C'est suffisant car l'UI réagit au changement de référence de liste

---

## 💡 Cas d'Usage Pratiques

### 1. Ajouter un Produit au Panier

```dart
// Dans ProductDetailPage
ElevatedButton(
  onPressed: () {
    final cartItem = CartItem(
      product: currentProduct,
      quantity: selectedQuantity,
    );
    context.read<CartCubit>().addToCart(cartItem);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${currentProduct.title} ajouté au panier')),
    );
  },
  child: Text('Ajouter au panier'),
)
```

### 2. Modifier une Quantité

```dart
// Widget QuantityStepper
QuantityStepper(
  value: cartItem.quantity,
  onChanged: (newQuantity) {
    context.read<CartCubit>().setQuantity(
      cartItem.product.id,
      newQuantity,
    );
  },
)
```

### 3. Vider le Panier

```dart
void clearCart() {
  final itemIds = controller.cartItems
    .map((item) => item.product.id)
    .toList();
  
  for (final id in itemIds) {
    controller.removeFromCart(id);
  }
  _syncFromController();
}
```

### 4. Traiter la Queue Offline

```dart
// Appeler quand la connexion revient
void onConnectivityRestored() async {
  if (offlineQueue.hasPending) {
    await offlineQueue.process();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Actions synchronisées')),
    );
  }
}
```

---

## ✅ Bonnes Pratiques

### 1. **Immutabilité des États**

```dart
// ❌ MAUVAIS
class CartState {
  List<CartItem> items = [];
  
  void addItem(CartItem item) {
    items.add(item); // Mutation !
  }
}

// ✅ BON
class CartState extends Equatable {
  const CartState({this.items = const []});
  final List<CartItem> items;
  
  @override
  List<Object?> get props => [items];
}
```

### 2. **Logging Structuré**

```dart
void _logDebug(String message) {
  if (kDebugMode) {
    debugPrint('🛒 [CartCubit] $message');
  }
}

// Usage
_logDebug('Adding to cart: ${item.product.title} (x${item.quantity})');
```

### 3. **Isolation des Responsabilités**

```dart
// AppController : Logique métier pure
int get cartCount => _cart.values.fold(0, (sum, it) => sum + it.quantity);
double get subtotal => _cart.values.fold(0, (sum, it) => sum + it.total);
double get shipping => _cart.isEmpty ? 0 : 1000.0;
double get total => subtotal + shipping;

// CartCubit : Orchestration
void addToCart(CartItem item) {
  offlineQueue.add(...);     // Queue management
  controller.addToCart(...);  // Business logic
  _syncFromController();      // State sync
}
```

### 4. **Gestion des Erreurs**

```dart
Future<void> process() async {
  while (_queue.isNotEmpty) {
    final action = _queue.first;
    try {
      await action.action();
      _queue.removeAt(0);
    } catch (e) {
      // Log l'erreur et arrête
      debugPrint('❌ Queue processing failed: $e');
      break; // Retry plus tard
    }
  }
}
```

### 5. **Persistance de la Queue**

Pour la production, persister la queue :

```dart
class PersistentOfflineQueue extends OfflineActionQueue {
  final HiveBox<OfflineAction> _box;
  
  @override
  Future<void> add(OfflineAction action) async {
    await _box.add(action);
    super.add(action);
  }
  
  @override
  Future<void> process() async {
    await super.process();
    // Nettoyer le storage après traitement
    await _box.clear();
  }
}
```

---

## 🧪 Tests Unitaires

### Test du Cubit

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:abdoul_express/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:abdoul_express/core/app_state.dart';

void main() {
  group('CartCubit', () {
    late AppController controller;
    late CartCubit cubit;

    setUp(() {
      controller = AppController();
      cubit = CartCubit(controller: controller);
    });

    test('initial state is empty', () {
      expect(cubit.state.items.length, 0);
    });

    test('addToCart adds item and syncs state', () {
      final product = Product(
        id: '1',
        title: 'Test Product',
        price: 5000,
        imageUrl: '',
      );
      
      final item = CartItem(product: product, quantity: 2);
      cubit.addToCart(item);

      expect(cubit.state.items.length, 1);
      expect(cubit.state.items.first.quantity, 2);
      expect(controller.cartCount, 2);
    });

    test('removeFromCart removes item and syncs state', () {
      final product = Product(id: '1', title: 'Test', price: 1000, imageUrl: '');
      final item = CartItem(product: product, quantity: 1);
      
      cubit.addToCart(item);
      expect(cubit.state.items.length, 1);
      
      cubit.removeFromCart(product.id);
      expect(cubit.state.items.length, 0);
    });

    test('setQuantity updates quantity correctly', () {
      final product = Product(id: '1', title: 'Test', price: 1000, imageUrl: '');
      final item = CartItem(product: product, quantity: 1);
      
      cubit.addToCart(item);
      cubit.setQuantity(product.id, 5);
      
      expect(cubit.state.items.first.quantity, 5);
      expect(controller.cartCount, 5);
    });

    test('setQuantity to 0 removes item', () {
      final product = Product(id: '1', title: 'Test', price: 1000, imageUrl: '');
      final item = CartItem(product: product, quantity: 3);
      
      cubit.addToCart(item);
      cubit.setQuantity(product.id, 0);
      
      expect(cubit.state.items.length, 0);
    });
  });
}
```

### Test de la Queue

```dart
void main() {
  group('OfflineActionQueue', () {
    late OfflineActionQueue queue;

    setUp(() {
      queue = OfflineActionQueue();
    });

    tearDown(() {
      queue.clear();
    });

    test('add action to queue', () {
      queue.add(OfflineAction(
        id: 'test-1',
        action: () async {},
      ));
      expect(queue.hasPending, true);
    });

    test('process executes actions in order', () async {
      final results = <String>[];
      
      queue.add(OfflineAction(
        id: 'action-1',
        action: () async => results.add('first'),
      ));
      queue.add(OfflineAction(
        id: 'action-2',
        action: () async => results.add('second'),
      ));

      await queue.process();
      
      expect(results, ['first', 'second']);
      expect(queue.hasPending, false);
    });

    test('process stops on error', () async {
      final results = <String>[];
      
      queue.add(OfflineAction(
        id: 'action-1',
        action: () async => results.add('first'),
      ));
      queue.add(OfflineAction(
        id: 'action-2',
        action: () async => throw Exception('Network error'),
      ));
      queue.add(OfflineAction(
        id: 'action-3',
        action: () async => results.add('third'),
      ));

      await queue.process();
      
      expect(results, ['first']); // Seulement la première action
      expect(queue.hasPending, true); // Actions restantes en attente
    });
  });
}
```

---

## 🎓 Résumé & Concepts Clés

### Flux de Données Complet

```
┌─────────────────────────────────────────────────────────────┐
│                    USER ACTION                              │
│              (Tap "Ajouter au panier")                      │
└────────────────────────┬────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────────┐
│  CartPage: context.read<CartCubit>().addToCart(item)        │
└────────────────────────┬────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────────┐
│  CartCubit:                                                 │
│  1. offlineQueue.add(OfflineAction(...))                    │
│  2. controller.addToCart(product, quantity)                 │
│  3. _syncFromController()                                   │
│  4. emit(CartState(items: newItems))                        │
└────────────────────────┬────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────────┐
│  BlocBuilder rebuilds with new state                        │
└────────────────────────┬────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────────┐
│  UI updated → User sees new item in cart                    │
└─────────────────────────────────────────────────────────────┘
```

### Principes Fondamentaux

1. **Single Source of Truth** : `AppController._cart` est la source unique
2. **Immutabilité** : Les états UI (`CartState`) sont immuables
3. **Réactivité** : BlocBuilder reconstruit automatiquement
4. **Résilience** : Queue offline pour actions en attente
5. **Testabilité** : Chaque composant testé indépendamment

### Avantages de cette Architecture

✅ **Séparation des Préoccupations** : UI ≠ Logique ≠ Queue  
✅ **Testable** : Mocking facile, tests isolés  
✅ **Scalable** : Ajouter features sans toucher au core  
✅ **Offline-First** : UX fluide même sans réseau  
✅ **Debuggable** : Logs structurés à chaque niveau  

---

## 📚 Références

- [BLoC Pattern Official Documentation](https://bloclibrary.dev)
- [Equatable Package](https://pub.dev/packages/equatable)
- [Flutter State Management](https://flutter.dev/docs/development/data-and-backend/state-mgmt)
- [Code Source AbdoulExpress](../lib/features/cart/)

---

**Auteur** : Documentation basée sur l'implémentation AbdoulExpress  
**Date** : Décembre 2025  
**Version** : 1.0.0
