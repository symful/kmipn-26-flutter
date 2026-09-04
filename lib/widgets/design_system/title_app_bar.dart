import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/widgets/design_system/back_arrow_button.dart';

/// A structured AppBar with: [BackArrow] [TitleColumn] [TrailingWidget?]
/// TitleColumn = title text + optional subtitle
///
/// Replace DetailAppBar, S02AppBar patterns with this.
/// For unique patterns like WargaAppBar (wilayah dropdown + notification bell),
/// create a separate widget that may compose TitleAppBar internally.
///
/// Usage:
/// ```dart
/// TitleAppBar(
///   title: 'Detail laporan',
///   subtitle: 'Lokal #$localId · Server #$serverId',
///   onBack: () => context.pop(),
///   trailing: IconButton(icon: Icon(Icons.more_vert), onPressed: ...),
/// )
/// ```
class TitleAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Primary title text.
  final String title;

  /// Optional subtitle displayed below the title.
  final String? subtitle;

  /// Called when back arrow is tapped.
  final VoidCallback? onBack;

  /// Optional trailing widget (e.g., SLA badge, more button, action icons).
  final Widget? trailing;

  /// Additional AppBar.actions widgets appended after trailing.
  final List<Widget>? actions;

  /// Override the background color. Defaults to [SigapColors.bgSurface].
  final Color? backgroundColor;

  /// Padding for the content area.
  final EdgeInsetsGeometry? padding;

  /// Optional widget displayed below the title row (e.g., Stepper5).
  final Widget? bottom;

  /// Height of the bottom widget. If bottom is provided but bottomHeight is null,
  /// uses kToolbarHeight as base (meaning bottom adds on top).
  final double? bottomHeight;

  /// Style variant for the title text.
  final _TitleStyle _titleStyle;

  const TitleAppBar({
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
    _TitleStyle? titleStyle,
  }) : _titleStyle = titleStyle ?? _TitleStyle.standard;

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

    return Container(
      color: bgColor,
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: SigapSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main row: back arrow + title column + trailing
          SizedBox(
            height: 48,
            child: Row(
              children: [
                BackArrowButton(onTap: onBack),
                const SizedBox(width: SigapSpacing.x12),
                // Title column
                Expanded(child: _buildTitleColumn()),
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
            bottom!,
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
  factory SlaBadgeData.fromDaysRemaining(int? days) {
    if (days == null) {
      return const SlaBadgeData(
        backgroundColor: SigapColors.textDisabled,
        textColor: Colors.white,
        label: 'N/A',
      );
    }

    if (days <= 0) {
      return const SlaBadgeData(
        backgroundColor: SigapColors.danger,
        textColor: Colors.white,
        label: 'Overdue',
      );
    } else if (days < 1) {
      return const SlaBadgeData(
        backgroundColor: SigapColors.danger,
        textColor: Colors.white,
        label: '<1d',
      );
    } else if (days <= 2) {
      return SlaBadgeData(
        backgroundColor: SigapColors.warning,
        textColor: Colors.white,
        label: '${days}d',
      );
    } else {
      return SlaBadgeData(
        backgroundColor: SigapColors.primary,
        textColor: Colors.white,
        label: '${days}d',
      );
    }
  }
}

/// SLA badge widget for TitleAppBar trailing.
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
