# Phase 4: User Features

> Week 4: Cart, Addresses, and Favorites

## Goals

- [ ] Create cart DTOs and API integration
- [ ] Implement cart remote data source
- [ ] Update cart repository for API sync
- [ ] Create address management API
- [ ] Implement favorites/wishlist API
- [ ] Update cubits for API integration
- [ ] Handle offline cart actions

## Estimated Time: 4-5 days

---

## Part 1: Shopping Cart

### Backend API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/cart` | Get user cart |
| POST | `/cart/items` | Add item to cart |
| PATCH | `/cart/items/:id` | Update quantity |
| DELETE | `/cart/items/:id` | Remove item |
| DELETE | `/cart` | Clear cart |

### Step 1: Create Cart DTOs

**File:** `lib/features/cart/data/models/cart_model.dart`

```dart
import 'package:json_annotation/json_annotation.dart';
import '../../../products/data/models/product_model.dart';

part 'cart_model.g.dart';

@JsonSerializable()
class CartModel {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  final List<CartItemModel> items;
  final double subtotal;
  @JsonKey(name: 'item_count')
  final int itemCount;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  CartModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.itemCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) =>
      _$CartModelFromJson(json);

  Map<String, dynamic> toJson() => _$CartModelToJson(this);
}

@JsonSerializable()
class CartItemModel {
  final String id;
  final ProductModel product;
  final int quantity;
  final double price;
  final double total;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  CartItemModel({
    required this.id,
    required this.product,
    required this.quantity,
    required this.price,
    required this.total,
    required this.createdAt,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) =>
      _$CartItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$CartItemModelToJson(this);
}

// Request DTOs
@JsonSerializable()
class AddToCartRequest {
  @JsonKey(name: 'product_id')
  final String productId;
  final int quantity;

  AddToCartRequest({
    required this.productId,
    this.quantity = 1,
  });

  factory AddToCartRequest.fromJson(Map<String, dynamic> json) =>
      _$AddToCartRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AddToCartRequestToJson(this);
}

@JsonSerializable()
class UpdateCartItemRequest {
  final int quantity;

  UpdateCartItemRequest({required this.quantity});

  factory UpdateCartItemRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateCartItemRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateCartItemRequestToJson(this);
}
```

### Step 2: Create Cart Remote Data Source

**File:** `lib/features/cart/data/datasources/cart_remote_datasource.dart`

```dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../../core/api/api_response.dart';
import '../models/cart_model.dart';

part 'cart_remote_datasource.g.dart';

@RestApi()
abstract class CartRemoteDataSource {
  factory CartRemoteDataSource(Dio dio) = _CartRemoteDataSource;

  @GET('/cart')
  Future<ApiResponse<CartModel>> getCart();

  @POST('/cart/items')
  Future<ApiResponse<CartItemModel>> addItem(
    @Body() AddToCartRequest request,
  );

  @PATCH('/cart/items/{id}')
  Future<ApiResponse<CartItemModel>> updateItem(
    @Path('id') String itemId,
    @Body() UpdateCartItemRequest request,
  );

  @DELETE('/cart/items/{id}')
  Future<ApiResponse<void>> removeItem(@Path('id') String itemId);

  @DELETE('/cart')
  Future<ApiResponse<void>> clearCart();
}
```

### Step 3: Update Cart Repository

**File:** `lib/features/cart/data/repositories/cart_repository_impl.dart`

