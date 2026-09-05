import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sigap/widgets/design_system/responsive_scaffold.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/providers.dart';
import '../../providers/capability_provider.dart';
import '../../theme/tokens.dart';
import '../../widgets/design_system/sigap_card.dart';

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

    return ResponsiveScaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.gantiPeranPengguna),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: SigapColors.primary),
              )
            : ListView(
                padding: const EdgeInsets.all(SigapSpacing.lg),
                children: [
                  // Info banner
                  Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return Container(
                        padding: const EdgeInsets.all(SigapSpacing.md),
                        decoration: BoxDecoration(
                          color: SigapColors.primaryLight.withValues(
                            alpha: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(SigapRadius.md),
                          border: Border.all(
                            color: SigapColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.swap_horiz,
                              color: SigapColors.primary,
                              size: 24,
                            ),
                            SizedBox(width: SigapSpacing.md),
                            Expanded(
                              child: Text(
                                l10n.pilihPeranKonteks,
                                style: TextStyle(
                                  fontSize: SigapTypography.bodySmall,
                                  color: SigapColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: SigapSpacing.lg),

                  Text(
                    AppLocalizations.of(context)!.peranTersedia,
                    style: const TextStyle(
                      fontSize: SigapTypography.bodyMedium,
                      fontWeight: FontWeight.bold,
                      color: SigapColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: SigapSpacing.sm),

                  if (roles.isEmpty)
                    _emptyRolesCard(
                      currentRole:
                          activeRole ?? authState.userRole ?? 'Unknown',
                      context: context,
                    )
                  else
                    ...roles.map(
                      (role) => Padding(
                        padding: const EdgeInsets.only(bottom: SigapSpacing.sm),
                        child: _roleSwitchCard(
                          role: role,
                          isActive:
                              role.toLowerCase() == activeRole?.toLowerCase(),
                          onTap: role.toLowerCase() == activeRole?.toLowerCase()
                              ? null
                              : () => _handleRoleSwitch(role),
                          context: context,
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
        // Invalidate all data providers so they refetch with new role's capabilities
        ref.invalidate(wargaReportsProvider);
        ref.invalidate(wargaStatsProvider);
        ref.invalidate(localReportsProvider);
        ref.invalidate(surveyorTasksProvider);
        ref.invalidate(notificationsProvider);
        ref.invalidate(unreadCountProvider);
        ref.invalidate(wilayahProvider);
        ref.invalidate(userWilayahProvider);
        ref.invalidate(categoriesProvider);

        // Refresh capabilities for the new role (async, non-blocking)
        ref.read(capabilityNotifierProvider.notifier).refetch();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              )!.berhasilBeralihPeran(_formatRoleName(role)),
            ),
            backgroundColor: SigapColors.primary,
          ),
        );
        if (!mounted) return;
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.gagalBeralihPeran),
            backgroundColor: SigapColors.perluTindakan,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.errorDenganPesan(e.toString()),
          ),
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

/// Builds a role switch card using SigapCard.
Widget _roleSwitchCard({
  required String role,
  required bool isActive,
  required VoidCallback? onTap,
  required BuildContext context,
}) {
  final roleColor = _getRoleColor(role);

  return SigapCard(
    borderLeftColor: isActive ? SigapColors.primary : null,
    padding: EdgeInsets.zero,
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
            _formatRoleNameStatic(role),
            style: TextStyle(
              fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
              fontSize: SigapTypography.bodyMedium,
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
              child: Text(
                AppLocalizations.of(context)!.aktif,
                style: const TextStyle(
                  fontSize: SigapTypography.captionMicro,
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
          _getRoleDescription(role, AppLocalizations.of(context)!),
          style: TextStyle(
            fontSize: SigapTypography.bodySmall,
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

String _formatRoleNameStatic(String role) {
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

String _getRoleDescription(String role, AppLocalizations l10n) {
  switch (role.toLowerCase()) {
    case 'admin':
    case 'admin_daerah':
      return l10n.roleDescAdmin;
    case 'operator':
      return l10n.roleDescOperator;
    case 'verifikator':
      return l10n.roleDescVerifikator;
    case 'petugas':
      return l10n.roleDescPetugas;
    case 'surveyor':
      return l10n.roleDescSurveyor;
    case 'auditor':
      return l10n.roleDescAuditor;
    case 'warga':
      return l10n.roleDescWarga;
    case 'exec':
      return l10n.roleDescExec;
    default:
      return l10n.roleDescDefault;
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

/// Builds an empty roles card using SigapCard.
Widget _emptyRolesCard({
  required String currentRole,
  required BuildContext context,
}) {
  return SigapCard(
    padding: const EdgeInsets.all(SigapSpacing.lg),
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
        Text(
          AppLocalizations.of(context)!.peranSaatIni,
          style: const TextStyle(
            fontSize: SigapTypography.bodySmall,
            color: SigapColors.textSecondary,
          ),
        ),
        const SizedBox(height: SigapSpacing.xs),
        Text(
          currentRole.toUpperCase(),
          style: const TextStyle(
            fontSize: SigapTypography.titleLarge,
            fontWeight: FontWeight.bold,
            color: SigapColors.primary,
          ),
        ),
        const SizedBox(height: SigapSpacing.md),
        Text(
          AppLocalizations.of(context)!.akunHanyaSatuPeran,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: SigapTypography.bodyText,
            color: SigapColors.textSecondary,
          ),
        ),
      ],
    ),
  );
}
