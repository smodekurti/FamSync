// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MessageImpl _$$MessageImplFromJson(Map<String, dynamic> json) =>
    _$MessageImpl(
      id: json['id'] as String,
      text: json['text'] as String,
      authorUid: json['authorUid'] as String,
      authorName: json['authorName'] as String,
      authorPhotoUrl: json['authorPhotoUrl'] as String?,
      createdAt: const TimestampDateTimeConverter().fromJson(json['createdAt']),
    );

Map<String, dynamic> _$$MessageImplToJson(
  _$MessageImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'text': instance.text,
  'authorUid': instance.authorUid,
  'authorName': instance.authorName,
  'authorPhotoUrl': instance.authorPhotoUrl,
  'createdAt': const TimestampDateTimeConverter().toJson(instance.createdAt),
};
