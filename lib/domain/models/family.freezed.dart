// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'family.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Family _$FamilyFromJson(Map<String, dynamic> json) {
  return _Family.fromJson(json);
}

/// @nodoc
mixin _$Family {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  List<String> get memberUids => throw _privateConstructorUsedError;
  Map<String, String> get roles =>
      throw _privateConstructorUsedError; // uid -> role (parent/child)
  Map<String, String> get colors =>
      throw _privateConstructorUsedError; // uid -> hex/color name token
  String? get inviteCode => throw _privateConstructorUsedError;
  int get maxMembers =>
      throw _privateConstructorUsedError; // Maximum number of family members allowed
  bool get allowInvites =>
      throw _privateConstructorUsedError; // Whether the family allows new invites
  DateTime? get createdAt =>
      throw _privateConstructorUsedError; // When the family was created
  String get ownerUid => throw _privateConstructorUsedError;

  /// Serializes this Family to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Family
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FamilyCopyWith<Family> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FamilyCopyWith<$Res> {
  factory $FamilyCopyWith(Family value, $Res Function(Family) then) =
      _$FamilyCopyWithImpl<$Res, Family>;
  @useResult
  $Res call({
    String id,
    String name,
    List<String> memberUids,
    Map<String, String> roles,
    Map<String, String> colors,
    String? inviteCode,
    int maxMembers,
    bool allowInvites,
    DateTime? createdAt,
    String ownerUid,
  });
}

/// @nodoc
class _$FamilyCopyWithImpl<$Res, $Val extends Family>
    implements $FamilyCopyWith<$Res> {
  _$FamilyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Family
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? memberUids = null,
    Object? roles = null,
    Object? colors = null,
    Object? inviteCode = freezed,
    Object? maxMembers = null,
    Object? allowInvites = null,
    Object? createdAt = freezed,
    Object? ownerUid = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            memberUids: null == memberUids
                ? _value.memberUids
                : memberUids // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            roles: null == roles
                ? _value.roles
                : roles // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>,
            colors: null == colors
                ? _value.colors
                : colors // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>,
            inviteCode: freezed == inviteCode
                ? _value.inviteCode
                : inviteCode // ignore: cast_nullable_to_non_nullable
                      as String?,
            maxMembers: null == maxMembers
                ? _value.maxMembers
                : maxMembers // ignore: cast_nullable_to_non_nullable
                      as int,
            allowInvites: null == allowInvites
                ? _value.allowInvites
                : allowInvites // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            ownerUid: null == ownerUid
                ? _value.ownerUid
                : ownerUid // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FamilyImplCopyWith<$Res> implements $FamilyCopyWith<$Res> {
  factory _$$FamilyImplCopyWith(
    _$FamilyImpl value,
    $Res Function(_$FamilyImpl) then,
  ) = __$$FamilyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    List<String> memberUids,
    Map<String, String> roles,
    Map<String, String> colors,
    String? inviteCode,
    int maxMembers,
    bool allowInvites,
    DateTime? createdAt,
    String ownerUid,
  });
}

