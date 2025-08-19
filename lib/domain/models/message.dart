import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';
part 'message.g.dart';

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
class Message with _$Message {
  const factory Message({
    required String id,
    required String text,
    required String authorUid,
    required String authorName,
    @TimestampDateTimeConverter() required DateTime createdAt,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
}


