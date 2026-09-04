import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/widgets/design_system/sync_status_indicator.dart';

/// Canonical SIGAP AppBar wrapper — consistent height, title text style,
/// optional leading, and an optional trailing [SyncStatusIndicator].
///
/// Background uses [SigapColors.surface] with subtle elevation per theme.
/// When [showSync] is true, a [SyncStatusIndicator] is rendered in the
/// trailing area; the caller is responsible for passing the appropriate
/// [SyncState] derived from their connectivity/sync provider.
class SigapAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SigapAppBar({
    super.key,
    this.title,
    this.leading,
    this.showSync = false,
    this.syncState = SyncState.online,
    this.actions,
    this.backgroundColor,
    this.elevation,
  });

  /// Primary title text displayed in the app bar.
  final String? title;

  /// Optional leading widget (e.g., back button, menu icon).
  /// If null, the standard back button is shown on routes that have a back button.
  final Widget? leading;

  /// When true, renders a [SyncStatusIndicator] in the trailing area.
  final bool showSync;

  /// The [SyncState] to display when [showSync] is true.
  /// Defaults to [SyncState.online]; caller wires the actual state.
  final SyncState syncState;

  /// Additional actions appended after the optional sync indicator.
  final List<Widget>? actions;

  /// Override the background color. Defaults to [SigapColors.surface].
  final Color? backgroundColor;

  /// Override the elevation. Defaults to a subtle elevation.
  final double? elevation;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final background = backgroundColor ?? SigapColors.surface;
    final subtleElevation = elevation ?? 0.5;

    return AppBar(
      backgroundColor: background,
      elevation: subtleElevation,
      scrolledUnderElevation: subtleElevation,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: leading == null,
      leading: leading,
      title: title != null
          ? Text(
              title!,
              style: TextStyle(
                fontSize: SigapTypography.subheading,
                fontWeight: FontWeight.w600,
                color: SigapColors.textPrimary,
                letterSpacing: SigapTypography.letterSpacingTight,
              ),
            )
          : null,
      centerTitle: false,
      actions: [
        if (showSync) ...[
          SyncStatusIndicator(state: syncState),
          const SizedBox(width: SigapSpacing.sm),
        ],
        if (actions != null) ...actions!,
      ],
    );
  }
}
