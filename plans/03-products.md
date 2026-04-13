# Phase 3: Product Catalog

> Week 3: Fetch products from API with filtering and caching

## Goals

- [ ] Create product DTOs
- [ ] Implement product remote data source
- [ ] Implement product local data source (cache)
- [ ] Create product repository
- [ ] Update ProductsCubit
- [ ] Add search functionality
- [ ] Implement category filtering
- [ ] Add pagination support

## Estimated Time: 4-5 days

---

## Backend API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/products` | List products (paginated) |
| GET | `/products/:id` | Product details |
| GET | `/products/featured` | Featured products |
| GET | `/products/trending` | Trending products |
| GET | `/products/search` | Search products |
| GET | `/categories` | List categories |
| GET | `/categories/:id/products` | Products by category |

### Query Parameters for `/products`

| Param | Type | Description |
|-------|------|-------------|
| page | int | Page number (default: 1) |
| limit | int | Items per page (default: 20) |
| category | string | Filter by category ID |
| minPrice | number | Minimum price (XOF) |
| maxPrice | number | Maximum price (XOF) |
| search | string | Search term |
| sortBy | string | Sort field (price, rating, newest, popularity) |
| order | string | Sort order (asc, desc) |
| featured | boolean | Featured products only |
| trending | boolean | Trending products only |

---

## Step 1: Create Product DTOs

### 1.1 Product Model

**File:** `lib/features/products/data/models/product_model.dart`

```dart
import 'package:json_annotation/json_annotation.dart';

part 'product_model.g.dart';

@JsonSerializable()
class ProductModel {
  final String id;
  final String slug;
  final String sku;
  
  // Multi-language names
  final String name;
  @JsonKey(name: 'name_en')
  final String nameEn;
  @JsonKey(name: 'name_fr')
  final String nameFr;
  @JsonKey(name: 'name_ha')
  final String? nameHa;
  
  // Multi-language descriptions
  final String description;
  @JsonKey(name: 'description_en')
  final String descriptionEn;
  @JsonKey(name: 'description_fr')
  final String descriptionFr;
  @JsonKey(name: 'description_ha')
  final String? descriptionHa;
  
  // Pricing
  final double price;
  @JsonKey(name: 'compare_price')
  final double? comparePrice;
  final String currency;
  
  // Inventory
  final int quantity;
  @JsonKey(name: 'low_stock_threshold')
  final int lowStockThreshold;
  
  // Media
  final List<String> images;
  final String thumbnail;
  final String? video;
  
  // Relations
  @JsonKey(name: 'category_id')
  final String categoryId;
  @JsonKey(name: 'vendor_id')
  final String vendorId;
  
  // Attributes
  final double? weight;
  final List<String> tags;
  
  // Status
  final String status; // draft, active, out_of_stock, discontinued
  final bool featured;
  final bool trending;
  
  // Stats
  @JsonKey(name: 'view_count')
  final int viewCount;
  @JsonKey(name: 'purchase_count')
  final int purchaseCount;
  final double rating;
  @JsonKey(name: 'review_count')
  final int reviewCount;
  
  // Timestamps
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  ProductModel({
    required this.id,
    required this.slug,
    required this.sku,
    required this.name,
    required this.nameEn,
    required this.nameFr,
    this.nameHa,
    required this.description,
    required this.descriptionEn,
    required this.descriptionFr,
    this.descriptionHa,
    required this.price,
    this.comparePrice,
    this.currency = 'XOF',
    required this.quantity,
    this.lowStockThreshold = 10,
    required this.images,
    required this.thumbnail,
    this.video,
    required this.categoryId,
    required this.vendorId,
    this.weight,
    required this.tags,
    required this.status,
    this.featured = false,
    this.trending = false,
    this.viewCount = 0,
    this.purchaseCount = 0,
    this.rating = 0,
    this.reviewCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductModelToJson(this);

  // Get localized name based on language
  String getLocalizedName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return nameEn;
      case 'fr':
        return nameFr;
      case 'ha':
        return nameHa ?? name;
      default:
        return name;
    }
  }

  // Get localized description based on language
  String getLocalizedDescription(String languageCode) {
    switch (languageCode) {
      case 'en':
        return descriptionEn;
      case 'fr':
        return descriptionFr;
      case 'ha':
        return descriptionHa ?? description;
      default:
        return description;
    }
  }

  // Check if product is in stock
  bool get isInStock => quantity > 0 && status == 'active';

  // Check if product is low stock
  bool get isLowStock => quantity <= lowStockThreshold && quantity > 0;

  // Calculate discount percentage
  int? get discountPercentage {
    if (comparePrice == null || comparePrice! <= price) return null;
    return (((comparePrice! - price) / comparePrice!) * 100).round();
  }

  // Get display price (formatted)
  String get displayPrice => '${price.toStringAsFixed(0)} $currency';
}
```

