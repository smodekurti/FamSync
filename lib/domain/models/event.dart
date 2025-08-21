import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'event.freezed.dart';
part 'event.g.dart';

@freezed
class Event with _$Event {
  const factory Event({
    required String id,
    required String title,
    @Default('') String description,
    required DateTime startTime,
    required DateTime endTime,
    @Default(<String>[]) List<String> assignedUids,
    @Default(EventCategory.family) EventCategory category,
    @Default(EventPriority.medium) EventPriority priority,
    String? location,
    @Default(false) bool isRecurring,
    RecurrencePattern? recurrence,
    required String familyId,
    required String createdByUid,
    @TimestampDateTimeConverter() required DateTime createdAt,
    @TimestampDateTimeConverter() required DateTime updatedAt,
    @Default(<String>[]) List<String> participants,
    @Default(EventStatus.scheduled) EventStatus status,
    String? notes,
    @Default(<String>[]) List<String> attachments,
  }) = _Event;

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
}

enum EventCategory {
  school,
  work,
  family,
  personal,
  medical,
  sports,
  travel,
  other
}

enum EventPriority {
  low,
  medium,
  high,
  urgent
}

enum EventStatus {
  scheduled,
  confirmed,
  cancelled,
  completed
}

@freezed
class RecurrencePattern with _$RecurrencePattern {
  const factory RecurrencePattern({
    required RecurrenceType type,
    required int interval,
    @Default(<int>[]) List<int> daysOfWeek,
    @Default(<int>[]) List<int> daysOfMonth,
    @Default(<int>[]) List<int> monthsOfYear,
    DateTime? endDate,
    @Default(0) int maxOccurrences,
  }) = _RecurrencePattern;

  factory RecurrencePattern.fromJson(Map<String, dynamic> json) => _$RecurrencePatternFromJson(json);
}

enum RecurrenceType {
  daily,
  weekly,
  monthly,
  yearly
}

class TimestampDateTimeConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampDateTimeConverter();

  @override
  DateTime fromJson(Timestamp timestamp) => timestamp.toDate();

  @override
  Timestamp toJson(DateTime date) => Timestamp.fromDate(date);
}
