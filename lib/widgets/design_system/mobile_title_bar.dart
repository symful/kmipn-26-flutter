import 'package:sigap/theme/sigap_color_scheme.dart';
import 'package:sigap/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../providers/providers.dart';

/// Native equivalent of mobile.css .m-titlebar and .connection.
class MobileTitleBar extends ConsumerWidget implements PreferredSizeWidget {
  const MobileTitleBar({
    super.key,
    required this.title,
    this.subtitle = '',
    this.onBack,
  });
  final String title;
  final String subtitle;
  final VoidCallback? onBack;
  @override
  Size get preferredSize => Size.fromHeight(76);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checking = !ref.watch(connectivityProvider).hasValue;
    final offline =
        ref
            .watch(connectivityProvider)
            .whenOrNull(
              data: (states) =>
                  states.isEmpty ||
                  states.every((state) => state == ConnectivityResult.none),
            ) ??
        true;
    return SafeArea(
      bottom: false,
      child: Container(
        color: SigapColorScheme.of(context).bgSurface,
        padding: EdgeInsets.fromLTRB(20, 11, 20, 16),
        child: Row(
          children: [
            if (onBack != null) ...[
              IconButton(
                onPressed: onBack,
                icon: Icon(Icons.arrow_back, size: 22),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 36, minHeight: 40),
              ),
              SizedBox(width: 9),
            ],
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -.4,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle.isNotEmpty) ...[
                    SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 10,
                        color: SigapColorScheme.of(context).textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 120),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: offline
                      ? SigapColorScheme.of(context).offlineBg
                      : SigapColorScheme.of(context).primaryLight,
                  border: Border.all(
                    color: offline
                        ? SigapColorScheme.of(context).offlineBorder
                        : SigapColorScheme.of(context).successBorder,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 6,
                      color: offline
                          ? SigapColorScheme.of(context).offlineText
                          : SigapColorScheme.of(context).primaryDark,
                    ),
                    SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        checking
                            ? AppLocalizations.of(
                                context,
                              )!.mobileCheckingConnection
                            : offline
                            ? AppLocalizations.of(context)!.connectionOffline
                            : AppLocalizations.of(context)!.connectionOnline,
                        style: TextStyle(
                          fontSize: 10,
                          color: offline
                              ? SigapColorScheme.of(context).offlineText
                              : SigapColorScheme.of(context).primaryDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
