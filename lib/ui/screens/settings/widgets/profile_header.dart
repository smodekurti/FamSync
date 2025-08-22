import 'package:flutter/material.dart';
import 'package:fam_sync/theme/app_theme.dart';
import 'package:fam_sync/domain/models/user_profile.dart';
import 'package:fam_sync/domain/models/family.dart' as models;

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.profile,
    this.family,
  });

  final UserProfile profile;
  final models.Family? family;

  @override
  Widget build(BuildContext context) {
    final spaces = context.spaces;
    final colors = context.colors;

    return Card(
      elevation: 0,
      color: colors.primaryContainer,
      child: Padding(
        padding: EdgeInsets.all(spaces.lg),
        child: Row(
          children: [
            // Profile Avatar
            Container(
              width: spaces.xxl * 2,
              height: spaces.xxl * 2,
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  profile.displayName.isNotEmpty 
                      ? profile.displayName[0].toUpperCase() 
                      : '?',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            SizedBox(width: spaces.md),
            
            // Profile Information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.displayName.isNotEmpty 
                        ? profile.displayName 
                        : 'User',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.onPrimary,
                    ),
                  ),
                  SizedBox(height: spaces.xs),
                  Text(
                    profile.email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                  SizedBox(height: spaces.xs),
                  Row(
                    children: [
                      Icon(
                        Icons.family_restroom,
                        size: spaces.sm,
                        color: colors.onPrimaryContainer,
                      ),
                      SizedBox(width: spaces.xs / 2),
                      Text(
                        family?.name ?? 'Family',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                      SizedBox(width: spaces.xs),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: spaces.xs,
                          vertical: spaces.xs / 2,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(spaces.xs),
                        ),
                        child: Text(
                          profile.role.name.toUpperCase(),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colors.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Edit Button
            IconButton(
              onPressed: () {
                // TODO: Navigate to profile editing
              },
              icon: Icon(
                Icons.edit,
                color: colors.onPrimary,
                size: spaces.md,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
