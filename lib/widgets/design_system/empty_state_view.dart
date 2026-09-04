import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/widgets/design_system/sigap_card.dart';

/// EmptyState — canonical loading / empty / error state widget for the SIGAP
/// design system.
///
/// Built with [SigapCard] as its container. Displays a large muted icon, bold
/// title, optional subtitle, and optional action button. Centered layout with
/// generous spacing following the SIGAP visual language.
///
/// Accessibility:
/// - [Semantics] label combines title + subtitle text so screen readers can
///   announce the full empty state.
/// - Action button is a [ElevatedButton] with a minimum 48px height tap target.
/// - No information is conveyed by color alone; icon + text + optional button
///   provide redundant cues.
class EmptyState extends StatelessWidget {
  /// The icon to display (e.g. [Icons.inbox], [Icons.error_outline]).
  final IconData icon;

  /// Primary text label for this empty state.
  final String title;

  /// Optional secondary text beneath the title.
  final String? subtitle;

  /// Optional action widget (typically an [ElevatedButton] or [TextButton])
  /// rendered below the subtitle.
  final Widget? action;

  /// Inner padding passed to the underlying [SigapCard]. Defaults to
  /// [SigapSpacing.xl] all sides.
  final EdgeInsets? padding;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final semanticsLabel = subtitle != null ? '$title. $subtitle' : title;

    return Semantics(
      label: semanticsLabel,
      child: SigapCard(
        padding: padding ?? const EdgeInsets.all(SigapSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Large muted icon
            Icon(icon, size: 64, color: SigapColors.textMuted),
            const SizedBox(height: SigapSpacing.lg),
            // Title — bold, using typography scale
            Text(
              title,
              style: TextStyle(
                fontSize: SigapTypography.subheading,
                fontWeight: FontWeight.w700,
                color: SigapColors.textPrimary,
                height: SigapTypography.lineHeight130,
              ),
              textAlign: TextAlign.center,
            ),
            // Optional subtitle
            if (subtitle != null) ...[
              const SizedBox(height: SigapSpacing.sm),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: SigapTypography.bodyText,
                  fontWeight: FontWeight.w400,
                  color: SigapColors.textSecondary,
                  height: SigapTypography.lineHeight145,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            // Optional action button — min 48px tap target
            if (action != null) ...[
              const SizedBox(height: SigapSpacing.lg),
              SizedBox(height: 48, child: action!),
            ],
          ],
        ),
      ),
    );
  }
}
