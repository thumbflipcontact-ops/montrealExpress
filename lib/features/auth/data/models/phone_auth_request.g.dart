// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phone_auth_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PhoneAuthInitiateRequest _$PhoneAuthInitiateRequestFromJson(
        Map<String, dynamic> json) =>
    PhoneAuthInitiateRequest(
      phoneNumber: json['phoneNumber'] as String,
    );

Map<String, dynamic> _$PhoneAuthInitiateRequestToJson(
        PhoneAuthInitiateRequest instance) =>
    <String, dynamic>{
      'phoneNumber': instance.phoneNumber,
    };

PhoneAuthVerifyRequest _$PhoneAuthVerifyRequestFromJson(
        Map<String, dynamic> json) =>
    PhoneAuthVerifyRequest(
      phoneNumber: json['phoneNumber'] as String,
      otpCode: json['otpCode'] as String,
    );

Map<String, dynamic> _$PhoneAuthVerifyRequestToJson(
        PhoneAuthVerifyRequest instance) =>
    <String, dynamic>{
      'phoneNumber': instance.phoneNumber,
      'otpCode': instance.otpCode,
    };

PhoneAuthInitiateResponse _$PhoneAuthInitiateResponseFromJson(
        Map<String, dynamic> json) =>
    PhoneAuthInitiateResponse(
      message: json['message'] as String,
      expiresIn: (json['expiresIn'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PhoneAuthInitiateResponseToJson(
        PhoneAuthInitiateResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'expiresIn': instance.expiresIn,
    };
