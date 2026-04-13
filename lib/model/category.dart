import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

/// Category model matching backend schema
@JsonSerializable()
class Category {
  final String id;
  final String name;
  final String? description;
  final String? image;
  final String? icon;
  final String? parentId;
  final int order;
  final bool isActive;
  final int productCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  // For tree structure
  final List<Category>? children;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.image,
    this.icon,
    this.parentId,
    this.order = 0,
    this.isActive = true,
    this.productCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.children,
  });

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);

  /// Check if category has children
  bool get hasChildren => children != null && children!.isNotEmpty;

  /// Check if category is a root category (no parent)
  bool get isRoot => parentId == null;

  /// Backward compatibility - get subcategories
  List<Subcategory> get subcategories {
    if (children == null) return [];
    return children!
        .map((child) => Subcategory(
              id: child.id,
              name: child.name,
              imageUrl: child.image,
              imageAsset: null,
              productCount: child.productCount,
            ))
        .toList();
  }

  /// Backward compatibility - image URL
  String? get imageUrl => image;
  String? get imageAsset => null; // Legacy field, always null

  /// Backward compatibility - featured products (empty for now)
  List<String> get featuredProductIds => [];

  Category copyWith({
    String? id,
    String? name,
    String? description,
    String? image,
    String? icon,
    String? parentId,
    int? order,
    bool? isActive,
    int? productCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Category>? children,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      icon: icon ?? this.icon,
      parentId: parentId ?? this.parentId,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
      productCount: productCount ?? this.productCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      children: children ?? this.children,
    );
  }
}

/// Subcategory class for backward compatibility
class Subcategory {
  final String id;
  final String name;
  final String? imageUrl;
  final String? imageAsset;
  final int productCount;

  Subcategory({
    required this.id,
    required this.name,
    this.imageUrl,
    this.imageAsset,
    required this.productCount,
  });
}
