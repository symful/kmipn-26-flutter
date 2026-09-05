import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/providers.dart';
import '../../theme/tokens.dart';
import '../../widgets/design_system/authenticated_shell.dart';
import '../../widgets/design_system/section_label.dart';
import '../../widgets/design_system/sigap_app_bar.dart';
import '../../widgets/design_system/sigap_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final activeRole = authState.activeRole ?? authState.userRole ?? '';
    final l10n = AppLocalizations.of(context)!;

    return AuthenticatedShell(
      activeRole: activeRole,
      backgroundColor: SigapColors.bgScreen,
      appBar: SigapAppBar(
        title: l10n.profil,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.pengaturan,
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(SigapSpacing.lg),
        children: [
          SigapCard(
            padding: const EdgeInsets.all(SigapSpacing.lg),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: SigapColors.primary,
                  foregroundColor: SigapColors.surface,
                  child: Text(
                    (authState.userName ?? l10n.penggunaSigap).isNotEmpty
                        ? (authState.userName ?? l10n.penggunaSigap)[0]
                              .toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: SigapTypography.headlineMedium,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: SigapSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authState.userName ?? l10n.penggunaSigap,
                        style: const TextStyle(
                          fontSize: SigapTypography.bodyLarge,
                          fontWeight: FontWeight.bold,
                          color: SigapColors.textPrimary,
                        ),
                      ),
                      if ((authState.userEmail ?? '').isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          authState.userEmail ?? '',
                          style: const TextStyle(
                            fontSize: SigapTypography.bodySmall,
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
                          (authState.activeRole ??
                                  authState.userRole ??
                                  'Warga')
                              .toUpperCase(),
                          style: const TextStyle(
                            fontSize: SigapTypography.captionSmall,
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
          ),
          const SizedBox(height: SigapSpacing.lg),
          SectionLabel(
            label: l10n.labelPeranAkses,
            padding: const EdgeInsets.only(bottom: SigapSpacing.xs),
          ),
          const SizedBox(height: SigapSpacing.sm),
          SigapCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              leading: Icon(Icons.check_circle, color: SigapColors.primary),
              title: Text(
                (authState.activeRole ??
                        authState.userRole ??
                        l10n.wargaDefault)
                    .replaceAll('_', ' ')
                    .toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: SigapTypography.bodyMedium,
                  color: SigapColors.textPrimary,
                ),
              ),
              subtitle: Text(
                l10n.peranAktifSaatIni,
                style: TextStyle(
                  fontSize: SigapTypography.bodySmall,
                  color: SigapColors.textSecondary,
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: SigapColors.textMuted,
              ),
              onTap: () => context.push('/switch-role'),
            ),
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
            label: Text(l10n.gantiPeranAktif),
            onPressed: () => context.push('/switch-role'),
          ),
          const SizedBox(height: SigapSpacing.xl),
          SectionLabel(
            label: l10n.labelPengaturanPreferensi,
            padding: const EdgeInsets.only(bottom: SigapSpacing.xs),
          ),
          const SizedBox(height: SigapSpacing.sm),
          SigapCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: SigapColors.primaryLight,
                  borderRadius: BorderRadius.circular(SigapRadius.sm),
                ),
                child: const Icon(
                  Icons.tune,
                  size: 20,
                  color: SigapColors.primary,
                ),
              ),
              title: Text(
                l10n.pengaturanAplikasi,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: SigapTypography.bodyMedium,
                  color: SigapColors.textPrimary,
                ),
              ),
              subtitle: Text(
                l10n.subtitlePengaturan,
                style: const TextStyle(
                  fontSize: SigapTypography.bodySmall,
                  color: SigapColors.textSecondary,
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: SigapColors.textMuted,
              ),
              onTap: () => context.push('/settings'),
            ),
          ),
          const SizedBox(height: SigapSpacing.lg),
          ElevatedButton.icon(
            icon: const Icon(Icons.logout, size: 20),
            label: Text(l10n.keluar),
            style: ElevatedButton.styleFrom(
              backgroundColor: SigapColors.perluTindakan,
              foregroundColor: SigapColors.surface,
              padding: const EdgeInsets.symmetric(vertical: SigapSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SigapRadius.md),
              ),
            ),
            onPressed: () => _handleLogout(context, ref),
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        final dl10n = AppLocalizations.of(ctx)!;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SigapRadius.lg),
          ),
          backgroundColor: SigapColors.surface,
          title: Row(
            children: [
              Icon(Icons.logout, color: SigapColors.perluTindakan),
              SizedBox(width: SigapSpacing.sm),
              Text(
                dl10n.keluar,
                style: TextStyle(
                  fontSize: SigapTypography.bodyLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            dl10n.apakahYakinKeluar,
            style: const TextStyle(
              fontSize: SigapTypography.bodyText,
              color: SigapColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                dl10n.batal,
                style: TextStyle(color: SigapColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Invalidate all data providers before clearing auth state
                ref.invalidate(wargaReportsProvider);
                ref.invalidate(wargaStatsProvider);
                ref.invalidate(localReportsProvider);
                ref.invalidate(surveyorTasksProvider);
                ref.invalidate(notificationsProvider);
                ref.invalidate(unreadCountProvider);
                ref.invalidate(wilayahProvider);
                ref.invalidate(userWilayahProvider);
                ref.invalidate(categoriesProvider);
                ref.read(authNotifierProvider.notifier).logout();
                context.go('/');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: SigapColors.perluTindakan,
                foregroundColor: SigapColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SigapRadius.sm),
                ),
              ),
              child: Text(dl10n.keluar),
            ),
          ],
        );
      },
    );
  }
}
