import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sigap/l10n/generated/app_localizations.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/widgets/design_system/back_arrow_button.dart';
import 'package:sigap/widgets/design_system/sync_status_indicator.dart';

/// Canonical SIGAP AppBar — single unified widget for all screens.
///
/// Back button visibility is auto-detected: shown only when the current route
/// can be popped (i.e. the screen was pushed, not a root/tab route).
///
/// Usage:
/// ```dart
/// // Simple — back button auto-detected
/// SigapAppBar(title: 'Pengaturan')
///
/// // With subtitle
/// SigapAppBar(
///   title: 'Detail laporan',
///   subtitle: 'Lokal #$localId · Server #$serverId',
/// )
///
/// // With trailing widget (SLA badge, more button, etc.)
/// SigapAppBar(
///   title: 'Detail tugas',
///   trailing: SlaBadge(data: SlaBadgeData.fromDaysRemaining(2)),
/// )
///
/// // With bottom widget (stepper, progress bar)
/// SigapAppBar(
///   title: 'Review laporan',
///   subtitle: 'Langkah 5 dari 5',
///   bottom: Stepper5(currentStep: 5, totalSteps: 5),
/// )
///
/// // With sync indicator
/// SigapAppBar(
///   title: 'Dashboard',
///   showSync: true,
///   syncState: SyncState.online,
/// )
/// ```
class SigapAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Primary title text.
  final String title;

  /// Optional subtitle displayed below the title.
  final String? subtitle;

  /// Called when back arrow is tapped.
  /// If null, defaults to [GoRouter.pop]. The back arrow itself is only
  /// rendered when [GoRouter.canPop] is true for the current location.
  final VoidCallback? onBack;

  /// Optional trailing widget (e.g., SLA badge, more button, action icons).
  final Widget? trailing;

  /// Additional widgets appended after the optional trailing.
  final List<Widget>? actions;

  /// Override the background color. Defaults to [SigapColors.bgSurface].
  final Color? backgroundColor;

  /// Padding for the content area. Default: horizontal SigapSpacing.lg.
  final EdgeInsetsGeometry? padding;

  /// Optional widget displayed below the title row (e.g., Stepper5).
  final Widget? bottom;

  /// Height of the bottom widget. If bottom is provided but bottomHeight is null,
  /// uses kToolbarHeight as base (meaning bottom adds on top).
  final double? bottomHeight;

  /// When true, renders a [SyncStatusIndicator] in the trailing area.
  final bool showSync;

  /// The [SyncState] to display when [showSync] is true.
  /// Defaults to [SyncState.online].
  final SyncState syncState;

  /// Title style variant: standard (default) or review (larger text).
  final _TitleStyle _titleStyle;

  const SigapAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.trailing,
    this.actions,
    this.backgroundColor,
    this.padding,
    this.bottom,
    this.bottomHeight,
    this.showSync = false,
    this.syncState = SyncState.online,
    _TitleStyle? titleStyle,
  }) : _titleStyle = titleStyle ?? _TitleStyle.standard;

  /// Creates a SigapAppBar with the "review" title style (larger text).
  const SigapAppBar.review({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.trailing,
    this.actions,
    this.backgroundColor,
    this.padding,
    this.bottom,
    this.bottomHeight,
    this.showSync = false,
    this.syncState = SyncState.online,
  }) : _titleStyle = _TitleStyle.review;

  @override
  Size get preferredSize {
    if (bottom != null) {
      return Size.fromHeight((bottomHeight ?? kToolbarHeight) + 48);
    }
    return const Size.fromHeight(kToolbarHeight);
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? SigapColors.bgSurface;
    final canPop = GoRouter.of(context).canPop();

    return Container(
      color: bgColor,
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: SigapSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main row: back arrow + title column + trailing + actions
          SizedBox(
            height: 48,
            child: Row(
              children: [
                if (canPop) ...[
                  BackArrowButton(onTap: onBack ?? () => context.pop()),
                  const SizedBox(width: SigapSpacing.x12),
                ],
                // Title column
                Expanded(child: _buildTitleColumn()),
                // Sync indicator
                if (showSync) ...[
                  SyncStatusIndicator(state: syncState),
                  const SizedBox(width: SigapSpacing.sm),
                ],
                // Trailing widget
                if (trailing != null) trailing!,
                // Additional actions
                if (actions != null) ...actions!,
              ],
            ),
          ),
          // Optional bottom widget (e.g., stepper)
          if (bottom != null) ...[
            const SizedBox(height: SigapSpacing.x11),
            Flexible(child: bottom!),
          ],
        ],
      ),
    );
  }

  Widget _buildTitleColumn() {
    switch (_titleStyle) {
      case _TitleStyle.standard:
        return _TitleColumnStandard(title: title, subtitle: subtitle);
      case _TitleStyle.review:
        return _TitleColumnReview(title: title, subtitle: subtitle);
    }
  }
}

