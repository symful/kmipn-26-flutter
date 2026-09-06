import 'package:sigap/theme/sigap_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/providers/providers.dart';

/// Displays the currently active role as a colored banner.
///
/// Used in the authenticated shell to give users a clear
/// visual indicator of their active role context.
class RoleBanner extends ConsumerWidget {
  const RoleBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final userRole = authState.userRole ?? 'UNKNOWN';
    final color = _roleColor(context, userRole);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: SigapSpacing.md,
        vertical: SigapSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border(bottom: BorderSide(color: color.withValues(alpha: 0.3))),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: SigapSpacing.sm),
          Text(
            userRole,
            style: TextStyle(
              color: color,
              fontSize: SigapTypography.bodySmall,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Color _roleColor(BuildContext context, String role) {
    switch (role) {
      case 'PETUGAS':
        return SigapColors.rolePetugas;
      case 'WARGA':
        return SigapColors.roleWarga;
      default:
        return SigapColorScheme.of(context).textSecondary;
    }
  }
}
