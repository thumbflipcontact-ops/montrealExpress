import 'package:json_annotation/json_annotation.dart';

part 'phone_auth_request.g.dart';

/// Request to initiate phone authentication (send OTP)
/// Matches backend InitiatePhoneAuthDto: phoneNumber*
@JsonSerializable()
class PhoneAuthInitiateRequest {
  final String phoneNumber;

  PhoneAuthInitiateRequest({
    required this.phoneNumber,
  });

  factory PhoneAuthInitiateRequest.fromJson(Map<String, dynamic> json) =>
      _$PhoneAuthInitiateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PhoneAuthInitiateRequestToJson(this);
}

/// Request to verify OTP for phone authentication
/// Matches backend VerifySMSOTPDto: phoneNumber*, otpCode*
@JsonSerializable()
class PhoneAuthVerifyRequest {
  final String phoneNumber;
  final String otpCode;

  PhoneAuthVerifyRequest({
    required this.phoneNumber,
    required this.otpCode,
  });

  factory PhoneAuthVerifyRequest.fromJson(Map<String, dynamic> json) =>
      _$PhoneAuthVerifyRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PhoneAuthVerifyRequestToJson(this);
}

/// Response after OTP initiation
@JsonSerializable()
class PhoneAuthInitiateResponse {
  final String message;
  final int? expiresIn;

  PhoneAuthInitiateResponse({
    required this.message,
    this.expiresIn,
  });

  factory PhoneAuthInitiateResponse.fromJson(Map<String, dynamic> json) =>
      _$PhoneAuthInitiateResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PhoneAuthInitiateResponseToJson(this);
}
