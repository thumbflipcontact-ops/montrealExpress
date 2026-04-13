// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'password_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChangePasswordRequest _$ChangePasswordRequestFromJson(
        Map<String, dynamic> json) =>
    ChangePasswordRequest(
      currentPassword: json['currentPassword'] as String,
      newPassword: json['newPassword'] as String,
    );

Map<String, dynamic> _$ChangePasswordRequestToJson(
        ChangePasswordRequest instance) =>
    <String, dynamic>{
      'currentPassword': instance.currentPassword,
      'newPassword': instance.newPassword,
    };

ForgotPasswordRequest _$ForgotPasswordRequestFromJson(
        Map<String, dynamic> json) =>
    ForgotPasswordRequest(
      email: json['email'] as String,
    );

Map<String, dynamic> _$ForgotPasswordRequestToJson(
        ForgotPasswordRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
    };

VerifyResetOtpRequest _$VerifyResetOtpRequestFromJson(
        Map<String, dynamic> json) =>
    VerifyResetOtpRequest(
      email: json['email'] as String,
      otp: json['otp'] as String,
      newPassword: json['newPassword'] as String,
    );

Map<String, dynamic> _$VerifyResetOtpRequestToJson(
        VerifyResetOtpRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'otp': instance.otp,
      'newPassword': instance.newPassword,
    };

PasswordOperationResponse _$PasswordOperationResponseFromJson(
        Map<String, dynamic> json) =>
    PasswordOperationResponse(
      message: json['message'] as String,
    );

Map<String, dynamic> _$PasswordOperationResponseToJson(
        PasswordOperationResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
    };
