import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sigap/l10n/generated/app_localizations.dart';
import 'package:sigap/l10n/status_label.dart';
import 'package:sigap/providers/providers.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/widgets/design_system/authenticated_shell.dart';
import 'package:sigap/widgets/design_system/skeleton_loaders.dart';
import 'home_screen.dart' show mergeReports, ReportItem;
import 'package:sigap/widgets/design_system/sigap_card.dart';
import '../theme/sigap_color_scheme.dart';

class LaporanScreen extends ConsumerWidget {
  const LaporanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localAsync = ref.watch(localReportsProvider);
    final serverAsync = ref.watch(wargaReportsProvider);

    return AuthenticatedShell(
      activeRole: 'WARGA',
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.laporan),
        automaticallyImplyLeading: true,
      ),
      body: localAsync.when(
        loading: () => const _LaporanLoading(),
        error: (e, _) => _ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(localReportsProvider),
        ),
        data: (localReports) => serverAsync.when(
          loading: () => const _LaporanLoading(),
          error: (e, _) => _ErrorView(
            message: e.toString(),
            onRetry: () => ref.invalidate(wargaReportsProvider),
          ),
          data: (serverReports) {
            final reports = mergeReports(localReports, serverReports);
            if (reports.isEmpty) return const _EmptyView();
            return _LaporanList(reports: reports);
          },
        ),
      ),
    );
  }
}

class _LaporanList extends ConsumerWidget {
  const _LaporanList({required this.reports});
  final List<ReportItem> reports;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(localReportsProvider);
        ref.invalidate(wargaReportsProvider);
        await Future.wait([
          ref.read(localReportsProvider.future),
          ref.read(wargaReportsProvider.future),
        ]);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(SigapSpacing.md),
        itemCount: reports.length,
        itemBuilder: (context, index) => _ReportListItem(
          report: reports[index],
          onTap: () => context.push('/laporan/${reports[index].navKey}'),
        ),
      ),
    );
  }
}

/// Report list item — mirrors home_screen._ReportListItem.
class _ReportListItem extends StatelessWidget {
  final ReportItem report;
  final VoidCallback onTap;

  const _ReportListItem({required this.report, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SigapCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SigapRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(SigapSpacing.md),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _syncDotColor(context, report.syncStatus),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: SigapSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (report.status != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: SigapSpacing.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _serverStatusColor(
                                context,
                                report.status,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                SigapRadius.pill,
                              ),
                            ),
                            child: Text(
                              _serverStatusLabel(context, report.status),
                              style: TextStyle(
                                color: _serverStatusColor(
                                  context,
                                  report.status,
                                ),
                                fontSize: SigapTypography.captionMedium,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: SigapSpacing.sm),
                        ],
                        Expanded(
                          child: Text(
                            report.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: SigapTypography.bodyTextWide,
                              fontWeight: FontWeight.w500,
                              color: SigapColorScheme.of(context).textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: SigapSpacing.xs),
                    Text(
                      _formatTimeAgo(context, report.createdAt),
                      style: TextStyle(
                        fontSize: SigapTypography.captionMedium,
                        color: SigapColorScheme.of(context).textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: SigapSpacing.sm),
              Icon(
                Icons.chevron_right,
                color: SigapColorScheme.of(context).textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _syncDotColor(BuildContext context, int syncStatus) {
    switch (syncStatus) {
      case 1:
        return SigapColorScheme.of(context).selesai;
      case 2:
        return SigapColorScheme.of(context).perluTindakan;
      default:
        return SigapColorScheme.of(context).offlineDot;
    }
  }

  Color _serverStatusColor(BuildContext context, String? status) {
    switch (status) {
      case 'submitted':
      case 'under_review':
        return SigapColorScheme.of(context).perluTindakan;
      case 'verified':
      case 'in_progress':
        return SigapColorScheme.of(context).diproses;
      case 'resolved':
        return SigapColorScheme.of(context).selesai;
      default:
        return SigapColorScheme.of(context).textMuted;
    }
  }

  String _serverStatusLabel(BuildContext context, String? status) {
    return statusLabel(context, status);
  }

  String _formatTimeAgo(BuildContext context, DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) {
      if (diff.inDays == 1) return l10n.kemarin;
      if (diff.inDays < 7) return '${diff.inDays} ${l10n.hariLalu}';
      return '${(diff.inDays / 7).floor()} ${l10n.mingguLalu}';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} ${l10n.jamLalu}';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} ${l10n.menitYangLalu}';
    }
    return l10n.baruSaja;
  }
}

class _LaporanLoading extends StatelessWidget {
  const _LaporanLoading();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(SigapSpacing.md),
      itemCount: 5,
      itemBuilder: (_, __) => SigapCard(child: SkeletonBox(height: 80)),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 64,
            color: SigapColorScheme.of(
              context,
            ).textMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: SigapSpacing.md),
          Text(
            l10n.belumAdaLaporan,
            style: TextStyle(
              fontSize: SigapTypography.bodyLarge,
              fontWeight: FontWeight.w600,
              color: SigapColorScheme.of(context).textPrimary,
            ),
          ),
          const SizedBox(height: SigapSpacing.xs),
          Text(
            l10n.laporanAndaKirimkanMuncul,
            style: TextStyle(
              fontSize: SigapTypography.bodyText,
              color: SigapColorScheme.of(context).textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: SigapColorScheme.of(
              context,
            ).perluTindakan.withValues(alpha: 0.5),
          ),
          const SizedBox(height: SigapSpacing.md),
          Text(
            l10n.gagalMemuatLaporan,
            style: TextStyle(
              fontSize: SigapTypography.bodyLarge,
              fontWeight: FontWeight.w600,
              color: SigapColorScheme.of(context).textPrimary,
            ),
          ),
          const SizedBox(height: SigapSpacing.xs),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: SigapTypography.bodySmall,
              color: SigapColorScheme.of(context).textMuted,
            ),
          ),
          const SizedBox(height: SigapSpacing.md),
          ElevatedButton(onPressed: onRetry, child: Text(l10n.cobaLagi)),
        ],
      ),
    );
  }
}