```dart
import '../../../../core/api/api_exceptions.dart';
import '../../../../core/api/api_response.dart';
import '../../../../core/repositories/base_repository.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_datasource.dart';
import '../datasources/cart_local_datasource.dart';
import '../models/cart_model.dart';

class CartRepositoryImpl extends BaseRepository implements CartRepository {
  final CartRemoteDataSource _remote;
  final CartLocalDataSource _local;
  final ConnectivityService _connectivity;

  CartRepositoryImpl({
    required CartRemoteDataSource remote,
    required CartLocalDataSource local,
    required ConnectivityService connectivity,
  })  : _remote = remote,
        _local = local,
        _connectivity = connectivity;

  @override
  Future<CartModel?> getCart() async {
    return handleRequest(
      request: () async {
        final response = await _remote.getCart();
        final cart = parseResponse(response);
        await _local.cacheCart(cart);
        return cart;
      },
      fallback: await _local.getCachedCart(),
    );
  }

  @override
  Future<void> addItem(String productId, int quantity) async {
    // Always update local first for immediate feedback
    await _local.addItem(productId, quantity);
    
    // Queue for sync if offline
    if (!await _connectivity.isConnected) {
      await _local.queueAction('add', productId, quantity: quantity);
      return;
    }

    return handleRequest(
      request: () async {
        final request = AddToCartRequest(
          productId: productId,
          quantity: quantity,
        );
        await _remote.addItem(request);
      },
    );
  }

  @override
  Future<void> updateItem(String itemId, int quantity) async {
    await _local.updateItem(itemId, quantity);
    
    if (!await _connectivity.isConnected) {
      await _local.queueAction('update', itemId, quantity: quantity);
      return;
    }

    return handleRequest(
      request: () async {
        final request = UpdateCartItemRequest(quantity: quantity);
        await _remote.updateItem(itemId, request);
      },
    );
  }

  @override
  Future<void> removeItem(String itemId) async {
    await _local.removeItem(itemId);
    
    if (!await _connectivity.isConnected) {
      await _local.queueAction('remove', itemId);
      return;
    }

    return handleRequest(
      request: () async {
        await _remote.removeItem(itemId);
      },
    );
  }

  @override
  Future<void> clearCart() async {
    await _local.clearCart();
    
    if (!await _connectivity.isConnected) {
      await _local.queueAction('clear', 'all');
      return;
    }

    return handleRequest(
      request: () async {
        await _remote.clearCart();
      },
    );
  }

  @override
  Future<void> syncPendingActions() async {
    if (!await _connectivity.isConnected) return;
    
    final actions = await _local.getPendingActions();
    
    for (final action in actions) {
      try {
        switch (action.type) {
          case 'add':
            await _remote.addItem(AddToCartRequest(
              productId: action.itemId,
              quantity: action.quantity ?? 1,
            ));
            break;
          case 'update':
            await _remote.updateItem(
              action.itemId,
              UpdateCartItemRequest(quantity: action.quantity ?? 1),
            );
            break;
          case 'remove':
            await _remote.removeItem(action.itemId);
            break;
          case 'clear':
            await _remote.clearCart();
            break;
        }
        await _local.removePendingAction(action.id);
      } catch (e) {
        // Stop processing on error, will retry next time
        break;
      }
    }
  }
}
```

---

## Part 2: Address Management

### Backend API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/users/addresses` | List addresses |
| POST | `/users/addresses` | Create address |
| PATCH | `/users/addresses/:id` | Update address |
| DELETE | `/users/addresses/:id` | Delete address |
| PATCH | `/users/addresses/:id/default` | Set default |

### Step 1: Create Address DTOs

**File:** `lib/features/address/data/models/address_model.dart`

```dart
import 'package:json_annotation/json_annotation.dart';

part 'address_model.g.dart';

@JsonSerializable()
class AddressModel {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'full_name')
  final String fullName;
  final String phone;
  final String street;
  final String city;
  final String state;
  final String country;
  @JsonKey(name: 'postal_code')
  final String? postalCode;
  @JsonKey(name: 'is_default')
  final bool isDefault;
  @JsonKey(name: 'additional_info')
  final String? additionalInfo;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'is_synced')
  final bool isSynced;

  AddressModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.phone,
    required this.street,
    required this.city,
    required this.state,
    this.country = 'Niger',
    this.postalCode,
    this.isDefault = false,
    this.additionalInfo,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = true,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) =>
      _$AddressModelFromJson(json);

  Map<String, dynamic> toJson() => _$AddressModelToJson(this);

  AddressModel copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? phone,
    String? street,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    bool? isDefault,
    String? additionalInfo,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return AddressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      isDefault: isDefault ?? this.isDefault,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}

@JsonSerializable()
class CreateAddressRequest {
  @JsonKey(name: 'full_name')
  final String fullName;
  final String phone;
  final String street;
  final String city;
  final String state;
  final String country;
  @JsonKey(name: 'postal_code')
  final String? postalCode;
  @JsonKey(name: 'is_default')
  final bool isDefault;
  @JsonKey(name: 'additional_info')
  final String? additionalInfo;

  CreateAddressRequest({
    required this.fullName,
    required this.phone,
    required this.street,
    required this.city,
    required this.state,
    this.country = 'Niger',
    this.postalCode,
    this.isDefault = false,
    this.additionalInfo,
  });

  factory CreateAddressRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateAddressRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateAddressRequestToJson(this);
}
```