### 1.2 Category Model

**File:** `lib/features/products/data/models/category_model.dart`

```dart
import 'package:json_annotation/json_annotation.dart';

part 'category_model.g.dart';

@JsonSerializable()
class CategoryModel {
  final String id;
  final String slug;
  final String name;
  @JsonKey(name: 'name_en')
  final String nameEn;
  @JsonKey(name: 'name_fr')
  final String nameFr;
  @JsonKey(name: 'name_ha')
  final String? nameHa;
  final String? description;
  final String? icon;
  final String? image;
  
  @JsonKey(name: 'parent_id')
  final String? parentId;
  final int order;
  @JsonKey(name: 'is_active')
  final bool isActive;
  
  @JsonKey(name: 'product_count')
  final int? productCount;
  
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  CategoryModel({
    required this.id,
    required this.slug,
    required this.name,
    required this.nameEn,
    required this.nameFr,
    this.nameHa,
    this.description,
    this.icon,
    this.image,
    this.parentId,
    this.order = 0,
    this.isActive = true,
    this.productCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);

  String getLocalizedName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return nameEn;
      case 'fr':
        return nameFr;
      case 'ha':
        return nameHa ?? name;
      default:
        return name;
    }
  }
}
```

### 1.3 Product Filter Request

**File:** `lib/features/products/data/models/product_filter.dart`

```dart
import 'package:json_annotation/json_annotation.dart';

part 'product_filter.g.dart';

@JsonSerializable()
class ProductFilter {
  final int page;
  final int limit;
  final String? category;
  @JsonKey(name: 'min_price')
  final double? minPrice;
  @JsonKey(name: 'max_price')
  final double? maxPrice;
  final String? search;
  @JsonKey(name: 'sort_by')
  final String? sortBy;
  final String? order;
  final bool? featured;
  final bool? trending;

  ProductFilter({
    this.page = 1,
    this.limit = 20,
    this.category,
    this.minPrice,
    this.maxPrice,
    this.search,
    this.sortBy,
    this.order,
    this.featured,
    this.trending,
  });

  factory ProductFilter.fromJson(Map<String, dynamic> json) =>
      _$ProductFilterFromJson(json);

  Map<String, dynamic> toJson() => _$ProductFilterToJson(this);

  ProductFilter copyWith({
    int? page,
    int? limit,
    String? category,
    double? minPrice,
    double? maxPrice,
    String? search,
    String? sortBy,
    String? order,
    bool? featured,
    bool? trending,
  }) {
    return ProductFilter(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      category: category ?? this.category,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      search: search ?? this.search,
      sortBy: sortBy ?? this.sortBy,
      order: order ?? this.order,
      featured: featured ?? this.featured,
      trending: trending ?? this.trending,
    );
  }

  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    
    if (category != null) params['category'] = category;
    if (minPrice != null) params['minPrice'] = minPrice;
    if (maxPrice != null) params['maxPrice'] = maxPrice;
    if (search != null && search!.isNotEmpty) params['search'] = search;
    if (sortBy != null) params['sortBy'] = sortBy;
    if (order != null) params['order'] = order;
    if (featured != null) params['featured'] = featured;
    if (trending != null) params['trending'] = trending;
    
    return params;
  }
}
```

