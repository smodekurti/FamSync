// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invite_validation_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InviteValidationResultImpl _$$InviteValidationResultImplFromJson(
  Map<String, dynamic> json,
) => _$InviteValidationResultImpl(
  isValid: json['isValid'] as bool,
  family: json['family'] == null
      ? null
      : Family.fromJson(json['family'] as Map<String, dynamic>),
  inviteId: json['inviteId'] as String?,
  errorMessage: json['errorMessage'] as String?,
  errorType: $enumDecodeNullable(
    _$InviteValidationErrorEnumMap,
    json['errorType'],
  ),
  isAlreadyMember: json['isAlreadyMember'] as bool? ?? false,
  isFamilyFull: json['isFamilyFull'] as bool? ?? false,
  isExpired: json['isExpired'] as bool? ?? false,
  isAlreadyUsed: json['isAlreadyUsed'] as bool? ?? false,
  isRevoked: json['isRevoked'] as bool? ?? false,
);

Map<String, dynamic> _$$InviteValidationResultImplToJson(
  _$InviteValidationResultImpl instance,
) => <String, dynamic>{
  'isValid': instance.isValid,
  'family': instance.family,
  'inviteId': instance.inviteId,
  'errorMessage': instance.errorMessage,
  'errorType': _$InviteValidationErrorEnumMap[instance.errorType],
  'isAlreadyMember': instance.isAlreadyMember,
  'isFamilyFull': instance.isFamilyFull,
  'isExpired': instance.isExpired,
  'isAlreadyUsed': instance.isAlreadyUsed,
  'isRevoked': instance.isRevoked,
};

const _$InviteValidationErrorEnumMap = {
  InviteValidationError.invalidCode: 'invalidCode',
  InviteValidationError.expired: 'expired',
  InviteValidationError.alreadyUsed: 'alreadyUsed',
  InviteValidationError.revoked: 'revoked',
  InviteValidationError.alreadyMember: 'alreadyMember',
  InviteValidationError.familyFull: 'familyFull',
  InviteValidationError.familyNotFound: 'familyNotFound',
  InviteValidationError.unknown: 'unknown',
};