enum _TitleStyle { standard, review }

/// Standard title column: title + optional subtitle below
class _TitleColumnStandard extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _TitleColumnStandard({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: SigapTypography.bodyLarge,
            fontWeight: FontWeight.w700,
            color: SigapColors.textPrimary,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: const TextStyle(
              fontSize: SigapTypography.captionMedium,
              fontFamily: SigapTypography.fontFamilyMono,
              color: SigapColors.textTertiary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

/// Review title column: larger title + stepper-style subtitle
class _TitleColumnReview extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _TitleColumnReview({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: SigapTypography.headlineMedium,
            fontWeight: FontWeight.w700,
            color: SigapColors.textPrimary,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 1),
          Text(
            subtitle!,
            style: const TextStyle(
              fontSize: SigapTypography.bodySmall,
              color: SigapColors.textTertiary,
            ),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// SLA Badge
// ---------------------------------------------------------------------------

/// SLA badge data for S02AppBar pattern.
class SlaBadgeData {
  final Color backgroundColor;
  final Color textColor;
  final String label;

  const SlaBadgeData({
    required this.backgroundColor,
    required this.textColor,
    required this.label,
  });

  /// Creates badge data based on days remaining until SLA deadline.
  ///
  /// Colors:
  /// - Green (>2 days remaining): [SigapColors.primary]
  /// - Amber (1-2 days remaining): [SigapColors.warning]
  /// - Red (<1 day or overdue): [SigapColors.danger]
  factory SlaBadgeData.fromDaysRemaining(BuildContext context, int? days) {
    final l10n = AppLocalizations.of(context)!;
    if (days == null) {
      return const SlaBadgeData(
        backgroundColor: SigapColors.textDisabled,
        textColor: SigapColors.surface,
        label: 'N/A',
      );
    }

    if (days <= 0) {
      return SlaBadgeData(
        backgroundColor: SigapColors.danger,
        textColor: SigapColors.surface,
        label: l10n.overdue,
      );
    } else if (days < 1) {
      return SlaBadgeData(
        backgroundColor: SigapColors.danger,
        textColor: SigapColors.surface,
        label: l10n.lessThan1dLabel,
      );
    } else if (days <= 2) {
      return SlaBadgeData(
        backgroundColor: SigapColors.warning,
        textColor: SigapColors.surface,
        label: '${days}d',
      );
    } else {
      return SlaBadgeData(
        backgroundColor: SigapColors.primary,
        textColor: SigapColors.surface,
        label: '${days}d',
      );
    }
  }
}

/// SLA badge widget for SigapAppBar trailing.
class SlaBadge extends StatelessWidget {
  final SlaBadgeData data;

  const SlaBadge({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SigapSpacing.x9,
        vertical: SigapSpacing.x4,
      ),
      decoration: BoxDecoration(
        color: data.backgroundColor,
        borderRadius: BorderRadius.circular(SigapRadius.pill),
      ),
      child: Text(
        data.label,
        style: TextStyle(
          fontSize: SigapTypography.captionMedium,
          fontWeight: FontWeight.w600,
          color: data.textColor,
        ),
      ),
    );
  }
}
