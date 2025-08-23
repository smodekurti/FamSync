import 'package:freezed_annotation/freezed_annotation.dart';

part 'family.freezed.dart';
part 'family.g.dart';

@freezed
class Family with _$Family {
  const Family._(); // Private constructor for getters
  
  const factory Family({
    required String id,
    required String name,
    @Default([]) List<String> memberUids,
    @Default({}) Map<String, String> roles, // uid -> role (parent/child)
    @Default({}) Map<String, String> colors, // uid -> hex/color name token
    String? inviteCode,
    @Default(10) int maxMembers, // Maximum number of family members allowed
    @Default(true) bool allowInvites, // Whether the family allows new invites
    DateTime? createdAt, // When the family was created
    @Default('') String ownerUid, // UID of the family owner/creator
  }) = _Family;

  factory Family.fromJson(Map<String, dynamic> json) => _$FamilyFromJson(json);

  /// Creates a new family with the owner as the first member
  factory Family.create({
    required String id,
    required String name,
    required String ownerUid,
    int maxMembers = 10,
  }) {
    return Family(
      id: id,
      name: name,
      memberUids: [ownerUid],
      roles: {ownerUid: 'parent'},
      ownerUid: ownerUid,
      maxMembers: maxMembers,
      allowInvites: true,
      createdAt: DateTime.now(),
    );
  }

  /// Checks if the family can accept new members
  bool get canAcceptMembers => 
      memberUids.length < maxMembers && 
      allowInvites;

  /// Gets the number of available member slots
  int get availableMemberSlots => maxMembers - memberUids.length;

  /// Checks if a user is the owner of the family
  bool isOwner(String uid) => ownerUid == uid;

  /// Checks if a user is a parent in the family
  bool isParent(String uid) => roles[uid] == 'parent';

  /// Checks if a user can create invites (owners and parents)
  bool canCreateInvites(String uid) => isOwner(uid) || isParent(uid);

  /// Gets the role of a user in the family
  String? getUserRole(String uid) => roles[uid];

  /// Gets the color assigned to a user
  String? getUserColor(String uid) => colors[uid];
}


