import 'package:json_annotation/json_annotation.dart';

part 'product.g.dart';

/// Product model matching backend schema
@JsonSerializable()
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? sku;
  final int stock;
  final double? discount; // Discount percentage (0-100)
  final List<String> images;
  final String? categoryId;
  final String? categoryName; // For display purposes
  final double rating; // Average rating (0-5)
  final int reviewCount;
  final bool featured;
  final bool trending;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.sku,
    required this.stock,
    this.discount,
    required this.images,
    this.categoryId,
    this.categoryName,
    required this.rating,
    required this.reviewCount,
    required this.featured,
    required this.trending,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  Map<String, dynamic> toJson() => _$ProductToJson(this);

  // Computed properties

  /// Get final price after discount
  double get finalPrice {
    if (discount != null && discount! > 0) {
      return price * (1 - discount! / 100);
    }
    return price;
  }

  /// Check if product has discount
  bool get hasDiscount => discount != null && discount! > 0;

  /// Check if product is in stock
  bool get inStock => stock > 0;

  /// Get first image or null
  String? get imageUrl => images.isNotEmpty ? images.first : null;

  /// Backward compatibility with old code
  String get title => name; // Alias for name
  String get category => categoryName ?? ''; // Alias for categoryName
  String? get imageAsset => null; // Legacy field, always null now

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? sku,
    int? stock,
    double? discount,
    List<String>? images,
    String? categoryId,
    String? categoryName,
    double? rating,
    int? reviewCount,
    bool? featured,
    bool? trending,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      sku: sku ?? this.sku,
      stock: stock ?? this.stock,
      discount: discount ?? this.discount,
      images: images ?? this.images,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      featured: featured ?? this.featured,
      trending: trending ?? this.trending,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Product review model
@JsonSerializable()
class ProductReview {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final int rating; // 1-5
  final String? comment;
  final DateTime createdAt;

  ProductReview({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory ProductReview.fromJson(Map<String, dynamic> json) =>
      _$ProductReviewFromJson(json);

  Map<String, dynamic> toJson() => _$ProductReviewToJson(this);
}
