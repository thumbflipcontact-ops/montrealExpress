class Promotion {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String? imageAsset;
  final PromotionType type;
  final double discountValue;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> productIds;
  final String? promoCode;
  final int? minimumOrder;
  final String? category;

  Promotion({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.imageAsset,
    required this.type,
    required this.discountValue,
    required this.startDate,
    required this.endDate,
    this.productIds = const [],
    this.promoCode,
    this.minimumOrder,
    this.category,
  });
}

enum PromotionType {
  percentage,
  fixedAmount,
  buyOneGetOne,
  freeShipping,
}