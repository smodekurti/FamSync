// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_invite.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FamilyInviteImpl _$$FamilyInviteImplFromJson(Map<String, dynamic> json) =>
    _$FamilyInviteImpl(
      id: json['id'] as String,
      familyId: json['familyId'] as String,
      inviteCode: json['inviteCode'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      createdByUid: json['createdByUid'] as String,
      status:
          $enumDecodeNullable(_$InviteStatusEnumMap, json['status']) ??
          InviteStatus.active,
      acceptedByUid: json['acceptedByUid'] as String?,
      acceptedAt: json['acceptedAt'] == null
          ? null
          : DateTime.parse(json['acceptedAt'] as String),
      role: json['role'] as String? ?? 'child',
      maxUses: (json['maxUses'] as num?)?.toInt() ?? 1,
      useCount: (json['useCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$FamilyInviteImplToJson(_$FamilyInviteImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'familyId': instance.familyId,
      'inviteCode': instance.inviteCode,
      'createdAt': instance.createdAt.toIso8601String(),
      'expiresAt': instance.expiresAt.toIso8601String(),
      'createdByUid': instance.createdByUid,
      'status': _$InviteStatusEnumMap[instance.status]!,
      'acceptedByUid': instance.acceptedByUid,
      'acceptedAt': instance.acceptedAt?.toIso8601String(),
      'role': instance.role,
      'maxUses': instance.maxUses,
      'useCount': instance.useCount,
    };

const _$InviteStatusEnumMap = {
  InviteStatus.active: 'active',
  InviteStatus.accepted: 'accepted',
  InviteStatus.expired: 'expired',
  InviteStatus.revoked: 'revoked',
};
