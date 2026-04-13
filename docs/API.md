# API Documentation

## Vue d'ensemble

Cette documentation décrit l'interface entre l'application mobile et le backend (actuellement mock, à remplacer par une API réelle).

## Repositories

### ProductRepository

**Localisation**: `lib/features/products/data/product_repository.dart`

Interface pour la récupération des produits.

#### Méthodes

```dart
abstract class ProductRepository {
  /// Récupère tous les produits disponibles
  Future<List<Product>> getProducts();
  
  /// Récupère un produit par son ID
  Future<Product> getProductById(String id);
  
  /// Recherche des produits par terme
  Future<List<Product>> searchProducts(String query);
  
  /// Filtre les produits par catégorie
  Future<List<Product>> getProductsByCategory(String category);
}
```

#### Implémentation Mock

```dart
class MockProductRepository implements ProductRepository {
  final List<Product> _products;
  
  MockProductRepository(this._products);
  
  @override
  Future<List<Product>> getProducts() async {
    // Simule un délai réseau
    await Future.delayed(const Duration(milliseconds: 500));
    return _products;
  }
  
  @override
  Future<Product> getProductById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _products.firstWhere((p) => p.id == id);
  }
}
```

## Modèles de données

### Product

**Localisation**: `lib/model/product.dart`

```dart
class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String category;
  final double rating;
  final String? imageUrl;      // URL de l'image (API)
  final String? imageAsset;    // Asset local (fallback)
  
  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    this.rating = 0.0,
    this.imageUrl,
    this.imageAsset,
  });
  
  // Sérialisation JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: json['price'].toDouble(),
      category: json['category'],
      rating: json['rating']?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'],
      imageAsset: json['imageAsset'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'category': category,
      'rating': rating,
      'imageUrl': imageUrl,
      'imageAsset': imageAsset,
    };
  }
}
```

### CartItem

**Localisation**: `lib/features/cart/presentation/cubit/cart_cubit.dart`

```dart
class CartItem extends Equatable {
  final Product product;
  final int quantity;
  
  const CartItem({
    required this.product,
    required this.quantity,
  });
  
  double get totalPrice => product.price * quantity;
  
  @override
  List<Object> get props => [product, quantity];
  
  CartItem copyWith({
    Product? product,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}
```

## Endpoints API (Future)

### Produits

#### GET /api/products
Récupère tous les produits

**Response**:
```json
{
  "products": [
    {
      "id": "1",
      "title": "Produit exemple",
      "description": "Description du produit",
      "price": 15000,
      "category": "Beauté",
      "rating": 4.5,
      "imageUrl": "https://example.com/image.jpg"
    }
  ],
  "total": 50,
  "page": 1,
  "perPage": 20
}
```

#### GET /api/products/:id
Récupère un produit spécifique

**Response**:
```json
{
  "id": "1",
  "title": "Produit exemple",
  "description": "Description détaillée",
  "price": 15000,
  "category": "Beauté",
  "rating": 4.5,
  "imageUrl": "https://example.com/image.jpg",
  "stock": 25,
  "variants": []
}
```

#### GET /api/products/search?q=:query
Recherche de produits

**Query params**:
- `q`: Terme de recherche
- `category`: Filtre par catégorie (optionnel)
- `minPrice`: Prix minimum (optionnel)
- `maxPrice`: Prix maximum (optionnel)

### Panier

#### POST /api/cart/add
Ajoute un produit au panier

**Request**:
```json
{
  "productId": "1",
  "quantity": 2
}
```

**Response**:
```json
{
  "success": true,
  "cart": {
    "items": [...],
    "subtotal": 30000,
    "shipping": 2000,
    "total": 32000
  }
}
```

#### PUT /api/cart/update/:itemId
Met à jour la quantité

**Request**:
```json
{
  "quantity": 3
}
```

#### DELETE /api/cart/remove/:itemId
Retire un produit du panier

### Commandes

#### POST /api/orders/create
Crée une nouvelle commande

**Request**:
```json
{
  "items": [
    {
      "productId": "1",
      "quantity": 2,
      "price": 15000
    }
  ],
  "customer": {
    "name": "John Doe",
    "phone": "+22790123456",
    "address": "Niamey, Niger"
  },
  "paymentMethod": "mobile_money",
  "total": 32000
}
```

**Response**:
```json
{
  "orderId": "ORD-123456",
  "status": "pending",
  "paymentUrl": "https://payment.example.com/...",
  "createdAt": "2025-12-01T10:00:00Z"
}
```

## Gestion des erreurs

### Codes d'erreur

```dart
enum ApiError {
  networkError,      // Pas de connexion
  serverError,       // Erreur serveur (5xx)
  notFound,          // Ressource non trouvée (404)
  unauthorized,      // Non authentifié (401)
  forbidden,         // Accès refusé (403)
  badRequest,        // Requête invalide (400)
  timeout,           // Timeout
}
```

### Format de réponse d'erreur

```json
{
  "error": {
    "code": "PRODUCT_NOT_FOUND",
    "message": "Le produit demandé n'existe pas",
    "details": {}
  }
}
```

## Authentification (Future)

### JWT Token

```dart
class AuthRepository {
  Future<AuthToken> login(String phone, String password);
  Future<void> logout();
  Future<AuthToken> refreshToken(String refreshToken);
}

class AuthToken {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
}
```

### Headers

```
Authorization: Bearer <access_token>
Content-Type: application/json
Accept: application/json
X-App-Version: 1.0.0
X-Platform: android|ios
```

## Cache et Offline

### Stratégie de cache

1. **Images**: Cache automatique via `cached_network_image`
2. **Produits**: Cache local avec expiration (1 heure)
3. **Panier**: Stockage local persistant

### Offline Queue

```dart
class OfflineActionQueue {
  // Ajoute une action à la queue
  void enqueue(OfflineAction action);
  
  // Synchronise quand la connexion revient
  Future<void> sync();
}

class OfflineAction {
  final String type;  // 'add_to_cart', 'create_order', etc.
  final Map<String, dynamic> data;
  final DateTime timestamp;
}
```

## Rate Limiting

Pour éviter la surcharge :
- Max 100 requêtes / minute / utilisateur
- Retry avec backoff exponentiel
- Cache agressif

## Sécurité

### HTTPS Only
Toutes les requêtes doivent utiliser HTTPS

### Validation
- Validation côté client ET serveur
- Sanitization des inputs
- Protection CSRF pour les mutations

### Données sensibles
- Pas de stockage de mots de passe en clair
- Tokens stockés de manière sécurisée (flutter_secure_storage)