---

## Step 2: Run Code Generation

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Step 3: Create Product Remote Data Source

**File:** `lib/features/products/data/datasources/product_remote_datasource.dart`

```dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../../core/api/api_response.dart';
import '../../../../core/api/pagination.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

part 'product_remote_datasource.g.dart';

@RestApi()
abstract class ProductRemoteDataSource {
  factory ProductRemoteDataSource(Dio dio) = _ProductRemoteDataSource;

  @GET('/products')
  Future<ApiResponse<PaginatedResponse<ProductModel>>> getProducts(
    @Queries() Map<String, dynamic> queries,
  );

  @GET('/products/{id}')
  Future<ApiResponse<ProductModel>> getProductById(
    @Path('id') String id,
  );

  @GET('/products/featured')
  Future<ApiResponse<List<ProductModel>>> getFeaturedProducts();

  @GET('/products/trending')
  Future<ApiResponse<List<ProductModel>>> getTrendingProducts();

  @GET('/products/search')
  Future<ApiResponse<PaginatedResponse<ProductModel>>> searchProducts(
    @Query('q') String query,
    @Queries() Map<String, dynamic> queries,
  );

  @GET('/categories')
  Future<ApiResponse<List<CategoryModel>>> getCategories();

  @GET('/categories/{id}/products')
  Future<ApiResponse<PaginatedResponse<ProductModel>>> getProductsByCategory(
    @Path('id') String categoryId,
    @Queries() Map<String, dynamic> queries,
  );
}
```

---

## Step 4: Create Product Local Data Source

**File:** `lib/features/products/data/datasources/product_local_datasource.dart`

```dart
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

class ProductLocalDataSource {
  static const String _productsBoxName = 'products_cache';
  static const String _categoriesBoxName = 'categories_cache';
  static const String _featuredBoxName = 'featured_products_cache';
  static const String _trendingBoxName = 'trending_products_cache';
  static const String _lastSyncKey = 'last_sync_timestamp';

  // Products Cache
  Future<void> cacheProducts(List<ProductModel> products) async {
    final box = await Hive.openBox<ProductModel>(_productsBoxName);
    for (final product in products) {
      await box.put(product.id, product);
    }
  }

  Future<void> cacheProduct(ProductModel product) async {
    final box = await Hive.openBox<ProductModel>(_productsBoxName);
    await box.put(product.id, product);
  }

  Future<ProductModel?> getCachedProduct(String id) async {
    final box = await Hive.openBox<ProductModel>(_productsBoxName);
    return box.get(id);
  }

  Future<List<ProductModel>> getCachedProducts() async {
    final box = await Hive.openBox<ProductModel>(_productsBoxName);
    return box.values.toList();
  }

  Future<List<ProductModel>> getCachedProductsByCategory(String categoryId) async {
    final box = await Hive.openBox<ProductModel>(_productsBoxName);
    return box.values.where((p) => p.categoryId == categoryId).toList();
  }

  // Categories Cache
  Future<void> cacheCategories(List<CategoryModel> categories) async {
    final box = await Hive.openBox<CategoryModel>(_categoriesBoxName);
    for (final category in categories) {
      await box.put(category.id, category);
    }
  }

  Future<List<CategoryModel>> getCachedCategories() async {
    final box = await Hive.openBox<CategoryModel>(_categoriesBoxName);
    return box.values.toList();
  }

  // Featured Products Cache
  Future<void> cacheFeaturedProducts(List<ProductModel> products) async {
    final box = await Hive.openBox<ProductModel>(_featuredBoxName);
    await box.clear();
    for (final product in products) {
      await box.put(product.id, product);
    }
  }

  Future<List<ProductModel>> getCachedFeaturedProducts() async {
    final box = await Hive.openBox<ProductModel>(_featuredBoxName);
    return box.values.toList();
  }

  // Trending Products Cache
  Future<void> cacheTrendingProducts(List<ProductModel> products) async {
    final box = await Hive.openBox<ProductModel>(_trendingBoxName);
    await box.clear();
    for (final product in products) {
      await box.put(product.id, product);
    }
  }

  Future<List<ProductModel>> getCachedTrendingProducts() async {
    final box = await Hive.openBox<ProductModel>(_trendingBoxName);
    return box.values.toList();
  }

  // Sync Timestamp
  Future<void> setLastSync(DateTime timestamp) async {
    final box = await Hive.openBox<String>('metadata');
    await box.put(_lastSyncKey, timestamp.toIso8601String());
  }

  Future<DateTime?> getLastSync() async {
    final box = await Hive.openBox<String>('metadata');
    final timestamp = box.get(_lastSyncKey);
    if (timestamp != null) {
      return DateTime.tryParse(timestamp);
    }
    return null;
  }

  // Clear all caches
  Future<void> clearAll() async {
    await Hive.deleteBoxFromDisk(_productsBoxName);
    await Hive.deleteBoxFromDisk(_categoriesBoxName);
    await Hive.deleteBoxFromDisk(_featuredBoxName);
    await Hive.deleteBoxFromDisk(_trendingBoxName);
  }
}
```

