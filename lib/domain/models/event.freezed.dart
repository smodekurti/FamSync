// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Event _$EventFromJson(Map<String, dynamic> json) {
  return _Event.fromJson(json);
}

/// @nodoc
mixin _$Event {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  DateTime get startTime => throw _privateConstructorUsedError;
  DateTime get endTime => throw _privateConstructorUsedError;
  List<String> get assignedUids => throw _privateConstructorUsedError;
  EventCategory get category => throw _privateConstructorUsedError;
  EventPriority get priority => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  bool get isRecurring => throw _privateConstructorUsedError;
  RecurrencePattern? get recurrence => throw _privateConstructorUsedError;
  String get familyId => throw _privateConstructorUsedError;
  String get createdByUid => throw _privateConstructorUsedError;
  @TimestampDateTimeConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @TimestampDateTimeConverter()
  DateTime get updatedAt => throw _privateConstructorUsedError;
  List<String> get participants => throw _privateConstructorUsedError;
  EventStatus get status => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  List<String> get attachments => throw _privateConstructorUsedError;

  /// Serializes this Event to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EventCopyWith<Event> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventCopyWith<$Res> {
  factory $EventCopyWith(Event value, $Res Function(Event) then) =
      _$EventCopyWithImpl<$Res, Event>;
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    DateTime startTime,
    DateTime endTime,
    List<String> assignedUids,
    EventCategory category,
    EventPriority priority,
    String? location,
    bool isRecurring,
    RecurrencePattern? recurrence,
    String familyId,
    String createdByUid,
    @TimestampDateTimeConverter() DateTime createdAt,
    @TimestampDateTimeConverter() DateTime updatedAt,
    List<String> participants,
    EventStatus status,
    String? notes,
    List<String> attachments,
  });

  $RecurrencePatternCopyWith<$Res>? get recurrence;
}

