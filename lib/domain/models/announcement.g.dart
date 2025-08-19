// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AnnouncementImpl _$$AnnouncementImplFromJson(Map<String, dynamic> json) =>
    _$AnnouncementImpl(
      id: json['id'] as String,
      text: json['text'] as String,
      authorUid: json['authorUid'] as String,
      authorName: json['authorName'] as String,
      createdAt: const TimestampDateTimeConverter().fromJson(json['createdAt']),
    );

Map<String, dynamic> _$$AnnouncementImplToJson(
  _$AnnouncementImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'text': instance.text,
  'authorUid': instance.authorUid,
  'authorName': instance.authorName,
  'createdAt': const TimestampDateTimeConverter().toJson(instance.createdAt),
};
