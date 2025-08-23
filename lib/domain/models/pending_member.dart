import 'package:freezed_annotation/freezed_annotation.dart';

part 'pending_member.freezed.dart';
part 'pending_member.g.dart';

/// Model representing a family member who has been invited but not yet joined
/// This tracks the invitation process and allows for follow-up actions
@freezed
class PendingMember with _$PendingMember {
  const PendingMember._(); // Private constructor for getters
  
  const factory PendingMember({
    /// Unique identifier for the pending member
    required String id,
    /// ID of the invite this pending member is associated with
    required String inviteId,
    /// Email address of the invited person
    required String email,
    /// Display name for the invited person
    required String displayName,
    /// When the invitation was sent
    required DateTime invitedAt,
    /// Role that will be assigned when they join
    @Default('child') String role,
    /// ID of the family they're being invited to
    required String familyId,
    /// UID of the user who sent the invitation
    required String invitedByUid,
    /// Whether a reminder has been sent
    @Default(false) bool reminderSent,
    /// When the last reminder was sent (if any)
    DateTime? lastReminderSentAt,
    /// Number of reminders sent
    @Default(0) int reminderCount,
  }) = _PendingMember;

  factory PendingMember.fromJson(Map<String, dynamic> json) => _$PendingMemberFromJson(json);

  /// Creates a new pending member from an invite
  factory PendingMember.fromInvite({
    required String id,
    required String inviteId,
    required String email,
    required String displayName,
    required String familyId,
    required String invitedByUid,
    String role = 'child',
  }) {
    return PendingMember(
      id: id,
      inviteId: inviteId,
      email: email,
      displayName: displayName,
      invitedAt: DateTime.now(),
      role: role,
      familyId: familyId,
      invitedByUid: invitedByUid,
    );
  }

  /// Gets the number of days since the invitation was sent
  int get daysSinceInvited {
    final now = DateTime.now();
    return now.difference(invitedAt).inDays;
  }

  /// Checks if a reminder should be sent (after 3 days)
  bool get shouldSendReminder => 
      daysSinceInvited >= 3 && 
      !reminderSent && 
      reminderCount < 3;

  /// Gets a human-readable status description
  String get statusDescription {
    if (reminderCount >= 3) return 'Max reminders sent';
    if (reminderSent) return 'Reminder sent';
    if (daysSinceInvited >= 3) return 'Ready for reminder';
    return 'Recently invited';
  }

  /// Gets the appropriate action text for this pending member
  String get actionText {
    if (reminderCount >= 3) return 'Resend invite';
    if (reminderSent) return 'Send another reminder';
    if (daysSinceInvited >= 3) return 'Send reminder';
    return 'Wait for response';
  }
}
