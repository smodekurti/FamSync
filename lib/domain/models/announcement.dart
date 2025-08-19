import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'announcement.freezed.dart';
part 'announcement.g.dart';

/// Converts Firestore Timestamp <-> DateTime for (de)serialization
class TimestampDateTimeConverter implements JsonConverter<DateTime, Object?> {
  const TimestampDateTimeConverter();

  @override
  DateTime fromJson(Object? json) {
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.parse(json);
    if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);
    throw ArgumentError('Unsupported timestamp type: ${json.runtimeType}');
  }

  @override
  Object toJson(DateTime object) => Timestamp.fromDate(object);
}

@freezed
class Announcement with _$Announcement {
  const factory Announcement({
    required String id,
    required String text,
    required String authorUid,
    required String authorName,
    @TimestampDateTimeConverter() required DateTime createdAt,
  }) = _Announcement;

  factory Announcement.fromJson(Map<String, dynamic> json) =>
      _$AnnouncementFromJson(json);
}
