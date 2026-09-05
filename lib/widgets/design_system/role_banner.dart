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
    final activeRole = authState.activeRole ?? authState.userRole ?? 'UNKNOWN';
    final color = _roleColor(activeRole);

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
            activeRole.replaceAll('_', ' '),
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

  Color _roleColor(String role) {
    switch (role) {
      case 'ADMIN_DAERAH':
        return SigapColors.roleAdmin;
      case 'VERIFIKATOR':
        return SigapColors.roleVerifikator;
      case 'SURVEYOR':
        return SigapColors.roleSurveyor;
      case 'PETUGAS':
        return SigapColors.rolePetugas;
      case 'OPERATOR':
        return SigapColors.roleOperator;
      case 'AUDITOR':
        return SigapColors.roleAuditor;
      case 'PENGAMBIL_KEPUTUSAN':
        return SigapColors.rolePengambilKeputusan;
      case 'WARGA':
        return SigapColors.roleWarga;
      case 'PUBLIC':
        return SigapColors.textSecondary;
      default:
        return SigapColors.textSecondary;
    }
  }
}
