import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'task.freezed.dart';
part 'task.g.dart';

enum TaskPriority { low, medium, high }

class TimestampDateTimeConverter implements JsonConverter<DateTime, Object?> {
  const TimestampDateTimeConverter();

  @override
  DateTime fromJson(Object? json) {
    if (json == null) return DateTime.now();
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.parse(json);
    if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);
    throw ArgumentError('Unsupported timestamp type: ${json.runtimeType}');
  }

  @override
  Object toJson(DateTime object) => Timestamp.fromDate(object);
}

class NullableTimestampDateTimeConverter
    implements JsonConverter<DateTime?, Object?> {
  const NullableTimestampDateTimeConverter();

  @override
  DateTime? fromJson(Object? json) {
    if (json == null) return null;
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.parse(json);
    if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);
    throw ArgumentError('Unsupported timestamp type: ${json.runtimeType}');
  }

  @override
  Object? toJson(DateTime? object) =>
      object == null ? null : Timestamp.fromDate(object);
}

@freezed
class Task with _$Task {
  const factory Task({
    required String id,
    required String title,
    @Default('') String notes,
    @Default(<String>[]) List<String> assignedUids,
    @NullableTimestampDateTimeConverter() DateTime? dueDate,
    @Default(TaskPriority.medium) TaskPriority priority,
    @Default(false) bool completed,
    @TimestampDateTimeConverter() required DateTime createdAt,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
}


