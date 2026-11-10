import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/profile/profile_provider.dart';

// TODO: add profile provider.
// Assumed shape: AsyncValue<Profile> where Profile has `displayName`
// (the same `profile.displayName` you use elsewhere).

import '../formatters/card_formatters.dart';

/// The name printed on the card = the currently logged-in user.
/// `select` means the card only rebuilds when the NAME changes, not on every
/// other profile update. Logging out/in as someone else updates it live.
final cardHolderNameProvider = Provider.autoDispose<String>((ref) {
  final name = ref.watch(
    profileProvider.select((async) => async.value?.displayName),
  );
  return CardFormatters.holderName(name);
});