---

## Step 5: Create Product Repository

**File:** `lib/features/products/data/repositories/product_repository_impl.dart`

```dart
import '../../../../core/api/api_exceptions.dart';
import '../../../../core/api/api_response.dart';
import '../../../../core/api/pagination.dart';
import '../../../../core/repositories/base_repository.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';
import '../datasources/product_local_datasource.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/product_filter.dart';

class ProductRepositoryImpl extends BaseRepository implements ProductRepository {
  final ProductRemoteDataSource _remote;
  final ProductLocalDataSource _local;

  ProductRepositoryImpl({
    required ProductRemoteDataSource remote,
    required ProductLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  @override
  Future<PaginatedResponse<ProductModel>> getProducts({
    ProductFilter? filter,
  }) async {
    final queries = filter?.toQueryParameters() ?? {};
    
    return handleRequest(
      request: () async {
        final response = await _remote.getProducts(queries);
        final result = parseResponse(response);
        
        // Cache products
        await _local.cacheProducts(result.items);
        await _local.setLastSync(DateTime.now());
        
        return result;
      },
      fallback: PaginatedResponse<ProductModel>(
        items: await _local.getCachedProducts(),
        pagination: PaginationData(
          page: 1,
          limit: 20,
          total: 0,
          totalPages: 1,
          hasNext: false,
          hasPrev: false,
        ),
      ),
    );
  }

  @override
  Future<ProductModel?> getProductById(String id) async {
    return handleRequest(
      request: () async {
        final response = await _remote.getProductById(id);
        final product = parseResponse(response);
        await _local.cacheProduct(product);
        return product;
      },
      fallback: await _local.getCachedProduct(id),
    );
  }

  @override
  Future<List<ProductModel>> getFeaturedProducts() async {
    return handleRequest(
      request: () async {
        final response = await _remote.getFeaturedProducts();
        final products = parseResponse(response);
        await _local.cacheFeaturedProducts(products);
        return products;
      },
      fallback: await _local.getCachedFeaturedProducts(),
    );
  }

  @override
  Future<List<ProductModel>> getTrendingProducts() async {
    return handleRequest(
      request: () async {
        final response = await _remote.getTrendingProducts();
        final products = parseResponse(response);
        await _local.cacheTrendingProducts(products);
        return products;
      },
      fallback: await _local.getCachedTrendingProducts(),
    );
  }

  @override
  Future<PaginatedResponse<ProductModel>> searchProducts(
    String query, {
    ProductFilter? filter,
  }) async {
    final queries = filter?.toQueryParameters() ?? {};
    
    return handleRequest(
      request: () async {
        final response = await _remote.searchProducts(query, queries);
        return parseResponse(response);
      },
      fallback: PaginatedResponse<ProductModel>(
        items: [],
        pagination: PaginationData(
          page: 1,
          limit: 20,
          total: 0,
          totalPages: 1,
          hasNext: false,
          hasPrev: false,
        ),
      ),
    );
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    return handleRequest(
      request: () async {
        final response = await _remote.getCategories();
        final categories = parseResponse(response);
        await _local.cacheCategories(categories);
        return categories;
      },
      fallback: await _local.getCachedCategories(),
    );
  }

  @override
  Future<PaginatedResponse<ProductModel>> getProductsByCategory(
    String categoryId, {
    ProductFilter? filter,
  }) async {
    final queries = (filter ?? ProductFilter()).toQueryParameters();
    
    return handleRequest(
      request: () async {
        final response = await _remote.getProductsByCategory(categoryId, queries);
        return parseResponse(response);
      },
      fallback: PaginatedResponse<ProductModel>(
        items: await _local.getCachedProductsByCategory(categoryId),
        pagination: PaginationData(
          page: 1,
          limit: 20,
          total: 0,
          totalPages: 1,
          hasNext: false,
          hasPrev: false,
        ),
      ),
    );
  }

  @override
  Future<void> clearCache() async {
    await _local.clearAll();
  }
}
```

