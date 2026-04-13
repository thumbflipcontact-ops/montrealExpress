import 'package:json_annotation/json_annotation.dart';

part 'password_request.g.dart';

/// Request to change password (for authenticated users)
@JsonSerializable()
class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;

  ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  factory ChangePasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ChangePasswordRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ChangePasswordRequestToJson(this);
}

/// Request to initiate forgot password (send OTP)
@JsonSerializable()
class ForgotPasswordRequest {
  final String email;

  ForgotPasswordRequest({
    required this.email,
  });

  factory ForgotPasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ForgotPasswordRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ForgotPasswordRequestToJson(this);
}

/// Request to verify OTP and reset password
@JsonSerializable()
class VerifyResetOtpRequest {
  final String email;
  final String otp;
  final String newPassword;

  VerifyResetOtpRequest({
    required this.email,
    required this.otp,
    required this.newPassword,
  });

  factory VerifyResetOtpRequest.fromJson(Map<String, dynamic> json) =>
      _$VerifyResetOtpRequestFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyResetOtpRequestToJson(this);
}

/// Response after password operations
@JsonSerializable()
class PasswordOperationResponse {
  final String message;

  PasswordOperationResponse({
    required this.message,
  });

  factory PasswordOperationResponse.fromJson(Map<String, dynamic> json) =>
      _$PasswordOperationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PasswordOperationResponseToJson(this);
}
