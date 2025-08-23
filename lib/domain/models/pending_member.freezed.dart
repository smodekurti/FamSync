// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pending_member.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PendingMember _$PendingMemberFromJson(Map<String, dynamic> json) {
  return _PendingMember.fromJson(json);
}

/// @nodoc
mixin _$PendingMember {
  /// Unique identifier for the pending member
  String get id => throw _privateConstructorUsedError;

  /// ID of the invite this pending member is associated with
  String get inviteId => throw _privateConstructorUsedError;

  /// Email address of the invited person
  String get email => throw _privateConstructorUsedError;

  /// Display name for the invited person
  String get displayName => throw _privateConstructorUsedError;

  /// When the invitation was sent
  DateTime get invitedAt => throw _privateConstructorUsedError;

  /// Role that will be assigned when they join
  String get role => throw _privateConstructorUsedError;

  /// ID of the family they're being invited to
  String get familyId => throw _privateConstructorUsedError;

  /// UID of the user who sent the invitation
  String get invitedByUid => throw _privateConstructorUsedError;

  /// Whether a reminder has been sent
  bool get reminderSent => throw _privateConstructorUsedError;

  /// When the last reminder was sent (if any)
  DateTime? get lastReminderSentAt => throw _privateConstructorUsedError;

  /// Number of reminders sent
  int get reminderCount => throw _privateConstructorUsedError;

  /// Serializes this PendingMember to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PendingMember
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PendingMemberCopyWith<PendingMember> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PendingMemberCopyWith<$Res> {
  factory $PendingMemberCopyWith(
    PendingMember value,
    $Res Function(PendingMember) then,
  ) = _$PendingMemberCopyWithImpl<$Res, PendingMember>;
  @useResult
  $Res call({
    String id,
    String inviteId,
    String email,
    String displayName,
    DateTime invitedAt,
    String role,
    String familyId,
    String invitedByUid,
    bool reminderSent,
    DateTime? lastReminderSentAt,
    int reminderCount,
  });
}

/// @nodoc
class _$PendingMemberCopyWithImpl<$Res, $Val extends PendingMember>
    implements $PendingMemberCopyWith<$Res> {
  _$PendingMemberCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PendingMember
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? inviteId = null,
    Object? email = null,
    Object? displayName = null,
    Object? invitedAt = null,
    Object? role = null,
    Object? familyId = null,
    Object? invitedByUid = null,
    Object? reminderSent = null,
    Object? lastReminderSentAt = freezed,
    Object? reminderCount = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            inviteId: null == inviteId
                ? _value.inviteId
                : inviteId // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            displayName: null == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                      as String,
            invitedAt: null == invitedAt
                ? _value.invitedAt
                : invitedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String,
            familyId: null == familyId
                ? _value.familyId
                : familyId // ignore: cast_nullable_to_non_nullable
                      as String,
            invitedByUid: null == invitedByUid
                ? _value.invitedByUid
                : invitedByUid // ignore: cast_nullable_to_non_nullable
                      as String,
            reminderSent: null == reminderSent
                ? _value.reminderSent
                : reminderSent // ignore: cast_nullable_to_non_nullable
                      as bool,
            lastReminderSentAt: freezed == lastReminderSentAt
                ? _value.lastReminderSentAt
                : lastReminderSentAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            reminderCount: null == reminderCount
                ? _value.reminderCount
                : reminderCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PendingMemberImplCopyWith<$Res>
    implements $PendingMemberCopyWith<$Res> {
  factory _$$PendingMemberImplCopyWith(
    _$PendingMemberImpl value,
    $Res Function(_$PendingMemberImpl) then,
  ) = __$$PendingMemberImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String inviteId,
    String email,
    String displayName,
    DateTime invitedAt,
    String role,
    String familyId,
    String invitedByUid,
    bool reminderSent,
    DateTime? lastReminderSentAt,
    int reminderCount,
  });
}