---

## Step 6: Create Domain Repository Interface

**File:** `lib/features/products/domain/repositories/product_repository.dart`

```dart
import '../../data/models/product_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/product_filter.dart';
import '../../../../core/api/pagination.dart';

abstract class ProductRepository {
  Future<PaginatedResponse<ProductModel>> getProducts({
    ProductFilter? filter,
  });
  
  Future<ProductModel?> getProductById(String id);
  
  Future<List<ProductModel>> getFeaturedProducts();
  
  Future<List<ProductModel>> getTrendingProducts();
  
  Future<PaginatedResponse<ProductModel>> searchProducts(
    String query, {
    ProductFilter? filter,
  });
  
  Future<List<CategoryModel>> getCategories();
  
  Future<PaginatedResponse<ProductModel>> getProductsByCategory(
    String categoryId, {
    ProductFilter? filter,
  });
  
  Future<void> clearCache();
}
```

---

## Step 7: Update ProductsCubit

**File:** `lib/features/products/presentation/bloc/products_cubit.dart`

```dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/product_model.dart';
import '../../data/models/product_filter.dart';
import '../../domain/repositories/product_repository.dart';

part 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  final ProductRepository _repository;
  ProductFilter _currentFilter = ProductFilter();
  
  ProductsCubit({required ProductRepository repository})
      : _repository = repository,
        super(const ProductsState.initial());

  Future<void> loadProducts({bool refresh = false}) async {
    if (state.isLoading && !refresh) return;
    
    try {
      emit(ProductsState.loading(
        products: refresh ? [] : state.products,
      ));
      
      final response = await _repository.getProducts(filter: _currentFilter);
      
      emit(ProductsState.loaded(
        products: response.items,
        hasMore: response.pagination.hasNext,
        page: response.pagination.page,
      ));
    } catch (e) {
      emit(ProductsState.error(
        message: _mapErrorToMessage(e),
        products: state.products,
      ));
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;
    
    try {
      emit(state.copyWith(isLoadingMore: true));
      
      _currentFilter = _currentFilter.copyWith(
        page: (state.page ?? 1) + 1,
      );
      
      final response = await _repository.getProducts(filter: _currentFilter);
      
      emit(ProductsState.loaded(
        products: [...state.products, ...response.items],
        hasMore: response.pagination.hasNext,
        page: response.pagination.page,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingMore: false,
        errorMessage: _mapErrorToMessage(e),
      ));
    }
  }

  Future<void> refresh() async {
    _currentFilter = ProductFilter();
    await loadProducts(refresh: true);
  }

  Future<void> setCategory(String? categoryId) async {
    _currentFilter = _currentFilter.copyWith(
      category: categoryId,
      page: 1,
    );
    await loadProducts(refresh: true);
  }

  Future<void> setPriceRange(double? min, double? max) async {
    _currentFilter = _currentFilter.copyWith(
      minPrice: min,
      maxPrice: max,
      page: 1,
    );
    await loadProducts(refresh: true);
  }

  Future<void> setSortBy(String sortBy, {String order = 'asc'}) async {
    _currentFilter = _currentFilter.copyWith(
      sortBy: sortBy,
      order: order,
      page: 1,
    );
    await loadProducts(refresh: true);
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      _currentFilter = _currentFilter.copyWith(search: null);
      await loadProducts(refresh: true);
      return;
    }
    
    _currentFilter = _currentFilter.copyWith(
      search: query,
      page: 1,
    );
    await loadProducts(refresh: true);
  }

  String _mapErrorToMessage(dynamic error) {
    // Map specific errors to user-friendly messages
    if (error.toString().contains('NO_CONNECTION')) {
      return 'Pas de connexion internet';
    }
    return 'Erreur de chargement. Réessayez.';
  }
}
```

