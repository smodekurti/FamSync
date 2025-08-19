// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileImpl _$$UserProfileImplFromJson(
  Map<String, dynamic> json,
) => _$UserProfileImpl(
  uid: json['uid'] as String,
  displayName: json['displayName'] as String,
  email: json['email'] as String,
  photoUrl: json['photoUrl'] as String?,
  familyId: json['familyId'] as String?,
  role: $enumDecodeNullable(_$UserRoleEnumMap, json['role']) ?? UserRole.parent,
  onboarded: json['onboarded'] as bool? ?? false,
);

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'displayName': instance.displayName,
      'email': instance.email,
      'photoUrl': instance.photoUrl,
      'familyId': instance.familyId,
      'role': _$UserRoleEnumMap[instance.role]!,
      'onboarded': instance.onboarded,
    };

const _$UserRoleEnumMap = {UserRole.parent: 'parent', UserRole.child: 'child'};
