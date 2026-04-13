# Current State Analysis

> Detailed analysis of the AbdoulExpress codebase before API integration

## Project Structure

```
lib/
├── core/                          # Shared functionality
│   ├── constants/                 # App colors, constants
│   ├── theme/                     # App theme
│   ├── utils/                     # Offline queue, formatters
│   ├── widgets/                   # Reusable widgets
│   ├── app_state.dart            # Global app state
│   ├── data.dart                 # MOCK DATA (replace first)
│   └── widgets.dart              # Widget exports
│
├── features/                      # Feature modules
│   ├── auth/                     # Login, signup, OTP
│   │   ├── data/
│   │   │   └── auth_repository.dart    # MOCK implementation
│   │   ├── presentation/
│   │   │   ├── cubit/
│   │   │   │   ├── auth_cubit.dart
│   │   │   │   └── auth_state.dart
│   │   │   └── pages/
│   │   │       ├── login_page.dart
│   │   │       ├── signup_page.dart
│   │   │       └── otp_page.dart
│   │
│   ├── products/                 # Product catalog
│   │   ├── data/
│   │   │   └── product_repository.dart  # MOCK implementation
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── products_cubit.dart
│   │       │   └── products_state.dart
│   │       └── pages/
│   │           └── product_detail_page.dart
│   │
│   ├── cart/                     # Shopping cart
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   ├── cart_cubit.dart
│   │       │   └── cart_state.dart
│   │       └── pages/
│   │           ├── cart_page.dart
│   │           └── checkout_page.dart
│   │
│   ├── orders/                   # Order management
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   ├── orders_cubit.dart
│   │       │   └── orders_state.dart
│   │       └── pages/
│   │           ├── order_history_page.dart
│   │           ├── order_detail_page.dart
│   │           └── order_tracking_page.dart
│   │
│   ├── payment/                  # Payments
│   ├── chat/                     # Customer support
│   ├── favorites/                # Wishlist
│   ├── address/                  # Delivery addresses
│   └── settings/                 # App settings
│
├── model/                        # Domain models
│   ├── product.dart
│   ├── order.dart
│   ├── address.dart
│   └── ...
│
└── main.dart                     # Entry point
```

## State Management

### Current Cubits (8 total)

| Cubit | Location | Current Data Source |
|-------|----------|---------------------|
| `AuthCubit` | `features/auth/` | Mock repository (any email works) |
| `ProductsCubit` | `features/products/` | Mock product list |
| `CartCubit` | `features/cart/` | In-memory + AppController |
| `OrdersCubit` | `features/orders/` | Hive local + mock data |
| `PaymentCubit` | `features/payment/` | Mock payments |
| `FavoritesCubit` | `features/favorites/` | In-memory only |
| `SearchCubit` | `features/search/` | Local search |
| `ChatCubit` | `features/chat/` | Local messages |

### Storage Services

```dart
// Currently using Hive for:
- Orders (Box<Order>)
- Delivery Addresses (Box<DeliveryAddress>)
- Delivery Methods (Box<DeliveryMethod>)
- Transactions (Box<Transaction>)
- Addresses (Box<Address>)
- Messages (Box<Message>)
```

## Mock Data Locations

### 1. Products (`lib/core/data.dart`)
```dart
const mockProducts = <Product>[
  Product(
    id: 'p1',
    title: 'Coffret Cosmétiques',
    category: 'Cosmétiques',
    price: 3500,
    // ... 10 products total
  ),
];
```

### 2. Categories (`lib/core/data.dart`)
```dart
final mockCategories = <Category>[
  Category(id: 'cat1', name: 'Cosmétiques', ...),
  // ... 5 categories
];
```

### 3. Auth Repository (`lib/features/auth/data/auth_repository.dart`)
```dart
Future<String> loginWithEmail(String email, String password) async {
  // MOCK: Accept any non-empty email/password
  await Future.delayed(const Duration(milliseconds: 800));
  return _saveToken(isGuest: false);
}
```

### 4. Product Repository (`lib/features/products/data/product_repository.dart`)
```dart
class MockProductRepository implements ProductRepository {
  @override
  Future<List<Product>> fetchProducts() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _data; // Returns mock data
  }
}
```

## What's Missing for API Integration

### 🔴 Critical (Blocking)

| Missing | Location | Purpose |
|---------|----------|---------|
| HTTP Client | `lib/core/api/` | Make API calls |
| Dio/Retrofit setup | `lib/core/api/api_client.dart` | HTTP configuration |
| API Config | `lib/core/api/api_config.dart` | Environment URLs |
| Interceptors | `lib/core/api/interceptors/` | Auth tokens, logging |
| Error Handling | `lib/core/api/exceptions.dart` | API error mapping |

### 🟡 High Priority

| Missing | Location | Purpose |
|---------|----------|---------|
| DTO Models | `lib/features/X/data/models/` | API request/response |
| Remote Data Sources | `lib/features/X/data/datasources/remote/` | API calls |
| Repository Impl | `lib/features/X/data/repositories/` | Combine local+remote |
| Connectivity Check | `lib/core/services/connectivity_service.dart` | Online/offline detection |

### 🟢 Medium Priority

| Missing | Purpose |
|---------|---------|
| API Response Wrapper | Standard response format |
| Pagination Support | List pagination |
| Image Upload Service | Cloudinary integration |
| Push Notifications | FCM setup |

## Dependencies to Add

```yaml
# pubspec.yaml
dependencies:
  # HTTP & Networking
  dio: ^5.4.0
  retrofit: ^4.0.3
  connectivity_plus: ^5.0.2
  
  # Authentication
  flutter_secure_storage: ^9.0.0
  jwt_decoder: ^2.0.1
  
  # Environment
  flutter_dotenv: ^5.1.0

dev_dependencies:
  retrofit_generator: ^8.0.6
  json_serializable: ^6.7.1
```

## Model Discrepancies

### Current Product Model vs API Spec

| Field | Current | API Expected |
|-------|---------|--------------|
| title | String | name (multi-language) |
| category | String | categoryId + Category object |
| imageAsset | String? | - (remove) |
| imageUrl | String? | images: List<String> |
| - | missing | descriptionEn/Fr/Ha |
| - | missing | quantity (stock) |
| - | missing | vendorId |
| - | missing | status |

### Required Model Updates

1. **Product**: Add multi-language, multiple images, stock
2. **Order**: Ensure isSynced flag exists
3. **User**: Add full profile fields
4. **Address**: Add isSynced flag

## Testing Current State

```bash
# Run existing tests
flutter test

# Current test files:
test/
├── unit/
├── widget/
└── integration/
```

## Files to Modify/Replace

### Phase 1 (Replace)
- `lib/core/data.dart` → Remove mocks, keep constants
- `lib/features/auth/data/auth_repository.dart` → Repository impl
- `lib/features/products/data/product_repository.dart` → Repository impl

### Phase 2 (Create)
- `lib/core/api/` (entire folder)
- `lib/features/auth/data/datasources/`
- `lib/features/auth/data/models/`

### Phase 3 (Create)
- `lib/features/products/data/datasources/`
- `lib/features/products/data/models/`

## Offline Strategy

Current implementation:
```dart
// lib/core/utils/offline_action_queue.dart
class OfflineActionQueue {
  final List<OfflineAction> _queue = [];
  // In-memory only - needs Hive persistence
}
```

Needed improvements:
1. Persist queue to Hive
2. Process queue when online
3. Conflict resolution for sync

## Next Steps

1. ✅ Review this analysis
2. ➡️ Start [Phase 1: Infrastructure](./01-infrastructure.md)
3. Add required dependencies
4. Create API client foundation
