import 'package:freezed_annotation/freezed_annotation.dart';

part 'family_invite.freezed.dart';
part 'family_invite.g.dart';

/// Represents the current status of a family invite
enum InviteStatus {
  /// Invite is active and can be accepted
  active,
  /// Invite has been accepted by a user
  accepted,
  /// Invite has expired and can no longer be used
  expired,
  /// Invite has been revoked by the family owner
  revoked,
}

/// Model representing a family invitation
/// This handles the secure invitation process for adding new members to families
@freezed
class FamilyInvite with _$FamilyInvite {
  const FamilyInvite._(); // Private constructor for getters
  
  const factory FamilyInvite({
    /// Unique identifier for the invite
    required String id,
    /// ID of the family this invite is for
    required String familyId,
    /// Unique invite code that users enter to join
    required String inviteCode,
    /// When the invite was created
    required DateTime createdAt,
    /// When the invite expires (default: 7 days from creation)
    required DateTime expiresAt,
    /// UID of the user who created this invite
    required String createdByUid,
    /// Current status of the invite
    @Default(InviteStatus.active) InviteStatus status,
    /// UID of the user who accepted this invite (if accepted)
    String? acceptedByUid,
    /// When the invite was accepted (if accepted)
    DateTime? acceptedAt,
    /// Role that will be assigned when the invite is accepted
    @Default('child') String role,
    /// Maximum number of times this invite can be used (default: 1)
    @Default(1) int maxUses,
    /// Number of times this invite has been used
    @Default(0) int useCount,
  }) = _FamilyInvite;

  factory FamilyInvite.fromJson(Map<String, dynamic> json) => _$FamilyInviteFromJson(json);

  /// Creates a new invite with default expiration (7 days from now)
  factory FamilyInvite.create({
    required String id,
    required String familyId,
    required String inviteCode,
    required String createdByUid,
    String role = 'child',
    int maxUses = 1,
    int daysUntilExpiry = 7,
  }) {
    final now = DateTime.now();
    return FamilyInvite(
      id: id,
      familyId: familyId,
      inviteCode: inviteCode,
      createdAt: now,
      expiresAt: now.add(Duration(days: daysUntilExpiry)),
      createdByUid: createdByUid,
      role: role,
      maxUses: maxUses,
    );
  }

  /// Checks if the invite can still be used
  bool get canBeUsed => 
      status == InviteStatus.active && 
      DateTime.now().isBefore(expiresAt) && 
      useCount < maxUses;

  /// Checks if the invite has expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Gets the remaining days until expiry
  int get daysUntilExpiry {
    final now = DateTime.now();
    if (now.isAfter(expiresAt)) return 0;
    return expiresAt.difference(now).inDays;
  }

  /// Gets a human-readable status description
  String get statusDescription {
    switch (status) {
      case InviteStatus.active:
        if (isExpired) return 'Expired';
        if (useCount >= maxUses) return 'Used';
        return 'Active';
      case InviteStatus.accepted:
        return 'Accepted';
      case InviteStatus.expired:
        return 'Expired';
      case InviteStatus.revoked:
        return 'Revoked';
    }
  }
}
