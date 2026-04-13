import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';

part 'auth_response.g.dart';

/// Response model for authentication endpoints (login, register, phone verify)
/// Backend returns: { success, message, data: { user, accessToken } }
/// The parseResponse() method unwraps the data layer before fromJson is called.
@JsonSerializable()
class AuthResponse {
  final UserModel user;
  final String accessToken;
  // Backend does not send refreshToken on login/register — nullable for safety
  final String? refreshToken;

  AuthResponse({
    required this.user,
    required this.accessToken,
    this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

/// Response for guest session
@JsonSerializable()
class GuestResponse {
  final String sessionId;
  final String accessToken;

  GuestResponse({
    required this.sessionId,
    required this.accessToken,
  });

  factory GuestResponse.fromJson(Map<String, dynamic> json) =>
      _$GuestResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GuestResponseToJson(this);
}