### Step 2: Create Address Repository

**File:** `lib/features/address/data/repositories/address_repository_impl.dart`

```dart
import '../../../../core/repositories/base_repository.dart';
import '../../domain/repositories/address_repository.dart';
import '../datasources/address_remote_datasource.dart';
import '../datasources/address_local_datasource.dart';
import '../models/address_model.dart';

class AddressRepositoryImpl extends BaseRepository implements AddressRepository {
  final AddressRemoteDataSource _remote;
  final AddressLocalDataSource _local;

  AddressRepositoryImpl({
    required AddressRemoteDataSource remote,
    required AddressLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  @override
  Future<List<AddressModel>> getAddresses() async {
    return handleRequest(
      request: () async {
        final response = await _remote.getAddresses();
        final addresses = parseResponse(response);
        await _local.cacheAddresses(addresses);
        return addresses;
      },
      fallback: await _local.getCachedAddresses(),
    );
  }

  @override
  Future<AddressModel> createAddress(CreateAddressRequest request) async {
    return handleRequest(
      request: () async {
        final response = await _remote.createAddress(request);
        return parseResponse(response);
      },
    );
  }

  @override
  Future<AddressModel> updateAddress(
    String id,
    CreateAddressRequest request,
  ) async {
    return handleRequest(
      request: () async {
        final response = await _remote.updateAddress(id, request);
        return parseResponse(response);
      },
    );
  }

  @override
  Future<void> deleteAddress(String id) async {
    return handleRequest(
      request: () async {
        await _remote.deleteAddress(id);
      },
    );
  }

  @override
  Future<void> setDefaultAddress(String id) async {
    return handleRequest(
      request: () async {
        await _remote.setDefaultAddress(id);
      },
    );
  }
}
```

---

## Part 3: Favorites/Wishlist

### Backend API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/wishlist` | Get wishlist |
| POST | `/wishlist/items` | Add to wishlist |
| DELETE | `/wishlist/items/:productId` | Remove from wishlist |

### Step 1: Create Favorites Repository

**File:** `lib/features/favorites/data/repositories/favorites_repository_impl.dart`

```dart
import '../../../../core/repositories/base_repository.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_remote_datasource.dart';
import '../datasources/favorites_local_datasource.dart';
import '../../../products/data/models/product_model.dart';

class FavoritesRepositoryImpl extends BaseRepository implements FavoritesRepository {
  final FavoritesRemoteDataSource _remote;
  final FavoritesLocalDataSource _local;

  FavoritesRepositoryImpl({
    required FavoritesRemoteDataSource remote,
    required FavoritesLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  @override
  Future<List<ProductModel>> getFavorites() async {
    return handleRequest(
      request: () async {
        final response = await _remote.getWishlist();
        final products = parseResponse(response);
        await _local.cacheFavorites(products);
        return products;
      },
      fallback: await _local.getCachedFavorites(),
    );
  }

  @override
  Future<void> addToFavorites(String productId) async {
    return handleRequest(
      request: () async {
        await _remote.addItem({'product_id': productId});
        await _local.addFavorite(productId);
      },
    );
  }

  @override
  Future<void> removeFromFavorites(String productId) async {
    return handleRequest(
      request: () async {
        await _remote.removeItem(productId);
        await _local.removeFavorite(productId);
      },
    );
  }

  @override
  Future<bool> isFavorite(String productId) async {
    return _local.isFavorite(productId);
  }
}
```

---

## Checklist

- [ ] CartModel and CartItemModel DTOs created
- [ ] CartRemoteDataSource implemented
- [ ] CartLocalDataSource with offline queue
- [ ] CartRepositoryImpl with sync logic
- [ ] AddressModel and CreateAddressRequest DTOs created
- [ ] AddressRemoteDataSource implemented
- [ ] AddressRepositoryImpl created
- [ ] FavoritesRepositoryImpl created
- [ ] Offline action queue for cart operations
- [ ] CartCubit updated for API integration
- [ ] AddressCubit updated for API integration
- [ ] FavoritesCubit updated for API integration
- [ ] Tests written

---

## Next Phase

➡️ [Phase 5: Orders & Payments](./05-orders-payments.md)
