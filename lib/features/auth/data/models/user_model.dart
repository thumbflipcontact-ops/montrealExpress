import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

/// User model matching backend User entity response
/// Fields: id, email, firstName, lastName, fullName, role, isActive, lastLogin
@JsonSerializable()
class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? fullName;
  final String? avatar;
  final bool isActive;
  final String role;
  final String? lastLogin;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.fullName,
    this.avatar,
    required this.isActive,
    required this.role,
    this.lastLogin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// Convenience getter: full display name
  String get displayName =>
      fullName?.isNotEmpty == true ? fullName! : '$firstName $lastName'.trim();

  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? fullName,
    String? avatar,
    bool? isActive,
    String? role,
    String? lastLogin,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fullName: fullName ?? this.fullName,
      avatar: avatar ?? this.avatar,
      isActive: isActive ?? this.isActive,
      role: role ?? this.role,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
