import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fam_sync/data/auth/auth_repository.dart';
import 'package:fam_sync/data/family/family_repository.dart';

class FamilyAppBarTitle extends ConsumerWidget {
  const FamilyAppBarTitle({super.key, this.fallback = 'Family'});
  final String fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileStreamProvider);
    return profileAsync.when(
      data: (profile) {
        final fid = profile?.familyId;
        if (fid == null) return Text(fallback);
        final famAsync = ref.watch(familyStreamProvider(fid));
        return famAsync.when(
          data: (fam) => Text(fam?.name ?? fallback),
          error: (_, __) => Text(fallback),
          loading: () => Text(fallback),
        );
      },
      error: (_, __) => Text(fallback),
      loading: () => Text(fallback),
    );
  }
}


