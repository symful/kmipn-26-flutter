import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/strings.dart';
import '../../providers/auth_provider.dart';
import '../../theme/tokens.dart';
import '../../widgets/design_system/section_label.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: SigapColors.bgScreen,
      appBar: AppBar(
        title: const Text(Strings.profil),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Pengaturan',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(SigapSpacing.lg),
          children: [
            _UserInfoCard(
              name: authState.userName ?? 'Pengguna SIGAP',
              email: authState.userEmail ?? '',
              role: authState.activeRole ?? authState.userRole ?? 'Warga',
            ),
            const SizedBox(height: SigapSpacing.lg),
            SectionLabel(
              label: 'Peran & Akses',
              padding: const EdgeInsets.only(bottom: SigapSpacing.xs),
            ),
            const SizedBox(height: SigapSpacing.sm),
            _RoleCard(
              role: authState.activeRole ?? authState.userRole ?? 'Warga',
              isActive: true,
              onTap: () => context.push('/switch-role'),
            ),
            const SizedBox(height: SigapSpacing.sm),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: SigapSpacing.sm),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SigapRadius.md),
                ),
              ),
              icon: const Icon(Icons.swap_horiz, size: 20),
              label: const Text('Ganti Peran Aktif'),
              onPressed: () => context.push('/switch-role'),
            ),
            const SizedBox(height: SigapSpacing.xl),
            SectionLabel(
              label: 'Pengaturan & Preferensi',
              padding: const EdgeInsets.only(bottom: SigapSpacing.xs),
            ),
            const SizedBox(height: SigapSpacing.sm),
            _ActionCard(
              icon: Icons.tune,
              title: 'Pengaturan Aplikasi',
              subtitle: 'Tema tampilan, pilihan bahasa, dan preferensi',
              onTap: () => context.push('/settings'),
            ),
            const SizedBox(height: SigapSpacing.lg),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout, size: 20),
              label: const Text(Strings.keluar),
              style: ElevatedButton.styleFrom(
                backgroundColor: SigapColors.perluTindakan,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: SigapSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SigapRadius.md),
                ),
              ),
              onPressed: () => _handleLogout(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SigapRadius.lg),
        ),
        backgroundColor: SigapColors.surface,
        title: const Row(
          children: [
            Icon(Icons.logout, color: SigapColors.perluTindakan),
            SizedBox(width: SigapSpacing.sm),
            Text(
              Strings.keluar,
              style: TextStyle(
                fontSize: SigapTypography.size16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari sesi akun ini?',
          style: TextStyle(
            fontSize: SigapTypography.size13,
            color: SigapColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              Strings.batal,
              style: TextStyle(color: SigapColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authNotifierProvider.notifier).logout();
              context.go('/');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SigapColors.perluTindakan,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SigapRadius.sm),
              ),
            ),
            child: const Text(Strings.keluar),
          ),
        ],
      ),
    );
  }
}

class _UserInfoCard extends StatelessWidget {
  final String name;
  final String email;
  final String role;
  const _UserInfoCard({
    required this.name,
    required this.email,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SigapSpacing.lg),
      decoration: BoxDecoration(
        color: SigapColors.surface,
        borderRadius: BorderRadius.circular(SigapRadius.lg),
        border: Border.all(color: SigapColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: SigapColors.primary,
            foregroundColor: Colors.white,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: SigapSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: SigapTypography.size16,
                    fontWeight: FontWeight.bold,
                    color: SigapColors.textPrimary,
                  ),
                ),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: SigapTypography.size12,
                      color: SigapColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SigapSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: SigapColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(SigapRadius.pill),
                    border: Border.all(
                      color: SigapColors.primary.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    role.toUpperCase(),
                    style: const TextStyle(
                      fontSize: SigapTypography.size10,
                      fontWeight: FontWeight.bold,
                      color: SigapColors.primary,
                      letterSpacing: SigapTypography.letterSpacingLabel,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String role;
  final bool isActive;
  final VoidCallback onTap;
  const _RoleCard({
    required this.role,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SigapColors.surface,
        borderRadius: BorderRadius.circular(SigapRadius.md),
        border: Border.all(
          color: isActive ? SigapColors.primary : SigapColors.border,
        ),
      ),
      child: ListTile(
        leading: Icon(
          isActive ? Icons.check_circle : Icons.circle_outlined,
          color: isActive ? SigapColors.primary : SigapColors.textMuted,
        ),
        title: Text(
          role.replaceAll('_', ' ').toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: SigapTypography.size14,
            color: SigapColors.textPrimary,
          ),
        ),
        subtitle: Text(
          isActive ? 'Peran aktif saat ini' : 'Tap untuk mengaktifkan',
          style: const TextStyle(
            fontSize: SigapTypography.size12,
            color: SigapColors.textSecondary,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: SigapColors.textMuted),
        onTap: onTap,
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SigapColors.surface,
        borderRadius: BorderRadius.circular(SigapRadius.md),
        border: Border.all(color: SigapColors.border),
      ),
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: SigapColors.primaryLight,
            borderRadius: BorderRadius.circular(SigapRadius.sm),
          ),
          child: Icon(icon, size: 20, color: SigapColors.primary),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: SigapTypography.size14,
            color: SigapColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: SigapTypography.size12,
            color: SigapColors.textSecondary,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: SigapColors.textMuted),
        onTap: onTap,
      ),
    );
  }
}
