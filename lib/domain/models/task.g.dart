// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TaskImpl _$$TaskImplFromJson(Map<String, dynamic> json) => _$TaskImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  notes: json['notes'] as String? ?? '',
  assignedUids:
      (json['assignedUids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  dueDate: const NullableTimestampDateTimeConverter().fromJson(json['dueDate']),
  priority:
      $enumDecodeNullable(_$TaskPriorityEnumMap, json['priority']) ??
      TaskPriority.medium,
  completed: json['completed'] as bool? ?? false,
  createdAt: const TimestampDateTimeConverter().fromJson(json['createdAt']),
);

Map<String, dynamic> _$$TaskImplToJson(
  _$TaskImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'notes': instance.notes,
  'assignedUids': instance.assignedUids,
  'dueDate': const NullableTimestampDateTimeConverter().toJson(
    instance.dueDate,
  ),
  'priority': _$TaskPriorityEnumMap[instance.priority]!,
  'completed': instance.completed,
  'createdAt': const TimestampDateTimeConverter().toJson(instance.createdAt),
};

const _$TaskPriorityEnumMap = {
  TaskPriority.low: 'low',
  TaskPriority.medium: 'medium',
  TaskPriority.high: 'high',
};
