// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'family_invite.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FamilyInvite _$FamilyInviteFromJson(Map<String, dynamic> json) {
  return _FamilyInvite.fromJson(json);
}

/// @nodoc
mixin _$FamilyInvite {
  /// Unique identifier for the invite
  String get id => throw _privateConstructorUsedError;

  /// ID of the family this invite is for
  String get familyId => throw _privateConstructorUsedError;

  /// Unique invite code that users enter to join
  String get inviteCode => throw _privateConstructorUsedError;

  /// When the invite was created
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// When the invite expires (default: 7 days from creation)
  DateTime get expiresAt => throw _privateConstructorUsedError;

  /// UID of the user who created this invite
  String get createdByUid => throw _privateConstructorUsedError;

  /// Current status of the invite
  InviteStatus get status => throw _privateConstructorUsedError;

  /// UID of the user who accepted this invite (if accepted)
  String? get acceptedByUid => throw _privateConstructorUsedError;

  /// When the invite was accepted (if accepted)
  DateTime? get acceptedAt => throw _privateConstructorUsedError;

  /// Role that will be assigned when the invite is accepted
  String get role => throw _privateConstructorUsedError;

  /// Maximum number of times this invite can be used (default: 1)
  int get maxUses => throw _privateConstructorUsedError;

  /// Number of times this invite has been used
  int get useCount => throw _privateConstructorUsedError;

  /// Serializes this FamilyInvite to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FamilyInvite
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FamilyInviteCopyWith<FamilyInvite> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FamilyInviteCopyWith<$Res> {
  factory $FamilyInviteCopyWith(
    FamilyInvite value,
    $Res Function(FamilyInvite) then,
  ) = _$FamilyInviteCopyWithImpl<$Res, FamilyInvite>;
  @useResult
  $Res call({
    String id,
    String familyId,
    String inviteCode,
    DateTime createdAt,
    DateTime expiresAt,
    String createdByUid,
    InviteStatus status,
    String? acceptedByUid,
    DateTime? acceptedAt,
    String role,
    int maxUses,
    int useCount,
  });
}

/// @nodoc
class _$FamilyInviteCopyWithImpl<$Res, $Val extends FamilyInvite>
    implements $FamilyInviteCopyWith<$Res> {
  _$FamilyInviteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FamilyInvite
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? familyId = null,
    Object? inviteCode = null,
    Object? createdAt = null,
    Object? expiresAt = null,
    Object? createdByUid = null,
    Object? status = null,
    Object? acceptedByUid = freezed,
    Object? acceptedAt = freezed,
    Object? role = null,
    Object? maxUses = null,
    Object? useCount = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            familyId: null == familyId
                ? _value.familyId
                : familyId // ignore: cast_nullable_to_non_nullable
                      as String,
            inviteCode: null == inviteCode
                ? _value.inviteCode
                : inviteCode // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            expiresAt: null == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            createdByUid: null == createdByUid
                ? _value.createdByUid
                : createdByUid // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as InviteStatus,
            acceptedByUid: freezed == acceptedByUid
                ? _value.acceptedByUid
                : acceptedByUid // ignore: cast_nullable_to_non_nullable
                      as String?,
            acceptedAt: freezed == acceptedAt
                ? _value.acceptedAt
                : acceptedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String,
            maxUses: null == maxUses
                ? _value.maxUses
                : maxUses // ignore: cast_nullable_to_non_nullable
                      as int,
            useCount: null == useCount
                ? _value.useCount
                : useCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FamilyInviteImplCopyWith<$Res>
    implements $FamilyInviteCopyWith<$Res> {
  factory _$$FamilyInviteImplCopyWith(
    _$FamilyInviteImpl value,
    $Res Function(_$FamilyInviteImpl) then,
  ) = __$$FamilyInviteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String familyId,
    String inviteCode,
    DateTime createdAt,
    DateTime expiresAt,
    String createdByUid,
    InviteStatus status,
    String? acceptedByUid,
    DateTime? acceptedAt,
    String role,
    int maxUses,
    int useCount,
  });
}

