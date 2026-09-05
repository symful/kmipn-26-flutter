import 'package:flutter/material.dart';
import 'package:sigap/l10n/generated/app_localizations.dart';
import 'package:sigap/theme/tokens.dart';

/// Online status for S-01 surveyor home screen indicator.
///
/// Maps to PantauDesa design spec colors:
/// - online: Light green pill with green dot and "Online" text (#e2f1ee bg, #0a5c50 text)
/// - syncing: Amber pill with "Syncing" text
/// - offline: Gray pill with "Offline" text
enum ConnectivityStatus {
  /// Connected and ready to sync
  online,

  /// Currently syncing data
  syncing,

  /// No internet connection
  offline,
}

/// Pill badge widget showing online/offline/syncing status.
///
/// Displays a colored pill with text label indicating the current
/// connection status for the surveyor home screen.
///
/// S-01 Design tokens:
/// - Online: bg #e2f1ee, text #0a5c50, border #bfe0d9, dot #0f7a6b
/// - Syncing: bg #f8ecd6, text #8a5808, border #ecd7a6
/// - Offline: bg #eef0ec, text #616770, border #d3d7d0
class ConnectivityIndicator extends StatelessWidget {
  /// Current online status.
  final ConnectivityStatus status;

  const ConnectivityIndicator({super.key, required this.status});

  /// Background color based on status (S-01 spec).
  Color get _backgroundColor {
    switch (status) {
      case ConnectivityStatus.online:
        return SigapColors.primaryLight; // #e2f1ee
      case ConnectivityStatus.syncing:
        return SigapColors.warningBg; // #f8ecd6
      case ConnectivityStatus.offline:
        return SigapColors.bgSoft; // #eef0ec
    }
  }

  /// Text color based on status (S-01 spec).
  Color get _textColor {
    switch (status) {
      case ConnectivityStatus.online:
        return SigapColors.primaryDark; // #0a5c50
      case ConnectivityStatus.syncing:
        return SigapColors.warningText; // #8a5808
      case ConnectivityStatus.offline:
        return SigapColors.textTertiary; // #616770
    }
  }

  /// Border color based on status (S-01 spec).
  Color get _borderColor {
    switch (status) {
      case ConnectivityStatus.online:
        return SigapColors.successBorder; // #bfe0d9
      case ConnectivityStatus.syncing:
        return SigapColors.warningBorder; // #ecd7a6
      case ConnectivityStatus.offline:
        return SigapColors.borderSoft; // #d3d7d0
    }
  }

  /// Dot color based on status (S-01 spec).
  Color get _dotColor {
    switch (status) {
      case ConnectivityStatus.online:
        return SigapColors.primary; // #0f7a6b - primary
      case ConnectivityStatus.syncing:
        return SigapColors.offlineDot; // #b8730a - offlineDot
      case ConnectivityStatus.offline:
        return SigapColors.textDisabled; // #8a9099
    }
  }

  /// Label text based on status.
  String _label(AppLocalizations l10n) {
    switch (status) {
      case ConnectivityStatus.online:
        return l10n.statusOnline;
      case ConnectivityStatus.syncing:
        return l10n.statusSyncing;
      case ConnectivityStatus.offline:
        return l10n.statusOffline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(SigapRadius.pill),
        border: Border.all(color: _borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: _dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            _label(l10n),
            style: TextStyle(
              fontSize: SigapTypography.captionMedium,
              fontWeight: FontWeight.w600,
              color: _textColor,
            ),
          ),
        ],
      ),
    );
  }
}
