import 'package:json_annotation/json_annotation.dart';

part 'update_profile_request.g.dart';

/// Request to update user profile
/// Matches backend UpdateProfileDto: firstName?, lastName?, avatar?
@JsonSerializable(includeIfNull: false)
class UpdateProfileRequest {
  final String? firstName;
  final String? lastName;
  final String? avatar;

  UpdateProfileRequest({
    this.firstName,
    this.lastName,
    this.avatar,
  });

  factory UpdateProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateProfileRequestToJson(this);
}
