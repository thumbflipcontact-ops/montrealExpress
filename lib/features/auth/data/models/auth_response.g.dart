// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String?,
    );

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'user': instance.user,
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
    };

GuestResponse _$GuestResponseFromJson(Map<String, dynamic> json) =>
    GuestResponse(
      sessionId: json['sessionId'] as String,
      accessToken: json['accessToken'] as String,
    );

Map<String, dynamic> _$GuestResponseToJson(GuestResponse instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'accessToken': instance.accessToken,
    };
