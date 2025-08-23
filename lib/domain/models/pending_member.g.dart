// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PendingMemberImpl _$$PendingMemberImplFromJson(Map<String, dynamic> json) =>
    _$PendingMemberImpl(
      id: json['id'] as String,
      inviteId: json['inviteId'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      invitedAt: DateTime.parse(json['invitedAt'] as String),
      role: json['role'] as String? ?? 'child',
      familyId: json['familyId'] as String,
      invitedByUid: json['invitedByUid'] as String,
      reminderSent: json['reminderSent'] as bool? ?? false,
      lastReminderSentAt: json['lastReminderSentAt'] == null
          ? null
          : DateTime.parse(json['lastReminderSentAt'] as String),
      reminderCount: (json['reminderCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$PendingMemberImplToJson(_$PendingMemberImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'inviteId': instance.inviteId,
      'email': instance.email,
      'displayName': instance.displayName,
      'invitedAt': instance.invitedAt.toIso8601String(),
      'role': instance.role,
      'familyId': instance.familyId,
      'invitedByUid': instance.invitedByUid,
      'reminderSent': instance.reminderSent,
      'lastReminderSentAt': instance.lastReminderSentAt?.toIso8601String(),
      'reminderCount': instance.reminderCount,
    };
