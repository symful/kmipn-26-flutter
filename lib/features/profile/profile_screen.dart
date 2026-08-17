import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/strings.dart';
import '../../providers/auth_provider.dart';
import '../../theme/tokens.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.profil),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(SigapSpacing.lg),
          children: [
            _UserInfoCard(
              name: authState.userName ?? 'Unknown',
              email: authState.userEmail ?? '',
              role: authState.activeRole ?? authState.userRole ?? 'Unknown',
            ),
            const SizedBox(height: SigapSpacing.lg),
            _SectionHeader(title: 'Peran Saya'),
            const SizedBox(height: SigapSpacing.sm),
            _RoleCard(
              role: authState.activeRole ?? authState.userRole ?? 'Unknown',
              isActive: true,
              onTap: () => context.push('/switch-role'),
            ),
            const SizedBox(height: SigapSpacing.sm),
            OutlinedButton.icon(
              icon: const Icon(Icons.swap_horiz),
              label: const Text('Ganti Peran'),
              onPressed: () => context.push('/switch-role'),
            ),
            const SizedBox(height: SigapSpacing.xl),
            _SectionHeader(title: 'Akun'),
            const SizedBox(height: SigapSpacing.sm),
            _ActionCard(
              icon: Icons.settings,
              title: 'Pengaturan',
              subtitle: 'Tema, bahasa, notifikasi',
              onTap: () => context.push('/settings'),
            ),
            const SizedBox(height: SigapSpacing.lg),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text(Strings.keluar),
              style: ElevatedButton.styleFrom(
                backgroundColor: SigapColors.perluTindakan,
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
        title: const Text(Strings.keluar),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(Strings.batal),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authNotifierProvider.notifier).logout();
              context.go('/');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SigapColors.perluTindakan,
            ),
            child: const Text(Strings.keluar),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SigapSpacing.xs),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: SigapColors.textSecondary,
        ),
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
            radius: 30,
            backgroundColor: SigapColors.primary,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
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
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: SigapColors.textPrimary,
                  ),
                ),
                const SizedBox(height: SigapSpacing.xs),
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: SigapColors.textSecondary,
                  ),
                ),
                const SizedBox(height: SigapSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SigapSpacing.sm,
                    vertical: SigapSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: SigapColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(SigapRadius.sm),
                  ),
                  child: Text(
                    role,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: SigapColors.primary,
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
        color: isActive
            ? SigapColors.primary.withValues(alpha: 0.05)
            : SigapColors.surface,
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
        title: Text(role),
        subtitle: Text(
          isActive ? 'Peran aktif saat ini' : 'Tap untuk mengaktifkan',
        ),
        trailing: isActive
            ? null
            : const Icon(Icons.chevron_right, color: SigapColors.textMuted),
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
        leading: Icon(icon, color: SigapColors.textSecondary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right, color: SigapColors.textMuted),
        onTap: onTap,
      ),
    );
  }
}
