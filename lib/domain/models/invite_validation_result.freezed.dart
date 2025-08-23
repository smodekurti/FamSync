// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invite_validation_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

InviteValidationResult _$InviteValidationResultFromJson(
  Map<String, dynamic> json,
) {
  return _InviteValidationResult.fromJson(json);
}

/// @nodoc
mixin _$InviteValidationResult {
  /// Whether the invite code is valid and can be used
  bool get isValid => throw _privateConstructorUsedError;

  /// The family object if valid
  Family? get family => throw _privateConstructorUsedError;

  /// The invite ID if valid
  String? get inviteId => throw _privateConstructorUsedError;

  /// Error message if validation failed
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Specific validation error type
  InviteValidationError? get errorType => throw _privateConstructorUsedError;

  /// Whether the current user is already a member of this family
  bool get isAlreadyMember => throw _privateConstructorUsedError;

  /// Whether the family has reached its member limit
  bool get isFamilyFull => throw _privateConstructorUsedError;

  /// Whether the invite has expired
  bool get isExpired => throw _privateConstructorUsedError;

  /// Whether the invite has already been used
  bool get isAlreadyUsed => throw _privateConstructorUsedError;

  /// Whether the invite has been revoked
  bool get isRevoked => throw _privateConstructorUsedError;

  /// Serializes this InviteValidationResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InviteValidationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InviteValidationResultCopyWith<InviteValidationResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InviteValidationResultCopyWith<$Res> {
  factory $InviteValidationResultCopyWith(
    InviteValidationResult value,
    $Res Function(InviteValidationResult) then,
  ) = _$InviteValidationResultCopyWithImpl<$Res, InviteValidationResult>;
  @useResult
  $Res call({
    bool isValid,
    Family? family,
    String? inviteId,
    String? errorMessage,
    InviteValidationError? errorType,
    bool isAlreadyMember,
    bool isFamilyFull,
    bool isExpired,
    bool isAlreadyUsed,
    bool isRevoked,
  });

  $FamilyCopyWith<$Res>? get family;
}

/// @nodoc
class _$InviteValidationResultCopyWithImpl<
  $Res,
  $Val extends InviteValidationResult
