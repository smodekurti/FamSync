import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fam_sync/domain/models/family.dart' as models;

part 'invite_validation_result.freezed.dart';
part 'invite_validation_result.g.dart';

/// Result of validating an invite code
/// This provides detailed information about the invite status and family details
@freezed
class InviteValidationResult with _$InviteValidationResult {
  const InviteValidationResult._(); // Private constructor for getters
  
  const factory InviteValidationResult({
    /// Whether the invite code is valid and can be used
    required bool isValid,
    /// The family object if valid
    required models.Family? family,
    /// The invite ID if valid
    required String? inviteId,
    /// Error message if validation failed
    String? errorMessage,
    /// Specific validation error type
    InviteValidationError? errorType,
    /// Whether the current user is already a member of this family
    @Default(false) bool isAlreadyMember,
    /// Whether the family has reached its member limit
    @Default(false) bool isFamilyFull,
    /// Whether the invite has expired
    @Default(false) bool isExpired,
    /// Whether the invite has already been used
    @Default(false) bool isAlreadyUsed,
    /// Whether the invite has been revoked
    @Default(false) bool isRevoked,
  }) = _InviteValidationResult;

  factory InviteValidationResult.fromJson(Map<String, dynamic> json) => _$InviteValidationResultFromJson(json);

  /// Creates a successful validation result
  factory InviteValidationResult.success({
    required models.Family family,
    required String inviteId,
  }) {
    return InviteValidationResult(
      isValid: true,
      family: family,
      inviteId: inviteId,
    );
  }

  /// Creates a failed validation result
  factory InviteValidationResult.failure({
    required String errorMessage,
    required InviteValidationError errorType,
    models.Family? family,
    String? inviteId,
    bool isAlreadyMember = false,
    bool isFamilyFull = false,
    bool isExpired = false,
    bool isAlreadyUsed = false,
    bool isRevoked = false,
  }) {
    return InviteValidationResult(
      isValid: false,
      family: family,
      inviteId: inviteId,
      errorMessage: errorMessage,
      errorType: errorType,
      isAlreadyMember: isAlreadyMember,
      isFamilyFull: isFamilyFull,
      isExpired: isExpired,
      isAlreadyUsed: isAlreadyUsed,
      isRevoked: isRevoked,
    );
  }

  /// Gets a user-friendly error message
  String get userFriendlyErrorMessage {
    if (isValid) return '';
    
    switch (errorType) {
      case InviteValidationError.invalidCode:
        return 'Invalid invite code. Please check and try again.';
      case InviteValidationError.expired:
        return 'This invite has expired. Please request a new one.';
      case InviteValidationError.alreadyUsed:
        return 'This invite has already been used.';
      case InviteValidationError.revoked:
        return 'This invite has been revoked by the family owner.';
      case InviteValidationError.alreadyMember:
        return 'You are already a member of this family.';
      case InviteValidationError.familyFull:
        return 'This family has reached its member limit.';
      case InviteValidationError.familyNotFound:
        return 'Family not found. The invite may be invalid.';
      case InviteValidationError.unknown:
        return errorMessage ?? 'An unknown error occurred.';
      case null:
        return errorMessage ?? 'Validation failed.';
    }
  }
}



/// Types of validation errors that can occur
enum InviteValidationError {
  /// The invite code is invalid or doesn't exist
  invalidCode,
  /// The invite has expired
  expired,
  /// The invite has already been used
  alreadyUsed,
  /// The invite has been revoked
  revoked,
  /// User is already a member of the family
  alreadyMember,
  /// Family has reached its member limit
  familyFull,
  /// Family not found
  familyNotFound,
  /// Unknown error occurred
  unknown,
}
