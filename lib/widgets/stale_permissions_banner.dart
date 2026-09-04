import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sigap/providers/capability_provider.dart';
import 'package:sigap/theme/tokens.dart';

/// Banner shown when the server indicates capabilities are stale (403 cap_stale).
///
/// Listens to [CapabilityState.isStale] and displays a Material banner with a
/// refresh action. Dismisses automatically after a successful refetch.
class StalePermissionsBanner extends ConsumerWidget {
  const StalePermissionsBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capState = ref.watch(capabilityNotifierProvider);

    final isStale = capState.valueOrNull?.isStale ?? false;

    if (!isStale) {
      return const SizedBox.shrink();
    }

    return MaterialBanner(
      backgroundColor: SigapColors.warningBg,
      leading: const Icon(Icons.refresh, color: SigapColors.warning),
      content: Text(
        'Permissions may be out of date — refresh',
        style: TextStyle(
          color: SigapColors.warningText,
          fontSize: SigapTypography.bodyText,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            ref.read(capabilityNotifierProvider.notifier).refetch();
          },
          child: Text(
            'REFRESH',
            style: TextStyle(
              color: SigapColors.warningTextStrong,
              fontSize: SigapTypography.bodySmall,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
