import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../theme/tokens.dart';

class RoleSwitcherScreen extends ConsumerStatefulWidget {
  const RoleSwitcherScreen({super.key});

  @override
  ConsumerState<RoleSwitcherScreen> createState() => _RoleSwitcherScreenState();
}

class _RoleSwitcherScreenState extends ConsumerState<RoleSwitcherScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final roles = authState.roles;
    final activeRole = authState.activeRole;

    return Scaffold(
      appBar: AppBar(title: const Text('Ganti Peran')),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(SigapSpacing.lg),
                children: [
                  const Text(
                    'Pilih peran yang ingin Anda gunakan. '
                    'Peran yang dipilih akan menentukan menu dan '
                    'fitur yang tersedia.',
                    style: TextStyle(
                      fontSize: 14,
                      color: SigapColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: SigapSpacing.lg),
                  if (roles.isEmpty)
                    _EmptyRolesCard(
                      currentRole:
                          activeRole ?? authState.userRole ?? 'Unknown',
                    )
                  else
                    ...roles.map(
                      (role) => Padding(
                        padding: const EdgeInsets.only(bottom: SigapSpacing.sm),
                        child: _RoleSwitchCard(
                          role: role,
                          isActive: role == activeRole,
                          onTap: role == activeRole
                              ? null
                              : () => _handleRoleSwitch(role),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Future<void> _handleRoleSwitch(String role) async {
    setState(() => _isLoading = true);

    try {
      final success = await ref
          .read(authNotifierProvider.notifier)
          .switchRole(role);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Berhasil switch ke peran $role'),
            backgroundColor: SigapColors.primary,
          ),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal switch peran'),
            backgroundColor: SigapColors.perluTindakan,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: SigapColors.perluTindakan,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

class _RoleSwitchCard extends StatelessWidget {
  final String role;
  final bool isActive;
  final VoidCallback? onTap;
  const _RoleSwitchCard({
    required this.role,
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isActive
            ? SigapColors.primary.withValues(alpha: 0.08)
            : SigapColors.surface,
        borderRadius: BorderRadius.circular(SigapRadius.md),
        border: Border.all(
          color: isActive ? SigapColors.primary : SigapColors.border,
          width: isActive ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: SigapSpacing.md,
          vertical: SigapSpacing.xs,
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive
                ? SigapColors.primary
                : SigapColors.textMuted.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(SigapRadius.sm),
          ),
          alignment: Alignment.center,
          child: Icon(
            _getRoleIcon(role),
            color: isActive ? Theme.of(context).colorScheme.onPrimary : SigapColors.textMuted,
            size: 20,
          ),
        ),
        title: Text(
          _formatRoleName(role),
          style: TextStyle(
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? SigapColors.primary : SigapColors.textPrimary,
          ),
        ),
        subtitle: Text(
          isActive ? 'Sedang aktif' : 'Tap untukswitch',
          style: TextStyle(
            fontSize: 12,
            color: isActive ? SigapColors.primary : SigapColors.textMuted,
          ),
        ),
        trailing: isActive
            ? const Icon(Icons.check_circle, color: SigapColors.primary)
            : const Icon(Icons.chevron_right, color: SigapColors.textMuted),
        onTap: onTap,
      ),
    );
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
        return Icons.admin_panel_settings;
      case 'admin_daerah':
        return Icons.location_city;
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
        return Icons.trending_up;
      default:
        return Icons.person;
    }
  }
}

class _EmptyRolesCard extends StatelessWidget {
  final String currentRole;
  const _EmptyRolesCard({required this.currentRole});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SigapSpacing.lg),
      decoration: BoxDecoration(
        color: SigapColors.surface,
        borderRadius: BorderRadius.circular(SigapRadius.md),
        border: Border.all(color: SigapColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.badge, size: 48, color: SigapColors.textMuted),
          const SizedBox(height: SigapSpacing.md),
          const Text(
            'Peran Saat Ini',
            style: TextStyle(fontSize: 14, color: SigapColors.textSecondary),
          ),
          const SizedBox(height: SigapSpacing.xs),
          Text(
            currentRole,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: SigapColors.textPrimary,
            ),
          ),
          const SizedBox(height: SigapSpacing.md),
          const Text(
            'Anda hanya memiliki satu peran. '
            'Hubungi administrator untuk menambahkan peran lain.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: SigapColors.textMuted),
          ),
        ],
      ),
    );
  }
}
