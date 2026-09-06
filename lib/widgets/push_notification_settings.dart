import 'package:sigap/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/push_notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';

class PushNotificationSettings extends ConsumerWidget {
  const PushNotificationSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final service = PushNotificationService.instance;
    return ValueListenableBuilder<PushState>(
      valueListenable: service.state,
      builder: (context, state, _) {
        final enabled = state == PushState.enabled;
        final busy = state == PushState.enabling;
        final subtitle = switch (state) {
          PushState.enabled => l10n.mobileNotificationEnabled,
          PushState.denied => l10n.mobileNotificationDenied,
          PushState.failed => l10n.mobileNotificationFailed,
          PushState.unavailable => l10n.mobileNotificationUnavailable,
          _ => l10n.mobileNotificationPrompt,
        };
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.mobileNotificationTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(subtitle),
                if (state == PushState.denied)
                  TextButton(
                    onPressed: openAppSettings,
                    child: Text(l10n.mobileAndroidSettings),
                  ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: busy || state == PushState.unavailable
                      ? null
                      : () async {
                          if (enabled) {
                            await service.disable();
                          } else {
                            await service.syncSession(
                              ref.read(apiClientProvider),
                              ref.read(authNotifierProvider).userId,
                            );
                            await service.enable();
                          }
                        },
                  child: Text(
                    busy
                        ? l10n.mobileNotificationEnabling
                        : enabled
                        ? l10n.mobileNotificationDisable
                        : l10n.mobileNotificationEnable,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
