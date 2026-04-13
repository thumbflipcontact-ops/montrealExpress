import 'package:abdoul_express/model/product.dart';

/// Mock products for testing
class MockProducts {
  static final product1 = Product(
    id: 'test-prod-1',
    name: 'Test Cosmetic Product',
    description: 'A high-quality cosmetic product for testing',
    price: 10000,
    stock: 50,
    images: ['assets/products/cosmetic.jpg'],
    categoryId: 'cat-cosmetics',
    categoryName: 'Cosmetics',
    rating: 4.5,
    reviewCount: 12,
    featured: false,
    trending: false,
    isActive: true,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  static final product2 = Product(
    id: 'test-prod-2',
    name: 'Test Children Bag',
    description: 'A colorful bag for children',
    price: 15000,
    stock: 30,
    images: ['assets/products/bag.jpg'],
    categoryId: 'cat-bags',
    categoryName: "Children's Bags",
    rating: 4.8,
    reviewCount: 25,
    featured: true,
    trending: false,
    isActive: true,
    createdAt: DateTime(2024, 1, 2),
    updatedAt: DateTime(2024, 1, 2),
  );

  static final product3 = Product(
    id: 'test-prod-3',
    name: 'Test Accessory',
    description: 'An elegant accessory',
    price: 8000,
    stock: 100,
    images: ['assets/products/accessory.jpg'],
    categoryId: 'cat-accessories',
    categoryName: 'Accessories',
    rating: 4.2,
    reviewCount: 8,
    featured: false,
    trending: true,
    isActive: true,
    createdAt: DateTime(2024, 1, 3),
    updatedAt: DateTime(2024, 1, 3),
  );

  static final product4 = Product(
    id: 'test-prod-4',
    name: 'Test Electronics',
    description: 'Latest electronic gadget',
    price: 50000,
    stock: 15,
    discount: 10.0, // 10% discount
    images: ['assets/products/electronics.jpg'],
    categoryId: 'cat-electronics',
    categoryName: 'Electronics',
    rating: 4.6,
    reviewCount: 42,
    featured: true,
    trending: true,
    isActive: true,
    createdAt: DateTime(2024, 1, 4),
    updatedAt: DateTime(2024, 1, 4),
  );

  static final outOfStockProduct = Product(
    id: 'test-prod-5',
    name: 'Out of Stock Product',
    description: 'This product is out of stock',
    price: 25000,
    stock: 0, // Out of stock
    images: ['assets/products/fashion.jpg'],
    categoryId: 'cat-fashion',
    categoryName: 'Fashion',
    rating: 4.0,
    reviewCount: 5,
    featured: false,
    trending: false,
    isActive: true,
    createdAt: DateTime(2024, 1, 5),
    updatedAt: DateTime(2024, 1, 5),
  );

  static final expensiveProduct = Product(
    id: 'test-prod-6',
    name: 'Expensive Luxury Item',
    description: 'A premium luxury product',
    price: 100000,
    stock: 5,
    images: ['assets/products/luxury.jpg'],
    categoryId: 'cat-accessories',
    categoryName: 'Accessories',
    rating: 5.0,
    reviewCount: 3,
    featured: true,
    trending: false,
    isActive: true,
    createdAt: DateTime(2024, 1, 6),
    updatedAt: DateTime(2024, 1, 6),
  );

  static final cheapProduct = Product(
    id: 'test-prod-7',
    name: 'Budget Friendly Item',
    description: 'An affordable option',
    price: 2000,
    stock: 200,
    discount: 5.0, // 5% discount
    images: ['assets/products/budget.jpg'],
    categoryId: 'cat-cosmetics',
    categoryName: 'Cosmetics',
    rating: 3.5,
    reviewCount: 18,
    featured: false,
    trending: false,
    isActive: true,
    createdAt: DateTime(2024, 1, 7),
    updatedAt: DateTime(2024, 1, 7),
  );

  /// Get all mock products
  static List<Product> get allProducts => [
        product1,
        product2,
        product3,
        product4,
        outOfStockProduct,
        expensiveProduct,
        cheapProduct,
      ];

  /// Get products by category
  static List<Product> getByCategory(String category) {
    return allProducts.where((p) => p.category == category).toList();
  }

  /// Get products by price range
  static List<Product> getByPriceRange(double min, double max) {
    return allProducts
        .where((p) => p.price >= min && p.price <= max)
        .toList();
  }

  /// Get products by rating
  static List<Product> getByMinRating(double minRating) {
    return allProducts.where((p) => p.rating >= minRating).toList();
  }

  /// Get in-stock products
  static List<Product> get inStockProducts =>
      allProducts.where((p) => p.inStock).toList();

  /// Get featured products
  static List<Product> get featuredProducts =>
      allProducts.where((p) => p.featured).toList();

  /// Get trending products
  static List<Product> get trendingProducts =>
      allProducts.where((p) => p.trending).toList();

  /// Get products with discount
  static List<Product> get discountedProducts =>
      allProducts.where((p) => p.hasDiscount).toList();
}
