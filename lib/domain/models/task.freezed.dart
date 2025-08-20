// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Task _$TaskFromJson(Map<String, dynamic> json) {
  return _Task.fromJson(json);
}

/// @nodoc
mixin _$Task {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get notes => throw _privateConstructorUsedError;
  List<String> get assignedUids => throw _privateConstructorUsedError;
  @NullableTimestampDateTimeConverter()
  DateTime? get dueDate => throw _privateConstructorUsedError;
  TaskPriority get priority => throw _privateConstructorUsedError;
  bool get completed => throw _privateConstructorUsedError;
  @TimestampDateTimeConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Task to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Task
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaskCopyWith<Task> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskCopyWith<$Res> {
  factory $TaskCopyWith(Task value, $Res Function(Task) then) =
      _$TaskCopyWithImpl<$Res, Task>;
  @useResult
  $Res call({
    String id,
    String title,
    String notes,
    List<String> assignedUids,
    @NullableTimestampDateTimeConverter() DateTime? dueDate,
    TaskPriority priority,
    bool completed,
    @TimestampDateTimeConverter() DateTime createdAt,
  });
}

/// @nodoc
class _$TaskCopyWithImpl<$Res, $Val extends Task>
    implements $TaskCopyWith<$Res> {
  _$TaskCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Task
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? notes = null,
    Object? assignedUids = null,
    Object? dueDate = freezed,
    Object? priority = null,
    Object? completed = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            notes: null == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String,
            assignedUids: null == assignedUids
                ? _value.assignedUids
                : assignedUids // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            dueDate: freezed == dueDate
                ? _value.dueDate
                : dueDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            priority: null == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                      as TaskPriority,
            completed: null == completed
                ? _value.completed
                : completed // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TaskImplCopyWith<$Res> implements $TaskCopyWith<$Res> {
  factory _$$TaskImplCopyWith(
    _$TaskImpl value,
    $Res Function(_$TaskImpl) then,
  ) = __$$TaskImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String notes,
    List<String> assignedUids,
    @NullableTimestampDateTimeConverter() DateTime? dueDate,
    TaskPriority priority,
    bool completed,
    @TimestampDateTimeConverter() DateTime createdAt,
  });
}

/// @nodoc
class __$$TaskImplCopyWithImpl<$Res>
    extends _$TaskCopyWithImpl<$Res, _$TaskImpl>
    implements _$$TaskImplCopyWith<$Res> {
  __$$TaskImplCopyWithImpl(_$TaskImpl _value, $Res Function(_$TaskImpl) _then)
    : super(_value, _then);

  /// Create a copy of Task
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? notes = null,
    Object? assignedUids = null,
    Object? dueDate = freezed,
    Object? priority = null,
    Object? completed = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$TaskImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        notes: null == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String,
        assignedUids: null == assignedUids
            ? _value._assignedUids
            : assignedUids // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        dueDate: freezed == dueDate
            ? _value.dueDate
            : dueDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        priority: null == priority
            ? _value.priority
            : priority // ignore: cast_nullable_to_non_nullable
                  as TaskPriority,
        completed: null == completed
            ? _value.completed
            : completed // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TaskImpl implements _Task {
  const _$TaskImpl({
    required this.id,
    required this.title,
    this.notes = '',
    final List<String> assignedUids = const <String>[],
    @NullableTimestampDateTimeConverter() this.dueDate,
    this.priority = TaskPriority.medium,
    this.completed = false,
    @TimestampDateTimeConverter() required this.createdAt,
  }) : _assignedUids = assignedUids;

  factory _$TaskImpl.fromJson(Map<String, dynamic> json) =>
      _$$TaskImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  @JsonKey()
  final String notes;
  final List<String> _assignedUids;
  @override
  @JsonKey()
  List<String> get assignedUids {
    if (_assignedUids is EqualUnmodifiableListView) return _assignedUids;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_assignedUids);
  }

  @override
  @NullableTimestampDateTimeConverter()
  final DateTime? dueDate;
  @override
  @JsonKey()
  final TaskPriority priority;
  @override
  @JsonKey()
  final bool completed;
  @override
  @TimestampDateTimeConverter()
  final DateTime createdAt;

  @override
  String toString() {
    return 'Task(id: $id, title: $title, notes: $notes, assignedUids: $assignedUids, dueDate: $dueDate, priority: $priority, completed: $completed, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            const DeepCollectionEquality().equals(
              other._assignedUids,
              _assignedUids,
            ) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.completed, completed) ||
                other.completed == completed) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    notes,
    const DeepCollectionEquality().hash(_assignedUids),
    dueDate,
    priority,
    completed,
    createdAt,
  );

  /// Create a copy of Task
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaskImplCopyWith<_$TaskImpl> get copyWith =>
      __$$TaskImplCopyWithImpl<_$TaskImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TaskImplToJson(this);
  }
}

abstract class _Task implements Task {
  const factory _Task({
    required final String id,
    required final String title,
    final String notes,
    final List<String> assignedUids,
    @NullableTimestampDateTimeConverter() final DateTime? dueDate,
    final TaskPriority priority,
    final bool completed,
    @TimestampDateTimeConverter() required final DateTime createdAt,
  }) = _$TaskImpl;

  factory _Task.fromJson(Map<String, dynamic> json) = _$TaskImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get notes;
  @override
  List<String> get assignedUids;
  @override
  @NullableTimestampDateTimeConverter()
  DateTime? get dueDate;
  @override
  TaskPriority get priority;
  @override
  bool get completed;
  @override
  @TimestampDateTimeConverter()
  DateTime get createdAt;

  /// Create a copy of Task
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaskImplCopyWith<_$TaskImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