/// @nodoc
class _$EventCopyWithImpl<$Res, $Val extends Event>
    implements $EventCopyWith<$Res> {
  _$EventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? assignedUids = null,
    Object? category = null,
    Object? priority = null,
    Object? location = freezed,
    Object? isRecurring = null,
    Object? recurrence = freezed,
    Object? familyId = null,
    Object? createdByUid = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? participants = null,
    Object? status = null,
    Object? notes = freezed,
    Object? attachments = null,
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
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            startTime: null == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endTime: null == endTime
                ? _value.endTime
                : endTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            assignedUids: null == assignedUids
                ? _value.assignedUids
                : assignedUids // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as EventCategory,
            priority: null == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                      as EventPriority,
            location: freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as String?,
            isRecurring: null == isRecurring
                ? _value.isRecurring
                : isRecurring // ignore: cast_nullable_to_non_nullable
                      as bool,
            recurrence: freezed == recurrence
                ? _value.recurrence
                : recurrence // ignore: cast_nullable_to_non_nullable
                      as RecurrencePattern?,
            familyId: null == familyId
                ? _value.familyId
                : familyId // ignore: cast_nullable_to_non_nullable
                      as String,
            createdByUid: null == createdByUid
                ? _value.createdByUid
                : createdByUid // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            participants: null == participants
                ? _value.participants
                : participants // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as EventStatus,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            attachments: null == attachments
                ? _value.attachments
                : attachments // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RecurrencePatternCopyWith<$Res>? get recurrence {
    if (_value.recurrence == null) {
      return null;
    }

    return $RecurrencePatternCopyWith<$Res>(_value.recurrence!, (value) {
      return _then(_value.copyWith(recurrence: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$EventImplCopyWith<$Res> implements $EventCopyWith<$Res> {
  factory _$$EventImplCopyWith(
    _$EventImpl value,
    $Res Function(_$EventImpl) then,
  ) = __$$EventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    DateTime startTime,
    DateTime endTime,
    List<String> assignedUids,
    EventCategory category,
    EventPriority priority,
    String? location,
    bool isRecurring,
    RecurrencePattern? recurrence,
    String familyId,
    String createdByUid,
    @TimestampDateTimeConverter() DateTime createdAt,
    @TimestampDateTimeConverter() DateTime updatedAt,
    List<String> participants,
    EventStatus status,
    String? notes,
    List<String> attachments,
  });

  @override
  $RecurrencePatternCopyWith<$Res>? get recurrence;
}

/// @nodoc
class __$$EventImplCopyWithImpl<$Res>
    extends _$EventCopyWithImpl<$Res, _$EventImpl>
    implements _$$EventImplCopyWith<$Res> {
  __$$EventImplCopyWithImpl(
    _$EventImpl _value,
    $Res Function(_$EventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? assignedUids = null,
    Object? category = null,
    Object? priority = null,
    Object? location = freezed,
    Object? isRecurring = null,
    Object? recurrence = freezed,
    Object? familyId = null,
    Object? createdByUid = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? participants = null,
    Object? status = null,
    Object? notes = freezed,
    Object? attachments = null,
  }) {
    return _then(
      _$EventImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        startTime: null == startTime
            ? _value.startTime
            : startTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endTime: null == endTime
            ? _value.endTime
            : endTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        assignedUids: null == assignedUids
            ? _value._assignedUids
            : assignedUids // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as EventCategory,
        priority: null == priority
            ? _value.priority
            : priority // ignore: cast_nullable_to_non_nullable
                  as EventPriority,
        location: freezed == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String?,
        isRecurring: null == isRecurring
            ? _value.isRecurring
            : isRecurring // ignore: cast_nullable_to_non_nullable
                  as bool,
        recurrence: freezed == recurrence
            ? _value.recurrence
            : recurrence // ignore: cast_nullable_to_non_nullable
                  as RecurrencePattern?,
        familyId: null == familyId
            ? _value.familyId
            : familyId // ignore: cast_nullable_to_non_nullable
                  as String,
        createdByUid: null == createdByUid
            ? _value.createdByUid
            : createdByUid // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        participants: null == participants
            ? _value._participants
            : participants // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as EventStatus,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        attachments: null == attachments
            ? _value._attachments
            : attachments // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EventImpl implements _Event {
  const _$EventImpl({
    required this.id,
    required this.title,
    this.description = '',
    required this.startTime,
    required this.endTime,
    final List<String> assignedUids = const <String>[],
    this.category = EventCategory.family,
    this.priority = EventPriority.medium,
    this.location,
    this.isRecurring = false,
    this.recurrence,
    required this.familyId,
    required this.createdByUid,
    @TimestampDateTimeConverter() required this.createdAt,
    @TimestampDateTimeConverter() required this.updatedAt,
    final List<String> participants = const <String>[],
    this.status = EventStatus.scheduled,
    this.notes,
    final List<String> attachments = const <String>[],
  }) : _assignedUids = assignedUids,
       _participants = participants,
       _attachments = attachments;

  factory _$EventImpl.fromJson(Map<String, dynamic> json) =>
      _$$EventImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  @JsonKey()
  final String description;
  @override
  final DateTime startTime;
  @override
  final DateTime endTime;
  final List<String> _assignedUids;
  @override
  @JsonKey()
  List<String> get assignedUids {
    if (_assignedUids is EqualUnmodifiableListView) return _assignedUids;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_assignedUids);
  }

  @override
  @JsonKey()
  final EventCategory category;
  @override
  @JsonKey()
  final EventPriority priority;
  @override
  final String? location;
  @override
  @JsonKey()
  final bool isRecurring;
  @override
  final RecurrencePattern? recurrence;
  @override
  final String familyId;
  @override
  final String createdByUid;
  @override
  @TimestampDateTimeConverter()
  final DateTime createdAt;
  @override
  @TimestampDateTimeConverter()
  final DateTime updatedAt;
  final List<String> _participants;
  @override
  @JsonKey()
  List<String> get participants {
    if (_participants is EqualUnmodifiableListView) return _participants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_participants);
  }

  @override
  @JsonKey()
  final EventStatus status;
  @override
  final String? notes;
  final List<String> _attachments;
  @override
  @JsonKey()
  List<String> get attachments {
    if (_attachments is EqualUnmodifiableListView) return _attachments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_attachments);
  }

  @override
  String toString() {
    return 'Event(id: $id, title: $title, description: $description, startTime: $startTime, endTime: $endTime, assignedUids: $assignedUids, category: $category, priority: $priority, location: $location, isRecurring: $isRecurring, recurrence: $recurrence, familyId: $familyId, createdByUid: $createdByUid, createdAt: $createdAt, updatedAt: $updatedAt, participants: $participants, status: $status, notes: $notes, attachments: $attachments)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EventImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            const DeepCollectionEquality().equals(
              other._assignedUids,
              _assignedUids,
            ) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.isRecurring, isRecurring) ||
                other.isRecurring == isRecurring) &&
            (identical(other.recurrence, recurrence) ||
                other.recurrence == recurrence) &&
            (identical(other.familyId, familyId) ||
                other.familyId == familyId) &&
            (identical(other.createdByUid, createdByUid) ||
                other.createdByUid == createdByUid) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(
              other._participants,
              _participants,
            ) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            const DeepCollectionEquality().equals(
              other._attachments,
              _attachments,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    title,
    description,
    startTime,
    endTime,
    const DeepCollectionEquality().hash(_assignedUids),
    category,
    priority,
    location,
    isRecurring,
    recurrence,
    familyId,
    createdByUid,
    createdAt,
    updatedAt,
    const DeepCollectionEquality().hash(_participants),
    status,
    notes,
    const DeepCollectionEquality().hash(_attachments),
  ]);

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EventImplCopyWith<_$EventImpl> get copyWith =>
      __$$EventImplCopyWithImpl<_$EventImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EventImplToJson(this);
  }
}

