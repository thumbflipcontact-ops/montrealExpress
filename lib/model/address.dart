import 'package:hive/hive.dart';

part 'address.g.dart';

@HiveType(typeId: 14)
class Address extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String userId;
  @HiveField(2)
  final String name;
  @HiveField(3)
  final String phone;
  @HiveField(4)
  final String street;
  @HiveField(5)
  final String city;
  @HiveField(6)
  final String? postalCode;
  @HiveField(7)
  final String country;
  @HiveField(8)
  final bool isDefault;
  @HiveField(9)
  final String? additionalInfo;
  @HiveField(10)
  final DateTime createdAt;
  @HiveField(11)
  final DateTime? updatedAt;
  @HiveField(12)
  final bool isSynced;

  Address({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    required this.street,
    required this.city,
    this.postalCode,
    required this.country,
    this.isDefault = false,
    this.additionalInfo,
    required this.createdAt,
    this.updatedAt,
    this.isSynced = false,
  });

  // Convenience constructor for creating new addresses
  factory Address.create({
    required String userId,
    required String name,
    required String phone,
    required String street,
    required String city,
    String? postalCode,
    String country = 'Niger',
    bool isDefault = false,
    String? additionalInfo,
  }) {
    return Address(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      name: name,
      phone: phone,
      street: street,
      city: city,
      postalCode: postalCode,
      country: country,
      isDefault: isDefault,
      additionalInfo: additionalInfo,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isSynced: false,
    );
  }

  Address copyWith({
    String? id,
    String? userId,
    String? name,
    String? phone,
    String? street,
    String? city,
    String? postalCode,
    String? country,
    bool? isDefault,
    String? additionalInfo,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return Address(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      street: street ?? this.street,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      isDefault: isDefault ?? this.isDefault,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  String get fullAddress {
    final parts = [street, city];
    if (postalCode != null && postalCode!.isNotEmpty) {
      parts.add(postalCode!);
    }
    parts.add(country);
    return parts.join(', ');
  }

  @override
  String toString() => fullAddress;

  // JSON serialization methods
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'phone': phone,
      'street': street,
      'city': city,
      'postalCode': postalCode,
      'country': country,
      'isDefault': isDefault,
      'additionalInfo': additionalInfo,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isSynced': isSynced,
    };
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      phone: json['phone'],
      street: json['street'],
      city: json['city'],
      postalCode: json['postalCode'],
      country: json['country'] ?? 'Niger',
      isDefault: json['isDefault'] ?? false,
      additionalInfo: json['additionalInfo'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      isSynced: json['isSynced'] ?? false,
    );
  }
}