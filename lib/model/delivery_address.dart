import 'package:hive/hive.dart';

part 'delivery_address.g.dart';

@HiveType(typeId: 3)
class DeliveryAddress extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String phone;
  @HiveField(3)
  final String address;
  @HiveField(4)
  final String? city;
  @HiveField(5)
  final String? postalCode;
  @HiveField(6)
  final String? country;
  @HiveField(7)
  final bool isDefault;
  @HiveField(8)
  final DateTime createdAt;
  @HiveField(9)
  final DateTime? updatedAt;

  DeliveryAddress({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    this.city,
    this.postalCode,
    this.country = 'Niger',
    this.isDefault = false,
    required this.createdAt,
    this.updatedAt,
  });

  // Convenience constructor for creating new addresses
  factory DeliveryAddress.create({
    required String name,
    required String phone,
    required String address,
    String? city,
    String? postalCode,
    String? country,
    bool isDefault = false,
  }) {
    return DeliveryAddress(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      phone: phone,
      address: address,
      city: city,
      postalCode: postalCode,
      country: country ?? 'Niger',
      isDefault: isDefault,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  String get fullAddress {
    final parts = [address];
    if (city != null) parts.add(city!);
    if (postalCode != null) parts.add(postalCode!);
    if (country != null) parts.add(country!);
    return parts.join(', ');
  }

  DeliveryAddress copyWith({
    String? id,
    String? name,
    String? phone,
    String? address,
    String? city,
    String? postalCode,
    String? country,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DeliveryAddress(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'city': city,
      'postalCode': postalCode,
      'country': country,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      address: json['address'],
      city: json['city'],
      postalCode: json['postalCode'],
      country: json['country'] ?? 'Niger',
      isDefault: json['isDefault'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeliveryAddress &&
        other.name == name &&
        other.phone == phone &&
        other.address == address &&
        other.city == city &&
        other.postalCode == postalCode &&
        other.country == country;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        phone.hashCode ^
        address.hashCode ^
        city.hashCode ^
        postalCode.hashCode ^
        country.hashCode;
  }

  @override
  String toString() {
    return 'DeliveryAddress(name: $name, phone: $phone, address: $address, city: $city, postalCode: $postalCode, country: $country)';
  }
}