/// @nodoc
class __$$FamilyInviteImplCopyWithImpl<$Res>
    extends _$FamilyInviteCopyWithImpl<$Res, _$FamilyInviteImpl>
    implements _$$FamilyInviteImplCopyWith<$Res> {
  __$$FamilyInviteImplCopyWithImpl(
    _$FamilyInviteImpl _value,
    $Res Function(_$FamilyInviteImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FamilyInvite
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? familyId = null,
    Object? inviteCode = null,
    Object? createdAt = null,
    Object? expiresAt = null,
    Object? createdByUid = null,
    Object? status = null,
    Object? acceptedByUid = freezed,
    Object? acceptedAt = freezed,
    Object? role = null,
    Object? maxUses = null,
    Object? useCount = null,
  }) {
    return _then(
      _$FamilyInviteImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        familyId: null == familyId
            ? _value.familyId
            : familyId // ignore: cast_nullable_to_non_nullable
                  as String,
        inviteCode: null == inviteCode
            ? _value.inviteCode
            : inviteCode // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        expiresAt: null == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        createdByUid: null == createdByUid
            ? _value.createdByUid
            : createdByUid // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as InviteStatus,
        acceptedByUid: freezed == acceptedByUid
            ? _value.acceptedByUid
            : acceptedByUid // ignore: cast_nullable_to_non_nullable
                  as String?,
        acceptedAt: freezed == acceptedAt
            ? _value.acceptedAt
            : acceptedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String,
        maxUses: null == maxUses
            ? _value.maxUses
            : maxUses // ignore: cast_nullable_to_non_nullable
                  as int,
        useCount: null == useCount
            ? _value.useCount
            : useCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FamilyInviteImpl extends _FamilyInvite {
  const _$FamilyInviteImpl({
    required this.id,
    required this.familyId,
    required this.inviteCode,
    required this.createdAt,
    required this.expiresAt,
    required this.createdByUid,
    this.status = InviteStatus.active,
    this.acceptedByUid,
    this.acceptedAt,
    this.role = 'child',
    this.maxUses = 1,
    this.useCount = 0,
  }) : super._();

  factory _$FamilyInviteImpl.fromJson(Map<String, dynamic> json) =>
      _$$FamilyInviteImplFromJson(json);

  /// Unique identifier for the invite
  @override
  final String id;

  /// ID of the family this invite is for
  @override
  final String familyId;

  /// Unique invite code that users enter to join
  @override
  final String inviteCode;

  /// When the invite was created
  @override
  final DateTime createdAt;

  /// When the invite expires (default: 7 days from creation)
  @override
  final DateTime expiresAt;

  /// UID of the user who created this invite
  @override
  final String createdByUid;

  /// Current status of the invite
  @override
  @JsonKey()
  final InviteStatus status;

  /// UID of the user who accepted this invite (if accepted)
  @override
  final String? acceptedByUid;

  /// When the invite was accepted (if accepted)
  @override
  final DateTime? acceptedAt;

  /// Role that will be assigned when the invite is accepted
  @override
  @JsonKey()
  final String role;

  /// Maximum number of times this invite can be used (default: 1)
  @override
  @JsonKey()
  final int maxUses;

  /// Number of times this invite has been used
  @override
  @JsonKey()
  final int useCount;

  @override
  String toString() {
    return 'FamilyInvite(id: $id, familyId: $familyId, inviteCode: $inviteCode, createdAt: $createdAt, expiresAt: $expiresAt, createdByUid: $createdByUid, status: $status, acceptedByUid: $acceptedByUid, acceptedAt: $acceptedAt, role: $role, maxUses: $maxUses, useCount: $useCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FamilyInviteImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.familyId, familyId) ||
                other.familyId == familyId) &&
            (identical(other.inviteCode, inviteCode) ||
                other.inviteCode == inviteCode) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.createdByUid, createdByUid) ||
                other.createdByUid == createdByUid) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.acceptedByUid, acceptedByUid) ||
                other.acceptedByUid == acceptedByUid) &&
            (identical(other.acceptedAt, acceptedAt) ||
                other.acceptedAt == acceptedAt) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.maxUses, maxUses) || other.maxUses == maxUses) &&
            (identical(other.useCount, useCount) ||
                other.useCount == useCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    familyId,
    inviteCode,
    createdAt,
    expiresAt,
    createdByUid,
    status,
    acceptedByUid,
    acceptedAt,
    role,
    maxUses,
    useCount,
  );

  /// Create a copy of FamilyInvite
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FamilyInviteImplCopyWith<_$FamilyInviteImpl> get copyWith =>
      __$$FamilyInviteImplCopyWithImpl<_$FamilyInviteImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FamilyInviteImplToJson(this);
  }
}

abstract class _FamilyInvite extends FamilyInvite {
  const factory _FamilyInvite({
    required final String id,
    required final String familyId,
    required final String inviteCode,
    required final DateTime createdAt,
    required final DateTime expiresAt,
    required final String createdByUid,
    final InviteStatus status,
    final String? acceptedByUid,
    final DateTime? acceptedAt,
    final String role,
    final int maxUses,
    final int useCount,
  }) = _$FamilyInviteImpl;
  const _FamilyInvite._() : super._();

  factory _FamilyInvite.fromJson(Map<String, dynamic> json) =
      _$FamilyInviteImpl.fromJson;

  /// Unique identifier for the invite
  @override
  String get id;

  /// ID of the family this invite is for
  @override
  String get familyId;

  /// Unique invite code that users enter to join
  @override
  String get inviteCode;

  /// When the invite was created
  @override
  DateTime get createdAt;

  /// When the invite expires (default: 7 days from creation)
  @override
  DateTime get expiresAt;

  /// UID of the user who created this invite
  @override
  String get createdByUid;

  /// Current status of the invite
  @override
  InviteStatus get status;

  /// UID of the user who accepted this invite (if accepted)
  @override
  String? get acceptedByUid;

  /// When the invite was accepted (if accepted)
  @override
  DateTime? get acceptedAt;

  /// Role that will be assigned when the invite is accepted
  @override
  String get role;

  /// Maximum number of times this invite can be used (default: 1)
  @override
  int get maxUses;

  /// Number of times this invite has been used
  @override
  int get useCount;

  /// Create a copy of FamilyInvite
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FamilyInviteImplCopyWith<_$FamilyInviteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
