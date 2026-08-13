import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../theme/tokens.dart';

class RoleBanner extends ConsumerWidget {
  const RoleBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final hasMultipleRoles = authState.roles.length > 1;
    final activeRole = authState.activeRole ?? authState.userRole;

    if (!hasMultipleRoles || activeRole == null) {
      return const SizedBox.shrink();
    }

    final bannerColor = _getRoleBannerColor(activeRole);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: SigapSpacing.md,
        vertical: SigapSpacing.xs,
      ),
      color: bannerColor,
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_getRoleIcon(activeRole), color: Colors.white, size: 16),
            const SizedBox(width: SigapSpacing.xs),
            Text(
              _formatRoleName(activeRole),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _roleColors = {
    'OPERATOR': Color(0xFF2E7D32),
    'VERIFIKATOR': Color(0xFF1565C0),
    'ADMIN': Color(0xFF6A1B9A),
    'ADMIN_DAERAH': Color(0xFF6A1B9A),
    'PETUGAS': Color(0xFFE65100),
    'SURVEYOR': Color(0xFF00695C),
    'AUDITOR': Color(0xFF4527A0),
    'WARGA': Color(0xFF558B2F),
    'RT_RW': Color(0xFF6D4C41),
    'PENGAMBIL_KEPUTUSAN': Color(0xFFC62828),
    'EXEC': Color(0xFFC62828),
  };

  Color _getRoleBannerColor(String role) {
    return _roleColors[role.toUpperCase()] ?? SigapColors.primary;
  }

  String _formatRoleName(String role) {
    return role
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
              : '',
        )
        .join(' ');
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
      case 'admin_daerah':
        return Icons.admin_panel_settings;
      case 'operator':
        return Icons.dashboard;
      case 'verifikator':
        return Icons.verified;
      case 'petugas':
        return Icons.assignment_ind;
      case 'surveyor':
        return Icons.map;
      case 'auditor':
        return Icons.fact_check;
      case 'warga':
        return Icons.person;
      case 'exec':
      case 'pengambil_keputusan':
        return Icons.trending_up;
      case 'rt_rw':
        return Icons.people;
      default:
        return Icons.badge;
    }
  }
}
