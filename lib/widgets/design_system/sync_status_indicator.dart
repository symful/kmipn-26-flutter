import 'package:sigap/theme/sigap_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:sigap/l10n/generated/app_localizations.dart';
import 'package:sigap/theme/tokens.dart';

/// Canonical sync status indicator pill — consolidates duplicate offline/online
/// indicators across the codebase.
///
/// Renders a compact pill with a colored dot and text label indicating the
/// current sync/connectivity state. Pure presentational — does NOT detect
/// connectivity; caller passes the [state].
///
/// States:
/// - [SyncState.online] — teal pill with check icon and "Online" label.
/// - [SyncState.offline] — amber pill with dot and "Offline" label.
/// - [SyncState.syncing] — amber pill with small [CircularProgressIndicator] and
///   "Syncing" label.
/// - [SyncState.error] — red pill with dot and "Error" label.
enum SyncState { online, offline, syncing, error }

class SyncStatusIndicator extends StatelessWidget {
  const SyncStatusIndicator({super.key, required this.state});

  /// Current sync/connectivity state to display.
  final SyncState state;

  // -------------------------------------------------------------------------
  // Color helpers — public for widget-test access
  // -------------------------------------------------------------------------

  Color backgroundColor(BuildContext context) {
    switch (state) {
      case SyncState.online:
        return SigapColorScheme.of(context).primaryLight;
      case SyncState.offline:
        return SigapColorScheme.of(context).warningBg;
      case SyncState.syncing:
        return SigapColorScheme.of(context).warningBg;
      case SyncState.error:
        return SigapColorScheme.of(context).dangerBg;
    }
  }

  Color foregroundColor(BuildContext context) {
    switch (state) {
      case SyncState.online:
        return SigapColorScheme.of(context).primaryDark;
      case SyncState.offline:
        return SigapColorScheme.of(context).warningText;
      case SyncState.syncing:
        return SigapColorScheme.of(context).warningText;
      case SyncState.error:
        return SigapColorScheme.of(context).dangerTextStrong;
    }
  }

  Color borderColor(BuildContext context) {
    switch (state) {
      case SyncState.online:
        return SigapColorScheme.of(context).successBorder;
      case SyncState.offline:
        return SigapColorScheme.of(context).warningBorder;
      case SyncState.syncing:
        return SigapColorScheme.of(context).warningBorder;
      case SyncState.error:
        return SigapColorScheme.of(context).dangerBorder;
    }
  }

  Color dotColor(BuildContext context) {
    switch (state) {
      case SyncState.online:
        return SigapColors.primary;
      case SyncState.offline:
        return SigapColors.warning;
      case SyncState.syncing:
        return SigapColors.warning;
      case SyncState.error:
        return SigapColors.danger;
    }
  }

  // -------------------------------------------------------------------------
  // Label
  // -------------------------------------------------------------------------

  String _label(AppLocalizations l10n) {
    switch (state) {
      case SyncState.online:
        return l10n.statusOnline;
      case SyncState.offline:
        return l10n.statusOffline;
      case SyncState.syncing:
        return l10n.statusSyncing;
      case SyncState.error:
        return l10n.statusErrorLabel;
    }
  }

  // -------------------------------------------------------------------------
  // Widget builder
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final label = _label(l10n);
    return Semantics(
      label: l10n.sinkronStatusA11y(label),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SigapSpacing.x9,
          vertical: SigapSpacing.x4,
        ),
        decoration: BoxDecoration(
          color: backgroundColor(context),
          borderRadius: BorderRadius.circular(SigapRadius.pill),
          border: Border.all(color: borderColor(context), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: SigapSpacing.x7),
            _buildIndicator(context),
            SizedBox(width: SigapSpacing.xs),
            Text(
              label,
              style: TextStyle(
                fontSize: SigapTypography.captionMedium,
                fontWeight: FontWeight.w600,
                color: foregroundColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(BuildContext context) {
    if (state == SyncState.syncing) {
      return SizedBox(
        width: 10,
        height: 10,
        child: CircularProgressIndicator(
          strokeWidth: 1.5,
          valueColor: AlwaysStoppedAnimation<Color>(dotColor(context)),
        ),
      );
    }

    if (state == SyncState.online) {
      return Icon(Icons.check_circle, size: 10, color: dotColor(context));
    }

    return SizedBox(
      width: 7,
      height: 7,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: dotColor(context),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
