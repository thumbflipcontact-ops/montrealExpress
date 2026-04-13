import 'package:hive/hive.dart';

part 'delivery_method.g.dart';

@HiveType(typeId: 4)
enum DeliveryType {
  @HiveField(0)
  standard,
  @HiveField(1)
  express,
  @HiveField(2)
  pickup,
}

@HiveType(typeId: 5)
class DeliveryMethod extends HiveObject {
  @HiveField(0)
  final DeliveryType type;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final double cost;
  @HiveField(3)
  final int estimatedHours;
  @HiveField(4)
  final bool isAvailable;
  @HiveField(5)
  final String? description;

  DeliveryMethod({
    required this.type,
    required this.name,
    required this.cost,
    required this.estimatedHours,
    required this.isAvailable,
    this.description,
  });

  String get displayName => name;
  String get estimatedTime => '$estimatedHours heures';
  String get costDisplay => '${cost.toStringAsFixed(0)} F';

  DeliveryMethod copyWith({
    DeliveryType? type,
    String? name,
    double? cost,
    int? estimatedHours,
    bool? isAvailable,
    String? description,
  }) {
    return DeliveryMethod(
      type: type ?? this.type,
      name: name ?? this.name,
      cost: cost ?? this.cost,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      isAvailable: isAvailable ?? this.isAvailable,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'name': name,
      'cost': cost,
      'estimatedHours': estimatedHours,
      'isAvailable': isAvailable,
      'description': description,
    };
  }

  factory DeliveryMethod.fromJson(Map<String, dynamic> json) {
    return DeliveryMethod(
      type: DeliveryType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => DeliveryType.standard,
      ),
      name: json['name'],
      cost: (json['cost'] as num).toDouble(),
      estimatedHours: json['estimatedHours'],
      isAvailable: json['isAvailable'],
      description: json['description'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeliveryMethod &&
        other.type == type &&
        other.name == name &&
        other.cost == cost &&
        other.estimatedHours == estimatedHours &&
        other.isAvailable == isAvailable &&
        other.description == description;
  }

  @override
  int get hashCode {
    return type.hashCode ^
        name.hashCode ^
        cost.hashCode ^
        estimatedHours.hashCode ^
        isAvailable.hashCode ^
        description.hashCode;
  }

  @override
  String toString() {
    return 'DeliveryMethod(type: $type, name: $name, cost: $cost, estimatedHours: $estimatedHours, isAvailable: $isAvailable, description: $description)';
  }
}

// Predefined delivery methods
List<DeliveryMethod> get standardDeliveryMethods => [
  DeliveryMethod(
    type: DeliveryType.standard,
    name: 'Livraison Standard',
    cost: 1000,
    estimatedHours: 24,
    isAvailable: true,
    description: 'Livraison dans les 24 heures',
  ),
  DeliveryMethod(
    type: DeliveryType.express,
    name: 'Livraison Express',
    cost: 2500,
    estimatedHours: 4,
    isAvailable: true,
    description: 'Livraison dans les 4 heures',
  ),
  DeliveryMethod(
    type: DeliveryType.pickup,
    name: 'Retrait Magasin',
    cost: 0,
    estimatedHours: 0,
    isAvailable: true,
    description: 'Retrait gratuit en magasin',
  ),
];