>
    implements $InviteValidationResultCopyWith<$Res> {
  _$InviteValidationResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InviteValidationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isValid = null,
    Object? family = freezed,
    Object? inviteId = freezed,
    Object? errorMessage = freezed,
    Object? errorType = freezed,
    Object? isAlreadyMember = null,
    Object? isFamilyFull = null,
    Object? isExpired = null,
    Object? isAlreadyUsed = null,
    Object? isRevoked = null,
  }) {
    return _then(
      _value.copyWith(
            isValid: null == isValid
                ? _value.isValid
                : isValid // ignore: cast_nullable_to_non_nullable
                      as bool,
            family: freezed == family
                ? _value.family
                : family // ignore: cast_nullable_to_non_nullable
                      as Family?,
            inviteId: freezed == inviteId
                ? _value.inviteId
                : inviteId // ignore: cast_nullable_to_non_nullable
                      as String?,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
            errorType: freezed == errorType
                ? _value.errorType
                : errorType // ignore: cast_nullable_to_non_nullable
                      as InviteValidationError?,
            isAlreadyMember: null == isAlreadyMember
                ? _value.isAlreadyMember
                : isAlreadyMember // ignore: cast_nullable_to_non_nullable
                      as bool,
            isFamilyFull: null == isFamilyFull
                ? _value.isFamilyFull
                : isFamilyFull // ignore: cast_nullable_to_non_nullable
                      as bool,
            isExpired: null == isExpired
                ? _value.isExpired
                : isExpired // ignore: cast_nullable_to_non_nullable
                      as bool,
            isAlreadyUsed: null == isAlreadyUsed
                ? _value.isAlreadyUsed
                : isAlreadyUsed // ignore: cast_nullable_to_non_nullable
                      as bool,
            isRevoked: null == isRevoked
                ? _value.isRevoked
                : isRevoked // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }

  /// Create a copy of InviteValidationResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FamilyCopyWith<$Res>? get family {
    if (_value.family == null) {
      return null;
    }

    return $FamilyCopyWith<$Res>(_value.family!, (value) {
      return _then(_value.copyWith(family: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$InviteValidationResultImplCopyWith<$Res>
    implements $InviteValidationResultCopyWith<$Res> {
  factory _$$InviteValidationResultImplCopyWith(
    _$InviteValidationResultImpl value,
    $Res Function(_$InviteValidationResultImpl) then,
  ) = __$$InviteValidationResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool isValid,
    Family? family,
    String? inviteId,
    String? errorMessage,
    InviteValidationError? errorType,
    bool isAlreadyMember,
    bool isFamilyFull,
    bool isExpired,
    bool isAlreadyUsed,
    bool isRevoked,
  });

  @override
  $FamilyCopyWith<$Res>? get family;
}

/// @nodoc
class __$$InviteValidationResultImplCopyWithImpl<$Res>
    extends
        _$InviteValidationResultCopyWithImpl<$Res, _$InviteValidationResultImpl>
    implements _$$InviteValidationResultImplCopyWith<$Res> {
  __$$InviteValidationResultImplCopyWithImpl(
    _$InviteValidationResultImpl _value,
    $Res Function(_$InviteValidationResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of InviteValidationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isValid = null,
    Object? family = freezed,
    Object? inviteId = freezed,
    Object? errorMessage = freezed,
    Object? errorType = freezed,
    Object? isAlreadyMember = null,
    Object? isFamilyFull = null,
    Object? isExpired = null,
    Object? isAlreadyUsed = null,
    Object? isRevoked = null,
  }) {
    return _then(
      _$InviteValidationResultImpl(
        isValid: null == isValid
            ? _value.isValid
            : isValid // ignore: cast_nullable_to_non_nullable
                  as bool,
        family: freezed == family
            ? _value.family
            : family // ignore: cast_nullable_to_non_nullable
                  as Family?,
        inviteId: freezed == inviteId
            ? _value.inviteId
            : inviteId // ignore: cast_nullable_to_non_nullable
                  as String?,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
        errorType: freezed == errorType
            ? _value.errorType
            : errorType // ignore: cast_nullable_to_non_nullable
                  as InviteValidationError?,
        isAlreadyMember: null == isAlreadyMember
            ? _value.isAlreadyMember
            : isAlreadyMember // ignore: cast_nullable_to_non_nullable
                  as bool,
        isFamilyFull: null == isFamilyFull
            ? _value.isFamilyFull
            : isFamilyFull // ignore: cast_nullable_to_non_nullable
                  as bool,
        isExpired: null == isExpired
            ? _value.isExpired
            : isExpired // ignore: cast_nullable_to_non_nullable
                  as bool,
        isAlreadyUsed: null == isAlreadyUsed
            ? _value.isAlreadyUsed
            : isAlreadyUsed // ignore: cast_nullable_to_non_nullable
                  as bool,
        isRevoked: null == isRevoked
            ? _value.isRevoked
            : isRevoked // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$InviteValidationResultImpl extends _InviteValidationResult {
  const _$InviteValidationResultImpl({
    required this.isValid,
    required this.family,
    required this.inviteId,
    this.errorMessage,
    this.errorType,
    this.isAlreadyMember = false,
    this.isFamilyFull = false,
    this.isExpired = false,
    this.isAlreadyUsed = false,
    this.isRevoked = false,
  }) : super._();

  factory _$InviteValidationResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$InviteValidationResultImplFromJson(json);

  /// Whether the invite code is valid and can be used
  @override
  final bool isValid;

  /// The family object if valid
  @override
  final Family? family;

  /// The invite ID if valid
  @override
  final String? inviteId;

  /// Error message if validation failed
  @override
  final String? errorMessage;

  /// Specific validation error type
  @override
  final InviteValidationError? errorType;

  /// Whether the current user is already a member of this family
  @override
  @JsonKey()
  final bool isAlreadyMember;

  /// Whether the family has reached its member limit
  @override
  @JsonKey()
  final bool isFamilyFull;

  /// Whether the invite has expired
  @override
  @JsonKey()
  final bool isExpired;

  /// Whether the invite has already been used
  @override
  @JsonKey()
  final bool isAlreadyUsed;

  /// Whether the invite has been revoked
  @override
  @JsonKey()
  final bool isRevoked;

  @override
  String toString() {
    return 'InviteValidationResult(isValid: $isValid, family: $family, inviteId: $inviteId, errorMessage: $errorMessage, errorType: $errorType, isAlreadyMember: $isAlreadyMember, isFamilyFull: $isFamilyFull, isExpired: $isExpired, isAlreadyUsed: $isAlreadyUsed, isRevoked: $isRevoked)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InviteValidationResultImpl &&
            (identical(other.isValid, isValid) || other.isValid == isValid) &&
            (identical(other.family, family) || other.family == family) &&
            (identical(other.inviteId, inviteId) ||
                other.inviteId == inviteId) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.errorType, errorType) ||
                other.errorType == errorType) &&
            (identical(other.isAlreadyMember, isAlreadyMember) ||
                other.isAlreadyMember == isAlreadyMember) &&
            (identical(other.isFamilyFull, isFamilyFull) ||
                other.isFamilyFull == isFamilyFull) &&
            (identical(other.isExpired, isExpired) ||
                other.isExpired == isExpired) &&
            (identical(other.isAlreadyUsed, isAlreadyUsed) ||
                other.isAlreadyUsed == isAlreadyUsed) &&
            (identical(other.isRevoked, isRevoked) ||
                other.isRevoked == isRevoked));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    isValid,
    family,
    inviteId,
    errorMessage,
    errorType,
    isAlreadyMember,
    isFamilyFull,
    isExpired,
    isAlreadyUsed,
    isRevoked,
  );

  /// Create a copy of InviteValidationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InviteValidationResultImplCopyWith<_$InviteValidationResultImpl>
  get copyWith =>
      __$$InviteValidationResultImplCopyWithImpl<_$InviteValidationResultImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$InviteValidationResultImplToJson(this);
  }
}

abstract class _InviteValidationResult extends InviteValidationResult {
  const factory _InviteValidationResult({
    required final bool isValid,
    required final Family? family,
    required final String? inviteId,
    final String? errorMessage,
    final InviteValidationError? errorType,
    final bool isAlreadyMember,
    final bool isFamilyFull,
    final bool isExpired,
    final bool isAlreadyUsed,
    final bool isRevoked,
  }) = _$InviteValidationResultImpl;
  const _InviteValidationResult._() : super._();

  factory _InviteValidationResult.fromJson(Map<String, dynamic> json) =
      _$InviteValidationResultImpl.fromJson;

  /// Whether the invite code is valid and can be used
  @override
  bool get isValid;

  /// The family object if valid
  @override
  Family? get family;

  /// The invite ID if valid
  @override
  String? get inviteId;

  /// Error message if validation failed
  @override
  String? get errorMessage;

  /// Specific validation error type
  @override
  InviteValidationError? get errorType;

  /// Whether the current user is already a member of this family
  @override
  bool get isAlreadyMember;

  /// Whether the family has reached its member limit
  @override
  bool get isFamilyFull;

  /// Whether the invite has expired
  @override
  bool get isExpired;

  /// Whether the invite has already been used
  @override
  bool get isAlreadyUsed;

  /// Whether the invite has been revoked
  @override
  bool get isRevoked;

  /// Create a copy of InviteValidationResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InviteValidationResultImplCopyWith<_$InviteValidationResultImpl>
  get copyWith => throw _privateConstructorUsedError;
}