abstract class _Event implements Event {
  const factory _Event({
    required final String id,
    required final String title,
    final String description,
    required final DateTime startTime,
    required final DateTime endTime,
    final List<String> assignedUids,
    final EventCategory category,
    final EventPriority priority,
    final String? location,
    final bool isRecurring,
    final RecurrencePattern? recurrence,
    required final String familyId,
    required final String createdByUid,
    @TimestampDateTimeConverter() required final DateTime createdAt,
    @TimestampDateTimeConverter() required final DateTime updatedAt,
    final List<String> participants,
    final EventStatus status,
    final String? notes,
    final List<String> attachments,
  }) = _$EventImpl;

  factory _Event.fromJson(Map<String, dynamic> json) = _$EventImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  DateTime get startTime;
  @override
  DateTime get endTime;
  @override
  List<String> get assignedUids;
  @override
  EventCategory get category;
  @override
  EventPriority get priority;
  @override
  String? get location;
  @override
  bool get isRecurring;
  @override
  RecurrencePattern? get recurrence;
  @override
  String get familyId;
  @override
  String get createdByUid;
  @override
  @TimestampDateTimeConverter()
  DateTime get createdAt;
  @override
  @TimestampDateTimeConverter()
  DateTime get updatedAt;
  @override
  List<String> get participants;
  @override
  EventStatus get status;
  @override
  String? get notes;
  @override
  List<String> get attachments;

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EventImplCopyWith<_$EventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RecurrencePattern _$RecurrencePatternFromJson(Map<String, dynamic> json) {
  return _RecurrencePattern.fromJson(json);
}

/// @nodoc
mixin _$RecurrencePattern {
  RecurrenceType get type => throw _privateConstructorUsedError;
  int get interval => throw _privateConstructorUsedError;
  List<int> get daysOfWeek => throw _privateConstructorUsedError;
  List<int> get daysOfMonth => throw _privateConstructorUsedError;
  List<int> get monthsOfYear => throw _privateConstructorUsedError;
  DateTime? get endDate => throw _privateConstructorUsedError;
  int get maxOccurrences => throw _privateConstructorUsedError;

  /// Serializes this RecurrencePattern to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecurrencePattern
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecurrencePatternCopyWith<RecurrencePattern> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecurrencePatternCopyWith<$Res> {
  factory $RecurrencePatternCopyWith(
    RecurrencePattern value,
    $Res Function(RecurrencePattern) then,
  ) = _$RecurrencePatternCopyWithImpl<$Res, RecurrencePattern>;
  @useResult
  $Res call({
    RecurrenceType type,
    int interval,
    List<int> daysOfWeek,
    List<int> daysOfMonth,
    List<int> monthsOfYear,
    DateTime? endDate,
    int maxOccurrences,
  });
}

/// @nodoc
class _$RecurrencePatternCopyWithImpl<$Res, $Val extends RecurrencePattern>
    implements $RecurrencePatternCopyWith<$Res> {
  _$RecurrencePatternCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecurrencePattern
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? interval = null,
    Object? daysOfWeek = null,
    Object? daysOfMonth = null,
    Object? monthsOfYear = null,
    Object? endDate = freezed,
    Object? maxOccurrences = null,
  }) {
    return _then(
      _value.copyWith(
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as RecurrenceType,
            interval: null == interval
                ? _value.interval
                : interval // ignore: cast_nullable_to_non_nullable
                      as int,
            daysOfWeek: null == daysOfWeek
                ? _value.daysOfWeek
                : daysOfWeek // ignore: cast_nullable_to_non_nullable
                      as List<int>,
            daysOfMonth: null == daysOfMonth
                ? _value.daysOfMonth
                : daysOfMonth // ignore: cast_nullable_to_non_nullable
                      as List<int>,
            monthsOfYear: null == monthsOfYear
                ? _value.monthsOfYear
                : monthsOfYear // ignore: cast_nullable_to_non_nullable
                      as List<int>,
            endDate: freezed == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            maxOccurrences: null == maxOccurrences
                ? _value.maxOccurrences
                : maxOccurrences // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RecurrencePatternImplCopyWith<$Res>
    implements $RecurrencePatternCopyWith<$Res> {
  factory _$$RecurrencePatternImplCopyWith(
    _$RecurrencePatternImpl value,
    $Res Function(_$RecurrencePatternImpl) then,
  ) = __$$RecurrencePatternImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    RecurrenceType type,
    int interval,
    List<int> daysOfWeek,
    List<int> daysOfMonth,
    List<int> monthsOfYear,
    DateTime? endDate,
    int maxOccurrences,
  });
}

/// @nodoc
class __$$RecurrencePatternImplCopyWithImpl<$Res>
    extends _$RecurrencePatternCopyWithImpl<$Res, _$RecurrencePatternImpl>
    implements _$$RecurrencePatternImplCopyWith<$Res> {
  __$$RecurrencePatternImplCopyWithImpl(
    _$RecurrencePatternImpl _value,
    $Res Function(_$RecurrencePatternImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RecurrencePattern
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? interval = null,
    Object? daysOfWeek = null,
    Object? daysOfMonth = null,
    Object? monthsOfYear = null,
    Object? endDate = freezed,
    Object? maxOccurrences = null,
  }) {
    return _then(
      _$RecurrencePatternImpl(
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as RecurrenceType,
        interval: null == interval
            ? _value.interval
            : interval // ignore: cast_nullable_to_non_nullable
                  as int,
        daysOfWeek: null == daysOfWeek
            ? _value._daysOfWeek
            : daysOfWeek // ignore: cast_nullable_to_non_nullable
                  as List<int>,
        daysOfMonth: null == daysOfMonth
            ? _value._daysOfMonth
            : daysOfMonth // ignore: cast_nullable_to_non_nullable
                  as List<int>,
        monthsOfYear: null == monthsOfYear
            ? _value._monthsOfYear
            : monthsOfYear // ignore: cast_nullable_to_non_nullable
                  as List<int>,
        endDate: freezed == endDate
            ? _value.endDate
            : endDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        maxOccurrences: null == maxOccurrences
            ? _value.maxOccurrences
            : maxOccurrences // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RecurrencePatternImpl implements _RecurrencePattern {
  const _$RecurrencePatternImpl({
    required this.type,
    required this.interval,
    final List<int> daysOfWeek = const <int>[],
    final List<int> daysOfMonth = const <int>[],
    final List<int> monthsOfYear = const <int>[],
    this.endDate,
    this.maxOccurrences = 0,
  }) : _daysOfWeek = daysOfWeek,
       _daysOfMonth = daysOfMonth,
       _monthsOfYear = monthsOfYear;

  factory _$RecurrencePatternImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecurrencePatternImplFromJson(json);

  @override
  final RecurrenceType type;
  @override
  final int interval;
  final List<int> _daysOfWeek;
  @override
  @JsonKey()
  List<int> get daysOfWeek {
    if (_daysOfWeek is EqualUnmodifiableListView) return _daysOfWeek;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_daysOfWeek);
  }

  final List<int> _daysOfMonth;
  @override
  @JsonKey()
  List<int> get daysOfMonth {
    if (_daysOfMonth is EqualUnmodifiableListView) return _daysOfMonth;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_daysOfMonth);
  }

  final List<int> _monthsOfYear;
  @override
  @JsonKey()
  List<int> get monthsOfYear {
    if (_monthsOfYear is EqualUnmodifiableListView) return _monthsOfYear;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_monthsOfYear);
  }

  @override
  final DateTime? endDate;
  @override
  @JsonKey()
  final int maxOccurrences;

  @override
  String toString() {
    return 'RecurrencePattern(type: $type, interval: $interval, daysOfWeek: $daysOfWeek, daysOfMonth: $daysOfMonth, monthsOfYear: $monthsOfYear, endDate: $endDate, maxOccurrences: $maxOccurrences)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecurrencePatternImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.interval, interval) ||
                other.interval == interval) &&
            const DeepCollectionEquality().equals(
              other._daysOfWeek,
              _daysOfWeek,
            ) &&
            const DeepCollectionEquality().equals(
              other._daysOfMonth,
              _daysOfMonth,
            ) &&
            const DeepCollectionEquality().equals(
              other._monthsOfYear,
              _monthsOfYear,
            ) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.maxOccurrences, maxOccurrences) ||
                other.maxOccurrences == maxOccurrences));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    type,
    interval,
    const DeepCollectionEquality().hash(_daysOfWeek),
    const DeepCollectionEquality().hash(_daysOfMonth),
    const DeepCollectionEquality().hash(_monthsOfYear),
    endDate,
    maxOccurrences,
  );

  /// Create a copy of RecurrencePattern
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecurrencePatternImplCopyWith<_$RecurrencePatternImpl> get copyWith =>
      __$$RecurrencePatternImplCopyWithImpl<_$RecurrencePatternImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RecurrencePatternImplToJson(this);
  }
}

abstract class _RecurrencePattern implements RecurrencePattern {
  const factory _RecurrencePattern({
    required final RecurrenceType type,
    required final int interval,
    final List<int> daysOfWeek,
    final List<int> daysOfMonth,
    final List<int> monthsOfYear,
    final DateTime? endDate,
    final int maxOccurrences,
  }) = _$RecurrencePatternImpl;

  factory _RecurrencePattern.fromJson(Map<String, dynamic> json) =
      _$RecurrencePatternImpl.fromJson;

  @override
  RecurrenceType get type;
  @override
  int get interval;
  @override
  List<int> get daysOfWeek;
  @override
  List<int> get daysOfMonth;
  @override
  List<int> get monthsOfYear;
  @override
  DateTime? get endDate;
  @override
  int get maxOccurrences;

  /// Create a copy of RecurrencePattern
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecurrencePatternImplCopyWith<_$RecurrencePatternImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
