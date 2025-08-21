// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EventImpl _$$EventImplFromJson(Map<String, dynamic> json) => _$EventImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String? ?? '',
  startTime: DateTime.parse(json['startTime'] as String),
  endTime: DateTime.parse(json['endTime'] as String),
  assignedUids:
      (json['assignedUids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  category:
      $enumDecodeNullable(_$EventCategoryEnumMap, json['category']) ??
      EventCategory.family,
  priority:
      $enumDecodeNullable(_$EventPriorityEnumMap, json['priority']) ??
      EventPriority.medium,
  location: json['location'] as String?,
  isRecurring: json['isRecurring'] as bool? ?? false,
  recurrence: json['recurrence'] == null
      ? null
      : RecurrencePattern.fromJson(json['recurrence'] as Map<String, dynamic>),
  familyId: json['familyId'] as String,
  createdByUid: json['createdByUid'] as String,
  createdAt: const TimestampDateTimeConverter().fromJson(
    json['createdAt'] as Timestamp,
  ),
  updatedAt: const TimestampDateTimeConverter().fromJson(
    json['updatedAt'] as Timestamp,
  ),
  participants:
      (json['participants'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  status:
      $enumDecodeNullable(_$EventStatusEnumMap, json['status']) ??
      EventStatus.scheduled,
  notes: json['notes'] as String?,
  attachments:
      (json['attachments'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
);

Map<String, dynamic> _$$EventImplToJson(
  _$EventImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'startTime': instance.startTime.toIso8601String(),
  'endTime': instance.endTime.toIso8601String(),
  'assignedUids': instance.assignedUids,
  'category': _$EventCategoryEnumMap[instance.category]!,
  'priority': _$EventPriorityEnumMap[instance.priority]!,
  'location': instance.location,
  'isRecurring': instance.isRecurring,
  'recurrence': instance.recurrence,
  'familyId': instance.familyId,
  'createdByUid': instance.createdByUid,
  'createdAt': const TimestampDateTimeConverter().toJson(instance.createdAt),
  'updatedAt': const TimestampDateTimeConverter().toJson(instance.updatedAt),
  'participants': instance.participants,
  'status': _$EventStatusEnumMap[instance.status]!,
  'notes': instance.notes,
  'attachments': instance.attachments,
};

const _$EventCategoryEnumMap = {
  EventCategory.school: 'school',
  EventCategory.work: 'work',
  EventCategory.family: 'family',
  EventCategory.personal: 'personal',
  EventCategory.medical: 'medical',
  EventCategory.sports: 'sports',
  EventCategory.travel: 'travel',
  EventCategory.other: 'other',
};

const _$EventPriorityEnumMap = {
  EventPriority.low: 'low',
  EventPriority.medium: 'medium',
  EventPriority.high: 'high',
  EventPriority.urgent: 'urgent',
};

const _$EventStatusEnumMap = {
  EventStatus.scheduled: 'scheduled',
  EventStatus.confirmed: 'confirmed',
  EventStatus.cancelled: 'cancelled',
  EventStatus.completed: 'completed',
};

_$RecurrencePatternImpl _$$RecurrencePatternImplFromJson(
  Map<String, dynamic> json,
) => _$RecurrencePatternImpl(
  type: $enumDecode(_$RecurrenceTypeEnumMap, json['type']),
  interval: (json['interval'] as num).toInt(),
  daysOfWeek:
      (json['daysOfWeek'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const <int>[],
  daysOfMonth:
      (json['daysOfMonth'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const <int>[],
  monthsOfYear:
      (json['monthsOfYear'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const <int>[],
  endDate: json['endDate'] == null
      ? null
      : DateTime.parse(json['endDate'] as String),
  maxOccurrences: (json['maxOccurrences'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$RecurrencePatternImplToJson(
  _$RecurrencePatternImpl instance,
) => <String, dynamic>{
  'type': _$RecurrenceTypeEnumMap[instance.type]!,
  'interval': instance.interval,
  'daysOfWeek': instance.daysOfWeek,
  'daysOfMonth': instance.daysOfMonth,
  'monthsOfYear': instance.monthsOfYear,
  'endDate': instance.endDate?.toIso8601String(),
  'maxOccurrences': instance.maxOccurrences,
};

const _$RecurrenceTypeEnumMap = {
  RecurrenceType.daily: 'daily',
  RecurrenceType.weekly: 'weekly',
  RecurrenceType.monthly: 'monthly',
  RecurrenceType.yearly: 'yearly',
};
