import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sigap/l10n/strings.dart';
import '../../providers/auth_provider.dart';
import '../../theme/tokens.dart';
import '../../components/app_icons.dart';

/// Index of the center FAB in the bottom navigation
const int _centerFabIndex = 2;

/// Provider for the currently selected bottom nav index
final wargaBottomNavIndexProvider = StateProvider<int>((ref) => 0);

/// Warga Beranda screen with bottom navigation and center FAB for creating reports.
///
/// Navigation items:
/// - 0: Beranda (Home)
/// - 1: Laporan (Reports)
/// - 2: FAB (Create Report) - center position
/// - 3: Notifikasi (Notifications)
/// - 4: Profil (Profile)
class WargaBerandaScreen extends ConsumerWidget {
  const WargaBerandaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(wargaBottomNavIndexProvider);

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex == _centerFabIndex ? 0 : selectedIndex,
        children: const [
          _BerandaTab(),
          _LaporanTab(),
          SizedBox.shrink(), // Placeholder for FAB position
          _NotifikasiTab(),
          _ProfilTab(),
        ],
      ),
      bottomNavigationBar: _BottomNavWithCenterFAB(
        selectedIndex: selectedIndex,
        onTap: (index) {
          if (index == _centerFabIndex) {
            // Navigate to create report
            context.push('/create');
          } else {
            ref.read(wargaBottomNavIndexProvider.notifier).state = index;
          }
        },
      ),
      floatingActionButton: _centerFabIndex == selectedIndex
          ? null
          : FloatingActionButton(
              onPressed: () => context.push('/create'),
              backgroundColor: SigapColors.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              child: const Icon(Icons.add),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

/// Custom bottom navigation bar with center FAB dock
class _BottomNavWithCenterFAB extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _BottomNavWithCenterFAB({
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SigapColors.bgCard,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: SigapSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: AppIcons.home,
                label: Strings.beranda,
                isSelected: selectedIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: AppIcons.report,
                label: Strings.laporan,
                isSelected: selectedIndex == 1,
                onTap: () => onTap(1),
              ),
              // Space for center FAB
              const SizedBox(width: 56),
              _NavItem(
                icon: AppIcons.inbox,
                label: 'Notifikasi',
                isSelected: selectedIndex == 3,
                onTap: () => onTap(3),
              ),
              _NavItem(
                icon: AppIcons.person,
                label: Strings.profil,
                isSelected: selectedIndex == 4,
                onTap: () => onTap(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Individual navigation item
class _NavItem extends StatelessWidget {
  final Widget icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? SigapColors.primary : SigapColors.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SigapRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SigapSpacing.md,
          vertical: SigapSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconTheme(
              data: IconThemeData(color: color, size: 24),
              child: icon is Icon
                  ? Icon((icon as Icon).icon, color: color, size: 24)
                  : icon,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Beranda (Home) tab content
class _BerandaTab extends ConsumerWidget {
  const _BerandaTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(SigapSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: SigapSpacing.md),
            // Welcome header
            Text(
              'Selamat datang,',
              style: TextStyle(fontSize: 14, color: SigapColors.textSecondary),
            ),
            const SizedBox(height: SigapSpacing.xs),
            Text(
              authState.userName ?? '--',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: SigapColors.textPrimary,
              ),
            ),
            const SizedBox(height: SigapSpacing.xl),

            // Quick action card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(SigapSpacing.lg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [SigapColors.primary, SigapColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(SigapRadius.xl),
                boxShadow: [
                  BoxShadow(
                    color: SigapColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: Colors.white,
                        size: 28,
                      ),
                      SizedBox(width: SigapSpacing.md),
                      Expanded(
                        child: Text(
                          'Buat Laporan Baru',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: SigapSpacing.sm),
                  const Text(
                    'Laporkan masalah di sekitarmu untuk membantu peningkatan layanan desa.',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: SigapSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/create'),
                      icon: const Icon(Icons.add_a_photo, size: 20),
                      label: const Text('Buat Laporan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: SigapColors.primary,
                        padding: const EdgeInsets.symmetric(
                          vertical: SigapSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(SigapRadius.md),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SigapSpacing.xl),

            // Recent activity header
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Aktivitas Terakhir',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: SigapColors.textPrimary,
                  ),
                ),
                Text(
                  'Lihat Semua',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: SigapColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: SigapSpacing.md),

            // Empty state
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(SigapSpacing.xl),
                      decoration: BoxDecoration(
                        color: SigapColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.inbox_outlined,
                        size: 48,
                        color: SigapColors.primary,
                      ),
                    ),
                    const SizedBox(height: SigapSpacing.lg),
                    const Text(
                      'Belum ada aktivitas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: SigapColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: SigapSpacing.xs),
                    const Text(
                      'Laporan yang kamu buat akan\ntampil di sini',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: SigapColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Laporan (Reports) tab content
class _LaporanTab extends ConsumerWidget {
  const _LaporanTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(SigapSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: SigapSpacing.md),
            const Text(
              'Laporan Saya',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: SigapColors.textPrimary,
              ),
            ),
            const SizedBox(height: SigapSpacing.xs),
            Text(
              'Kelola laporan yang telah kamu buat',
              style: TextStyle(fontSize: 14, color: SigapColors.textSecondary),
            ),
            const SizedBox(height: SigapSpacing.xl),

            // Empty state
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(SigapSpacing.xl),
                      decoration: BoxDecoration(
                        color: SigapColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.description_outlined,
                        size: 48,
                        color: SigapColors.primary,
                      ),
                    ),
                    const SizedBox(height: SigapSpacing.lg),
                    const Text(
                      'Belum ada laporan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: SigapColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: SigapSpacing.xs),
                    const Text(
                      'Tap tombol + untuk membuat\nlaporan pertama kamu',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: SigapColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Notifikasi (Notifications) tab content
class _NotifikasiTab extends StatelessWidget {
  const _NotifikasiTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(SigapSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: SigapSpacing.md),
            const Text(
              'Notifikasi',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: SigapColors.textPrimary,
              ),
            ),
            const SizedBox(height: SigapSpacing.xs),
            Text(
              'Pemberitahuan dan update terbaru',
              style: TextStyle(fontSize: 14, color: SigapColors.textSecondary),
            ),
            const SizedBox(height: SigapSpacing.xl),

            // Empty state
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(SigapSpacing.xl),
                      decoration: BoxDecoration(
                        color: SigapColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_outlined,
                        size: 48,
                        color: SigapColors.primary,
                      ),
                    ),
                    const SizedBox(height: SigapSpacing.lg),
                    const Text(
                      'Tidak ada notifikasi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: SigapColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: SigapSpacing.xs),
                    const Text(
                      'Pemberitahuan akan muncul\ndi sini',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: SigapColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Profil (Profile) tab content
class _ProfilTab extends ConsumerWidget {
  const _ProfilTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(SigapSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: SigapSpacing.md),

            // Profile header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: SigapColors.primary,
                    child: Text(
                      (authState.userName ?? 'W')[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: SigapSpacing.md),
                  Text(
                    authState.userName ?? '--',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: SigapColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: SigapSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SigapSpacing.md,
                      vertical: SigapSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: SigapColors.primaryLight,
                      borderRadius: BorderRadius.circular(SigapRadius.pill),
                    ),
                    child: Text(
                      authState.activeRole ??
                          authState.userRole ??
                          'Pilih Peran',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: SigapColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SigapSpacing.xxl),

            // Menu items
            _MenuItemCard(
              icon: Icons.person_outline,
              title: 'Edit Profil',
              subtitle: 'Ubah informasi akun kamu',
              onTap: () => context.push('/profile'),
            ),
            const SizedBox(height: SigapSpacing.md),
            _MenuItemCard(
              icon: Icons.settings_outlined,
              title: 'Pengaturan',
              subtitle: 'Tema, bahasa, notifikasi',
              onTap: () => context.push('/settings'),
            ),
            const SizedBox(height: SigapSpacing.md),
            _MenuItemCard(
              icon: Icons.swap_horiz,
              title: 'Ganti Peran',
              subtitle: 'Switch ke akun lain',
              onTap: () => context.push('/switch-role'),
            ),
            const SizedBox(height: SigapSpacing.xxl),

            // Logout button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _handleLogout(context, ref),
                icon: const Icon(Icons.logout, color: SigapColors.danger),
                label: const Text('Keluar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: SigapColors.danger,
                  side: const BorderSide(color: SigapColors.danger),
                  padding: const EdgeInsets.symmetric(vertical: SigapSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SigapRadius.md),
                  ),
                ),
              ),
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
        title: const Text('Keluar'),
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
            style: ElevatedButton.styleFrom(backgroundColor: SigapColors.danger),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}

/// Menu item card widget
class _MenuItemCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuItemCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SigapColors.bgCard,
        borderRadius: BorderRadius.circular(SigapRadius.lg),
        border: Border.all(color: SigapColors.borderCard),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: SigapSpacing.lg,
          vertical: SigapSpacing.sm,
        ),
        leading: Container(
          padding: const EdgeInsets.all(SigapSpacing.sm),
          decoration: BoxDecoration(
            color: SigapColors.primaryLight,
            borderRadius: BorderRadius.circular(SigapRadius.sm),
          ),
          child: Icon(icon, color: SigapColors.primary, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: SigapColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 13, color: SigapColors.textSecondary),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: SigapColors.textTertiary,
        ),
        onTap: onTap,
      ),
    );
  }
}