**File:** `lib/features/products/presentation/bloc/products_state.dart`

```dart
part of 'products_cubit.dart';

class ProductsState extends Equatable {
  final List<ProductModel> products;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final bool hasMore;
  final int? page;

  const ProductsState({
    this.products = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.hasMore = true,
    this.page,
  });

  const ProductsState.initial() : this();

  ProductsState.loading({List<ProductModel>? products})
      : this(
          isLoading: true,
          products: products ?? const [],
        );

  ProductsState.loaded({
    required List<ProductModel> products,
    required bool hasMore,
    required int page,
  }) : this(
          products: products,
          hasMore: hasMore,
          page: page,
        );

  ProductsState.error({
    required String message,
    List<ProductModel>? products,
  }) : this(
          errorMessage: message,
          products: products ?? const [],
        );

  ProductsState copyWith({
    List<ProductModel>? products,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    bool? hasMore,
    int? page,
  }) {
    return ProductsState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
    );
  }

  @override
  List<Object?> get props => [
        products,
        isLoading,
        isLoadingMore,
        errorMessage,
        hasMore,
        page,
      ];
}
```

---

## Step 8: Register Hive Adapters

Update `main.dart` to register new Hive adapters:

```dart
Future<void> _initHive() async {
  await Hive.initFlutter();
  
  // Existing adapters...
  
  // Register Product and Category adapters
  // You'll need to generate these with @HiveType
  // Or use json_serializable for simple caching
}
```

---

## Checklist

- [ ] ProductModel DTO created with multi-language support
- [ ] CategoryModel DTO created
- [ ] ProductFilter model created
- [ ] Code generation run
- [ ] ProductRemoteDataSource created with Retrofit
- [ ] ProductLocalDataSource implemented with Hive
- [ ] ProductRepositoryImpl created
- [ ] Domain repository interface defined
- [ ] ProductsCubit updated with pagination
- [ ] ProductsState updated with loading states
- [ ] Dependency injection updated
- [ ] Hive adapters registered (if using HiveType)

---

## Testing

### Unit Tests

```dart
void main() {
  group('ProductRepository', () {
    test('should return cached products when offline', () async {
      // Test implementation
    });
    
    test('should cache products after API fetch', () async {
      // Test implementation
    });
  });
}
```

---

## Next Phase

➡️ [Phase 4: User Features](./04-user-features.md)