/// @nodoc
class __$$FamilyImplCopyWithImpl<$Res>
    extends _$FamilyCopyWithImpl<$Res, _$FamilyImpl>
    implements _$$FamilyImplCopyWith<$Res> {
  __$$FamilyImplCopyWithImpl(
    _$FamilyImpl _value,
    $Res Function(_$FamilyImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Family
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? memberUids = null,
    Object? roles = null,
    Object? colors = null,
    Object? inviteCode = freezed,
    Object? maxMembers = null,
    Object? allowInvites = null,
    Object? createdAt = freezed,
    Object? ownerUid = null,
  }) {
    return _then(
      _$FamilyImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        memberUids: null == memberUids
            ? _value._memberUids
            : memberUids // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        roles: null == roles
            ? _value._roles
            : roles // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>,
        colors: null == colors
            ? _value._colors
            : colors // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>,
        inviteCode: freezed == inviteCode
            ? _value.inviteCode
            : inviteCode // ignore: cast_nullable_to_non_nullable
                  as String?,
        maxMembers: null == maxMembers
            ? _value.maxMembers
            : maxMembers // ignore: cast_nullable_to_non_nullable
                  as int,
        allowInvites: null == allowInvites
            ? _value.allowInvites
            : allowInvites // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        ownerUid: null == ownerUid
            ? _value.ownerUid
            : ownerUid // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FamilyImpl extends _Family {
  const _$FamilyImpl({
    required this.id,
    required this.name,
    final List<String> memberUids = const [],
    final Map<String, String> roles = const {},
    final Map<String, String> colors = const {},
    this.inviteCode,
    this.maxMembers = 10,
    this.allowInvites = false,
    this.createdAt,
    this.ownerUid = '',
  }) : _memberUids = memberUids,
       _roles = roles,
       _colors = colors,
       super._();

  factory _$FamilyImpl.fromJson(Map<String, dynamic> json) =>
      _$$FamilyImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  final List<String> _memberUids;
  @override
  @JsonKey()
  List<String> get memberUids {
    if (_memberUids is EqualUnmodifiableListView) return _memberUids;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_memberUids);
  }

  final Map<String, String> _roles;
  @override
  @JsonKey()
  Map<String, String> get roles {
    if (_roles is EqualUnmodifiableMapView) return _roles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_roles);
  }

  // uid -> role (parent/child)
  final Map<String, String> _colors;
  // uid -> role (parent/child)
  @override
  @JsonKey()
  Map<String, String> get colors {
    if (_colors is EqualUnmodifiableMapView) return _colors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_colors);
  }

  // uid -> hex/color name token
  @override
  final String? inviteCode;
  @override
  @JsonKey()
  final int maxMembers;
  // Maximum number of family members allowed
  @override
  @JsonKey()
  final bool allowInvites;
  // Whether the family allows new invites
  @override
  final DateTime? createdAt;
  // When the family was created
  @override
  @JsonKey()
  final String ownerUid;

  @override
  String toString() {
    return 'Family(id: $id, name: $name, memberUids: $memberUids, roles: $roles, colors: $colors, inviteCode: $inviteCode, maxMembers: $maxMembers, allowInvites: $allowInvites, createdAt: $createdAt, ownerUid: $ownerUid)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FamilyImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(
              other._memberUids,
              _memberUids,
            ) &&
            const DeepCollectionEquality().equals(other._roles, _roles) &&
            const DeepCollectionEquality().equals(other._colors, _colors) &&
            (identical(other.inviteCode, inviteCode) ||
                other.inviteCode == inviteCode) &&
            (identical(other.maxMembers, maxMembers) ||
                other.maxMembers == maxMembers) &&
            (identical(other.allowInvites, allowInvites) ||
                other.allowInvites == allowInvites) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.ownerUid, ownerUid) ||
                other.ownerUid == ownerUid));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    const DeepCollectionEquality().hash(_memberUids),
    const DeepCollectionEquality().hash(_roles),
    const DeepCollectionEquality().hash(_colors),
    inviteCode,
    maxMembers,
    allowInvites,
    createdAt,
    ownerUid,
  );

  /// Create a copy of Family
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FamilyImplCopyWith<_$FamilyImpl> get copyWith =>
      __$$FamilyImplCopyWithImpl<_$FamilyImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FamilyImplToJson(this);
  }
}

abstract class _Family extends Family {
  const factory _Family({
    required final String id,
    required final String name,
    final List<String> memberUids,
    final Map<String, String> roles,
    final Map<String, String> colors,
    final String? inviteCode,
    final int maxMembers,
    final bool allowInvites,
    final DateTime? createdAt,
    final String ownerUid,
  }) = _$FamilyImpl;
  const _Family._() : super._();

  factory _Family.fromJson(Map<String, dynamic> json) = _$FamilyImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  List<String> get memberUids;
  @override
  Map<String, String> get roles; // uid -> role (parent/child)
  @override
  Map<String, String> get colors; // uid -> hex/color name token
  @override
  String? get inviteCode;
  @override
  int get maxMembers; // Maximum number of family members allowed
  @override
  bool get allowInvites; // Whether the family allows new invites
  @override
  DateTime? get createdAt; // When the family was created
  @override
  String get ownerUid;

  /// Create a copy of Family
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FamilyImplCopyWith<_$FamilyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
