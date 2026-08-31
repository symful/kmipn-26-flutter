import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/capability_provider.dart';
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
      backgroundColor: SigapColors.bgScreen,
      appBar: AppBar(title: const Text('Ganti Peran Pengguna')),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: SigapColors.primary),
              )
            : ListView(
                padding: const EdgeInsets.all(SigapSpacing.lg),
                children: [
                  // Info banner
                  Container(
                    padding: const EdgeInsets.all(SigapSpacing.md),
                    decoration: BoxDecoration(
                      color: SigapColors.primaryLight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(SigapRadius.md),
                      border: Border.all(
                        color: SigapColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.swap_horiz,
                          color: SigapColors.primary,
                          size: 24,
                        ),
                        SizedBox(width: SigapSpacing.md),
                        Expanded(
                          child: Text(
                            'Pilih peran untuk berganti konteks kerja. Menu, alur data, dan izin akses akan disesuaikan secara otomatis.',
                            style: TextStyle(
                              fontSize: SigapTypography.size12,
                              color: SigapColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: SigapSpacing.lg),

                  const Text(
                    'Peran Tersedia untuk Akun Ini',
                    style: TextStyle(
                      fontSize: SigapTypography.size14,
                      fontWeight: FontWeight.bold,
                      color: SigapColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: SigapSpacing.sm),

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
                          isActive:
                              role.toLowerCase() == activeRole?.toLowerCase(),
                          onTap: role.toLowerCase() == activeRole?.toLowerCase()
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
        // Refresh capabilities for the new role (async, non-blocking)
        ref.read(capabilityNotifierProvider.notifier).refetch();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Berhasil beralih ke peran ${_formatRoleName(role)}'),
            backgroundColor: SigapColors.primary,
          ),
        );
        if (!mounted) return;
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal beralih peran. Silakan coba lagi.'),
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
    final roleColor = _getRoleColor(role);

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
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isActive
                ? SigapColors.primary
                : roleColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(SigapRadius.md),
          ),
          alignment: Alignment.center,
          child: Icon(
            _getRoleIcon(role),
            color: isActive ? Colors.white : roleColor,
            size: 22,
          ),
        ),
        title: Row(
          children: [
            Text(
              _formatRoleName(role),
              style: TextStyle(
                fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                fontSize: SigapTypography.size14,
                color: isActive ? SigapColors.primary : SigapColors.textPrimary,
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: SigapSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: SigapColors.primary,
                  borderRadius: BorderRadius.circular(SigapRadius.pill),
                ),
                child: const Text(
                  'AKTIF',
                  style: TextStyle(
                    fontSize: SigapTypography.size9,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: SigapTypography.letterSpacingLabel,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            _getRoleDescription(role),
            style: TextStyle(
              fontSize: SigapTypography.size12,
              color: isActive ? SigapColors.primary : SigapColors.textSecondary,
            ),
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

  String _getRoleDescription(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
      case 'admin_daerah':
        return 'Kelola master wilayah, unit UPT, SLA, dan konfigurasi bobot prioritas.';
      case 'operator':
        return 'Disposisi penugasan, eskalasi kasus, dan monitoring antrean laporan.';
      case 'verifikator':
        return 'Validasi kelayakan laporan pengaduan masuk dan tinjauan kebenaran.';
      case 'petugas':
        return 'Tindak lanjut teknis lapangan dan penyelesaian masalah pengaduan.';
      case 'surveyor':
        return 'Survei dan peninjauan fisik lapangan dengan formulir teknis.';
      case 'auditor':
        return 'Inspeksi jejak audit, log aktivitas sistem, dan pelaporan compliance.';
      case 'warga':
        return 'Kirim laporan pengaduan publik dan pantau status penyelesaian.';
      case 'exec':
        return 'Ringkasan eksekutif, analisis tren verifikasi, dan statistik wilayah.';
      default:
        return 'Akses fitur operasional sistem SIGAP.';
    }
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
      case 'admin_daerah':
        return SigapColors.perluTindakan;
      case 'operator':
      case 'verifikator':
        return SigapColors.diproses;
      case 'petugas':
        return SigapColors.offlineDot;
      case 'surveyor':
        return SigapColors.primary;
      case 'auditor':
        return SigapColors.roleAuditor;
      case 'exec':
        return SigapColors.roleExec;
      case 'warga':
        return SigapColors.selesai;
      default:
        return SigapColors.textMuted;
    }
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
          Container(
            padding: const EdgeInsets.all(SigapSpacing.md),
            decoration: const BoxDecoration(
              color: SigapColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.badge_outlined,
              size: 40,
              color: SigapColors.primary,
            ),
          ),
          const SizedBox(height: SigapSpacing.md),
          const Text(
            'Peran Saat Ini',
            style: TextStyle(
              fontSize: SigapTypography.size12,
              color: SigapColors.textSecondary,
            ),
          ),
          const SizedBox(height: SigapSpacing.xs),
          Text(
            currentRole.toUpperCase(),
            style: const TextStyle(
              fontSize: SigapTypography.size18,
              fontWeight: FontWeight.bold,
              color: SigapColors.primary,
            ),
          ),
          const SizedBox(height: SigapSpacing.md),
          const Text(
            'Akun Anda saat ini hanya memiliki satu peran yang aktif. Hubungi Administrator Daerah jika Anda membutuhkan akses ke peran tambahan.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: SigapTypography.size13,
              color: SigapColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