/// @nodoc
class __$$PendingMemberImplCopyWithImpl<$Res>
    extends _$PendingMemberCopyWithImpl<$Res, _$PendingMemberImpl>
    implements _$$PendingMemberImplCopyWith<$Res> {
  __$$PendingMemberImplCopyWithImpl(
    _$PendingMemberImpl _value,
    $Res Function(_$PendingMemberImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PendingMember
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? inviteId = null,
    Object? email = null,
    Object? displayName = null,
    Object? invitedAt = null,
    Object? role = null,
    Object? familyId = null,
    Object? invitedByUid = null,
    Object? reminderSent = null,
    Object? lastReminderSentAt = freezed,
    Object? reminderCount = null,
  }) {
    return _then(
      _$PendingMemberImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        inviteId: null == inviteId
            ? _value.inviteId
            : inviteId // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        displayName: null == displayName
            ? _value.displayName
            : displayName // ignore: cast_nullable_to_non_nullable
                  as String,
        invitedAt: null == invitedAt
            ? _value.invitedAt
            : invitedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String,
        familyId: null == familyId
            ? _value.familyId
            : familyId // ignore: cast_nullable_to_non_nullable
                  as String,
        invitedByUid: null == invitedByUid
            ? _value.invitedByUid
            : invitedByUid // ignore: cast_nullable_to_non_nullable
                  as String,
        reminderSent: null == reminderSent
            ? _value.reminderSent
            : reminderSent // ignore: cast_nullable_to_non_nullable
                  as bool,
        lastReminderSentAt: freezed == lastReminderSentAt
            ? _value.lastReminderSentAt
            : lastReminderSentAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        reminderCount: null == reminderCount
            ? _value.reminderCount
            : reminderCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PendingMemberImpl extends _PendingMember {
  const _$PendingMemberImpl({
    required this.id,
    required this.inviteId,
    required this.email,
    required this.displayName,
    required this.invitedAt,
    this.role = 'child',
    required this.familyId,
    required this.invitedByUid,
    this.reminderSent = false,
    this.lastReminderSentAt,
    this.reminderCount = 0,
  }) : super._();

  factory _$PendingMemberImpl.fromJson(Map<String, dynamic> json) =>
      _$$PendingMemberImplFromJson(json);

  /// Unique identifier for the pending member
  @override
  final String id;

  /// ID of the invite this pending member is associated with
  @override
  final String inviteId;

  /// Email address of the invited person
  @override
  final String email;

  /// Display name for the invited person
  @override
  final String displayName;

  /// When the invitation was sent
  @override
  final DateTime invitedAt;

  /// Role that will be assigned when they join
  @override
  @JsonKey()
  final String role;

  /// ID of the family they're being invited to
  @override
  final String familyId;

  /// UID of the user who sent the invitation
  @override
  final String invitedByUid;

  /// Whether a reminder has been sent
  @override
  @JsonKey()
  final bool reminderSent;

  /// When the last reminder was sent (if any)
  @override
  final DateTime? lastReminderSentAt;

  /// Number of reminders sent
  @override
  @JsonKey()
  final int reminderCount;

  @override
  String toString() {
    return 'PendingMember(id: $id, inviteId: $inviteId, email: $email, displayName: $displayName, invitedAt: $invitedAt, role: $role, familyId: $familyId, invitedByUid: $invitedByUid, reminderSent: $reminderSent, lastReminderSentAt: $lastReminderSentAt, reminderCount: $reminderCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PendingMemberImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.inviteId, inviteId) ||
                other.inviteId == inviteId) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.invitedAt, invitedAt) ||
                other.invitedAt == invitedAt) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.familyId, familyId) ||
                other.familyId == familyId) &&
            (identical(other.invitedByUid, invitedByUid) ||
                other.invitedByUid == invitedByUid) &&
            (identical(other.reminderSent, reminderSent) ||
                other.reminderSent == reminderSent) &&
            (identical(other.lastReminderSentAt, lastReminderSentAt) ||
                other.lastReminderSentAt == lastReminderSentAt) &&
            (identical(other.reminderCount, reminderCount) ||
                other.reminderCount == reminderCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    inviteId,
    email,
    displayName,
    invitedAt,
    role,
    familyId,
    invitedByUid,
    reminderSent,
    lastReminderSentAt,
    reminderCount,
  );

  /// Create a copy of PendingMember
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PendingMemberImplCopyWith<_$PendingMemberImpl> get copyWith =>
      __$$PendingMemberImplCopyWithImpl<_$PendingMemberImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PendingMemberImplToJson(this);
  }
}

abstract class _PendingMember extends PendingMember {
  const factory _PendingMember({
    required final String id,
    required final String inviteId,
    required final String email,
    required final String displayName,
    required final DateTime invitedAt,
    final String role,
    required final String familyId,
    required final String invitedByUid,
    final bool reminderSent,
    final DateTime? lastReminderSentAt,
    final int reminderCount,
  }) = _$PendingMemberImpl;
  const _PendingMember._() : super._();

  factory _PendingMember.fromJson(Map<String, dynamic> json) =
      _$PendingMemberImpl.fromJson;

  /// Unique identifier for the pending member
  @override
  String get id;

  /// ID of the invite this pending member is associated with
  @override
  String get inviteId;

  /// Email address of the invited person
  @override
  String get email;

  /// Display name for the invited person
  @override
  String get displayName;

  /// When the invitation was sent
  @override
  DateTime get invitedAt;

  /// Role that will be assigned when they join
  @override
  String get role;

  /// ID of the family they're being invited to
  @override
  String get familyId;

  /// UID of the user who sent the invitation
  @override
  String get invitedByUid;

  /// Whether a reminder has been sent
  @override
  bool get reminderSent;

  /// When the last reminder was sent (if any)
  @override
  DateTime? get lastReminderSentAt;

  /// Number of reminders sent
  @override
  int get reminderCount;

  /// Create a copy of PendingMember
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PendingMemberImplCopyWith<_$PendingMemberImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
