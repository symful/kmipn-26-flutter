import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/widgets/design_system/design_system.dart';

/// S-02 App Bar with SLA deadline badge for surveyor task detail screen.
///
/// Displays a back arrow, title (case category), and an SLA deadline badge
/// colored by urgency.
///
/// SLA badge colors:
/// - Green (>2 days remaining): SigapColors.primary
/// - Amber (1-2 days remaining): SigapColors.warning
/// - Red (<1 day or overdue): SigapColors.danger
///
/// Now uses [TitleAppBar] internally.
class S02AppBar extends StatelessWidget {
  /// Title text (case category).
  final String title;

  /// Days remaining until SLA deadline. Null means SLA not applicable.
  final int? slaDaysRemaining;

  /// Called when back arrow is tapped.
  final VoidCallback? onBack;

  const S02AppBar({
    super.key,
    required this.title,
    this.slaDaysRemaining,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return TitleAppBar(
      title: title,
      onBack: onBack,
      padding: const EdgeInsets.symmetric(horizontal: SigapSpacing.lg),
      trailing: SlaBadge(
        data: SlaBadgeData.fromDaysRemaining(slaDaysRemaining),
      ),
    );
  }
}
