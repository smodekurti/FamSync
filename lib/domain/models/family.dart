import 'package:freezed_annotation/freezed_annotation.dart';

part 'family.freezed.dart';
part 'family.g.dart';

@freezed
class Family with _$Family {
  const factory Family({
    required String id,
    required String name,
    @Default([]) List<String> memberUids,
    @Default({}) Map<String, String> roles, // uid -> role (parent/child)
    @Default({}) Map<String, String> colors, // uid -> hex/color name token
    String? inviteCode,
  }) = _Family;

  factory Family.fromJson(Map<String, dynamic> json) => _$FamilyFromJson(json);
}


