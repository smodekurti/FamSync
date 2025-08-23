// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FamilyImpl _$$FamilyImplFromJson(Map<String, dynamic> json) => _$FamilyImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  memberUids:
      (json['memberUids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  roles:
      (json['roles'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
  colors:
      (json['colors'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
  inviteCode: json['inviteCode'] as String?,
  maxMembers: (json['maxMembers'] as num?)?.toInt() ?? 10,
  allowInvites: json['allowInvites'] as bool? ?? true,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  ownerUid: json['ownerUid'] as String? ?? '',
  nameNormalized: json['nameNormalized'] as String?,
);

Map<String, dynamic> _$$FamilyImplToJson(_$FamilyImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'memberUids': instance.memberUids,
      'roles': instance.roles,
      'colors': instance.colors,
      'inviteCode': instance.inviteCode,
      'maxMembers': instance.maxMembers,
      'allowInvites': instance.allowInvites,
      'createdAt': instance.createdAt?.toIso8601String(),
      'ownerUid': instance.ownerUid,
      'nameNormalized': instance.nameNormalized,
    };
