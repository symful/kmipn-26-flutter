import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sigap/api/client.dart';
import 'package:sigap/l10n/generated/app_localizations.dart';
import 'package:sigap/providers/providers.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/widgets/design_system/skeleton_loaders.dart';
import 'package:sigap/widgets/design_system/sigap_card.dart';
import 'package:sigap/providers/capability_provider.dart';
import 'package:sigap/widgets/design_system/metric_card.dart';
import 'package:sigap/widgets/design_system/progress_metric_card.dart';
import 'package:sigap/widgets/design_system/trend_chart.dart';
import 'package:sigap/widgets/design_system/urgent_case_list.dart';
import 'package:sigap/widgets/design_system/error_card.dart';

// ─── Dashboard Data Models ────────────────────────────────────────────────────

/// Queue count data for operator dashboard.
class QueueCounts {
  final int newReports;
  final int needsVerification;
  final int slaBreached;
  final int highPriority;
  final int needsCompletion;

  const QueueCounts({
    required this.newReports,
    required this.needsVerification,
    required this.slaBreached,
    required this.highPriority,
    required this.needsCompletion,
  });
}

/// Backlog trend data point.
class BacklogPoint {
  final String day;
  final int laporanCount;
  final int kasusCount;

  const BacklogPoint({
    required this.day,
    required this.laporanCount,
    required this.kasusCount,
  });
}

/// Critical case item.
class CriticalCaseItem {
  final String id;
  final String title;
  final String caseCode;
  final String village;
  final int slaHoursRemaining;
  final bool isOverdue;

  const CriticalCaseItem({
    required this.id,
    required this.title,
    required this.caseCode,
    required this.village,
    required this.slaHoursRemaining,
    required this.isOverdue,
  });
}

// ─── Dashboard Providers ───────────────────────────────────────────────────────

/// Fetches dashboard stats for the current user.
final dashboardStatsProvider = FutureProvider<StatsResponse>((ref) async {
  final api = ref.watch(apiClientProvider);
  return await api.getStats();
});

/// Fetches queue counts for operator dashboard.
final queueCountsProvider = FutureProvider<QueueCounts>((ref) async {
  final api = ref.watch(apiClientProvider);
  final stats = await api.getStats();
  final byStatus = stats.byStatus;
  return QueueCounts(
    newReports:
        (byStatus?['submitted'] as int? ?? 0) +
        (byStatus?['needs_survey'] as int? ?? 0),
    needsVerification: byStatus?['under_review'] as int? ?? 0,
    slaBreached: stats.slaBreached ?? 0,
    highPriority:
        (byStatus?['submitted'] as int? ?? 0) +
        (byStatus?['needs_survey'] as int? ?? 0),
    needsCompletion: byStatus?['needs_completion'] as int? ?? 0,
  );
});

/// Fetches critical cases for the dashboard.
final criticalCasesProvider = FutureProvider<List<CriticalCaseItem>>((
  ref,
) async {
  // TODO: Wire to real /api/stats/sla-near-breach endpoint when T16 is done
  return [];
});

/// Fetches reports for backlog computation.
final dashboardReportsProvider = FutureProvider<List<Report>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final result = await api.getReports(limit: 100);
  return result.data;
});

/// Computes backlog trend from reports.
final backlogTrendProvider = FutureProvider<List<BacklogPoint>>((ref) async {
  final reports = await ref.watch(dashboardReportsProvider.future);
  if (reports.isEmpty) return [];

  // Group by date and count reports/cases
  final Map<String, int> laporanByDate = {};
  final Map<String, int> kasusByDate = {};

  for (final report in reports) {
    final date = report.createdAt?.substring(0, 10) ?? 'unknown';
    final isCase =
        report.status == ReportStatus.verified ||
        report.status == ReportStatus.inProgress ||
        report.status == ReportStatus.resolved;
    laporanByDate[date] = (laporanByDate[date] ?? 0) + 1;
    if (isCase) {
      kasusByDate[date] = (kasusByDate[date] ?? 0) + 1;
    }
  }

  // Take last 30 days
  final sortedDates = laporanByDate.keys.toList()..sort();
  final recentDates = sortedDates.length > 30
      ? sortedDates.sublist(sortedDates.length - 30)
      : sortedDates;

  return recentDates.map((date) {
    return BacklogPoint(
      day: date.substring(5), // MM-DD
      laporanCount: laporanByDate[date] ?? 0,
      kasusCount: kasusByDate[date] ?? 0,
    );
  }).toList();
});

// ─── Dashboard Skeleton ────────────────────────────────────────────────────────

/// Skeleton loading for the government dashboard screen.
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(SigapSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          SkeletonBox(width: 200, height: 24, borderRadius: 4),
          const SizedBox(height: SigapSpacing.xs),
          SkeletonBox(width: 150, height: 14, borderRadius: 4),
          const SizedBox(height: SigapSpacing.lg),

          // Stat cards row
          Row(
            children: [
              for (int i = 0; i < 4; i++) ...[
                if (i > 0) const SizedBox(width: SigapSpacing.sm),
                const Expanded(child: SkeletonStatCard()),
              ],
            ],
          ),
          const SizedBox(height: SigapSpacing.lg),

          // Queue cards (5 cards for operator)
          Row(
            children: [
              for (int i = 0; i < 5; i++) ...[
                if (i > 0) const SizedBox(width: SigapSpacing.sm),
                Expanded(
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: SigapColors.surface,
                      borderRadius: BorderRadius.circular(SigapRadius.md),
                      border: Border.all(color: SigapColors.border),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(SigapSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SkeletonBox(width: 40, height: 20, borderRadius: 4),
                          const SizedBox(height: SigapSpacing.xs),
                          SkeletonBox(width: 60, height: 12, borderRadius: 4),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: SigapSpacing.lg),

          // Backlog chart + map row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  height: 180,
                  padding: const EdgeInsets.all(SigapSpacing.md),
                  decoration: BoxDecoration(
                    color: SigapColors.surface,
                    borderRadius: BorderRadius.circular(SigapRadius.md),
                    border: Border.all(color: SigapColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: 120, height: 14, borderRadius: 4),
                      const SizedBox(height: SigapSpacing.md),
                      Row(
                        children: [
                          for (int i = 0; i < 10; i++) ...[
                            if (i > 0) const SizedBox(width: SigapSpacing.xs),
                            const Expanded(
                              child: SkeletonBox(height: 80, borderRadius: 2),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: SigapSpacing.md),
              Expanded(
                flex: 2,
                child: Container(
                  height: 180,
                  padding: const EdgeInsets.all(SigapSpacing.md),
                  decoration: BoxDecoration(
                    color: SigapColors.surface,
                    borderRadius: BorderRadius.circular(SigapRadius.md),
                    border: Border.all(color: SigapColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: 100, height: 14, borderRadius: 4),
                      const SizedBox(height: SigapSpacing.md),
                      const Expanded(
                        child: SkeletonBox(
                          height: 80,
                          borderRadius: SigapRadius.md,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: SigapSpacing.lg),

          // Critical cases
          Container(
            padding: const EdgeInsets.all(SigapSpacing.md),
            decoration: BoxDecoration(
              color: SigapColors.surface,
              borderRadius: BorderRadius.circular(SigapRadius.md),
              border: Border.all(color: SigapColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 100, height: 14, borderRadius: 4),
                const SizedBox(height: SigapSpacing.md),
                for (int i = 0; i < 3; i++) ...[
                  SkeletonBox(
                    width: double.infinity,
                    height: 50,
                    borderRadius: 4,
                  ),
                  if (i < 2) const SizedBox(height: SigapSpacing.sm),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Admin Daerah Section ─────────────────────────────────────────────────────

class _AdminDaerahSection extends ConsumerWidget {
  const _AdminDaerahSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Text(
          AppLocalizations.of(context)!.ringkasanOperasionalDaerah,
          style: const TextStyle(
            fontSize: SigapTypography.titleLarge,
            fontWeight: FontWeight.w700,
            color: SigapColors.textPrimary,
          ),
        ),
        const SizedBox(height: SigapSpacing.xs),
        Text(
          AppLocalizations.of(context)!.dataPenangananKasusDaerah,
          style: const TextStyle(
            fontSize: SigapTypography.bodySmall,
            color: SigapColors.textTertiary,
          ),
        ),
        const SizedBox(height: SigapSpacing.lg),

        // Stats cards
        statsAsync.when(
          data: (stats) {
            final totalCases =
                (stats.byStatus?['submitted'] as int? ?? 0) +
                (stats.byStatus?['verified'] as int? ?? 0) +
                (stats.byStatus?['in_progress'] as int? ?? 0) +
                (stats.byStatus?['resolved'] as int? ?? 0);
            final slaBreached = stats.slaBreached ?? 0;
            final inProgress =
                (stats.byStatus?['in_progress'] as int? ?? 0) +
                (stats.byStatus?['verified'] as int? ?? 0) +
                (stats.byStatus?['assigned'] as int? ?? 0);

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: MetricCard(
                        label: AppLocalizations.of(context)!.totalKasus,
                        value: totalCases.toString(),
                        color: SigapColors.textPrimary,
                        severityColor: SigapColors.primary,
                      ),
                    ),
                    const SizedBox(width: SigapSpacing.sm),
                    Expanded(
                      child: MetricCard(
                        label: AppLocalizations.of(
                          context,
                        )!.labelSLATerlewatDashboard,
                        value: slaBreached.toString(),
                        color: SigapColors.textPrimary,
                        severityColor: SigapColors.danger,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SigapSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: MetricCard(
                        label: AppLocalizations.of(
                          context,
                        )!.labelSedangDiproses,
                        value: inProgress.toString(),
                        color: SigapColors.textPrimary,
                        severityColor: SigapColors.info,
                      ),
                    ),
                    const SizedBox(width: SigapSpacing.sm),
                    const Expanded(child: SizedBox()),
                  ],
                ),
              ],
            );
          },
          loading: () => const DashboardSkeleton(),
          error: (_, __) => ErrorCard(
            message: AppLocalizations.of(context)!.gagalMemuatStatistik,
          ),
        ),
      ],
    );
  }
}

// ─── Operator Queue Section ──────────────────────────────────────────────────

class _OperatorQueueSection extends ConsumerWidget {
  const _OperatorQueueSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueAsync = ref.watch(queueCountsProvider);
    final backlogAsync = ref.watch(backlogTrendProvider);
    final criticalAsync = ref.watch(criticalCasesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Text(
          AppLocalizations.of(context)!.apaYangHarusDitanganiHariIni,
          style: const TextStyle(
            fontSize: SigapTypography.titleLarge,
            fontWeight: FontWeight.w700,
            color: SigapColors.textPrimary,
          ),
        ),
        const SizedBox(height: SigapSpacing.lg),

        // Queue cards
        queueAsync.when(
          data: (queue) => _QueueCardsRow(queue: queue),
          loading: () => const _QueueCardsLoading(),
          error: (_, __) => ErrorCard(
            message: AppLocalizations.of(context)!.gagalMemuatAntrean,
          ),
        ),
        const SizedBox(height: SigapSpacing.lg),

        // Backlog chart + Map row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Backlog chart
            Expanded(
              flex: 3,
              child: backlogAsync.when(
                data: (backlog) {
                  final List<ChartDataPoint> trendData = backlog
                      .map(
                        (b) => ChartDataPoint(
                          label: b.day,
                          primaryValue: b.laporanCount,
                          secondaryValue: b.kasusCount,
                        ),
                      )
                      .toList();
                  return TrendChart(
                    data: trendData,
                    primaryLabel: 'laporan',
                    secondaryLabel: 'kasus',
                    primaryColor: SigapColors.info,
                    secondaryColor: SigapColors.primary,
                  );
                },
                loading: () => const TrendChartLoading(),
                error: (_, __) => ErrorCard(
                  message: AppLocalizations.of(context)!.gagalMemuatTren,
                ),
              ),
            ),
            const SizedBox(width: SigapSpacing.md),
            // Mini map placeholder
            Expanded(flex: 2, child: const _MiniMapCard()),
          ],
        ),
        const SizedBox(height: SigapSpacing.lg),

        // Critical cases
        criticalAsync.when(
          data: (cases) => _CriticalCasesList(cases: cases),
          loading: () => const UrgentCaseListLoading(),
          error: (_, __) => ErrorCard(
            message: AppLocalizations.of(context)!.gagalMemuatKasusKritis,
          ),
        ),
      ],
    );
  }
}

class _QueueCardsRow extends StatelessWidget {
  final QueueCounts queue;

  const _QueueCardsRow({required this.queue});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: QueueCard(
            value: queue.newReports.toString(),
            label: AppLocalizations.of(context)!.labelKasusBaru,
            color: SigapColors.info,
          ),
        ),
        const SizedBox(width: SigapSpacing.sm),
        Expanded(
          child: QueueCard(
            value: queue.needsVerification.toString(),
            label: AppLocalizations.of(context)!.labelPerluVerifikasi,
            color: SigapColors.warning,
          ),
        ),
        const SizedBox(width: SigapSpacing.sm),
        Expanded(
          child: QueueCard(
            value: queue.slaBreached.toString(),
            label: AppLocalizations.of(context)!.labelSlaTerlewat,
            color: SigapColors.danger,
          ),
        ),
        const SizedBox(width: SigapSpacing.sm),
        Expanded(
          child: QueueCard(
            value: queue.highPriority.toString(),
            label: AppLocalizations.of(context)!.labelPrioritasTinggi,
            color: SigapColors.primary,
          ),
        ),
        const SizedBox(width: SigapSpacing.sm),
        Expanded(
          child: QueueCard(
            value: queue.needsCompletion.toString(),
            label: AppLocalizations.of(context)!.labelPerluKelengkapan,
            color: SigapColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _QueueCardsLoading extends StatelessWidget {
  const _QueueCardsLoading();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < 5; i++) ...[
          if (i > 0) const SizedBox(width: SigapSpacing.sm),
          Expanded(
            child: Container(
              height: 80,
              padding: const EdgeInsets.all(SigapSpacing.md),
              decoration: BoxDecoration(
                color: SigapColors.surface,
                borderRadius: BorderRadius.circular(SigapRadius.md),
                border: Border.all(color: SigapColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SkeletonBox(width: 40, height: 22, borderRadius: 4),
                  const SizedBox(height: SigapSpacing.xs),
                  SkeletonBox(width: 60, height: 12, borderRadius: 4),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _MiniMapCard extends StatelessWidget {
  const _MiniMapCard();

  @override
  Widget build(BuildContext context) {
    return SigapCard(
      padding: const EdgeInsets.all(SigapSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.petaRingkasKasus,
                style: const TextStyle(
                  fontSize: SigapTypography.bodyText,
                  fontWeight: FontWeight.w600,
                  color: SigapColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/map'),
                child: Text(
                  AppLocalizations.of(context)!.bukaPeta,
                  style: const TextStyle(
                    fontSize: SigapTypography.captionMedium,
                    fontWeight: FontWeight.w600,
                    color: SigapColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: SigapSpacing.md),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: SigapColors.bgSurface,
                borderRadius: BorderRadius.circular(SigapRadius.sm),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map_outlined,
                      size: 32,
                      color: SigapColors.textTertiary,
                    ),
                    SizedBox(height: SigapSpacing.xs),
                    Text(
                      AppLocalizations.of(context)!.lihatSemuaKasusDiPeta,
                      style: TextStyle(
                        fontSize: SigapTypography.captionMedium,
                        color: SigapColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CriticalCasesList extends StatelessWidget {
  final List<CriticalCaseItem> cases;

  const _CriticalCasesList({required this.cases});

  @override
  Widget build(BuildContext context) {
    final urgentCases = cases
        .map(
          (c) => UrgentCaseItem(
            id: c.id,
            title: c.title,
            subtitle: '${c.caseCode} · ${c.village}',
            slaHoursRemaining: c.slaHoursRemaining,
            isOverdue: c.isOverdue,
          ),
        )
        .toList();
    return UrgentCaseList(cases: urgentCases);
  }
}

// ─── Auditor Section ───────────────────────────────────────────────────────────

class _AuditorSection extends ConsumerWidget {
  const _AuditorSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SigapCard(
      padding: const EdgeInsets.all(SigapSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: SigapColors.primary,
                  borderRadius: BorderRadius.circular(SigapRadius.sm),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'A',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: SigapSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.dashboardAuditor,
                    style: const TextStyle(
                      fontSize: SigapTypography.bodyLarge,
                      fontWeight: FontWeight.w700,
                      color: SigapColors.textPrimary,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.auditIntegrityMonitoring,
                    style: const TextStyle(
                      fontSize: SigapTypography.captionMedium,
                      color: SigapColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: SigapSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => context.push('/audit'),
                child: Text(
                  AppLocalizations.of(context)!.lihatLogAktivitas,
                  style: const TextStyle(
                    fontSize: SigapTypography.bodySmall,
                    fontWeight: FontWeight.w600,
                    color: SigapColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Analytics Section ─────────────────────────────────────────────────────────

class _AnalyticsSection extends ConsumerWidget {
  const _AnalyticsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return statsAsync.when(
      data: (stats) {
        final total =
            (stats.byStatus?['submitted'] as int? ?? 0) +
            (stats.byStatus?['verified'] as int? ?? 0) +
            (stats.byStatus?['in_progress'] as int? ?? 0) +
            (stats.byStatus?['resolved'] as int? ?? 0);
        final slaBreached = stats.slaBreached ?? 0;
        final resolved = stats.byStatus?['resolved'] as int? ?? 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // KPI Stats row
            Row(
              children: [
                Expanded(
                  child: KPICard(
                    label: AppLocalizations.of(context)!.labelTotalAntrean,
                    value: total.toString(),
                    color: SigapColors.textPrimary,
                  ),
                ),
                const SizedBox(width: SigapSpacing.sm),
                Expanded(
                  child: KPICard(
                    label: AppLocalizations.of(context)!.selesai,
                    value: resolved.toString(),
                    color: SigapColors.selesai,
                  ),
                ),
              ],
            ),
            const SizedBox(height: SigapSpacing.lg),

            // Data quality panel
            ProgressMetricCard(
              label: AppLocalizations.of(context)!.labelTepatWaktu,
              percentage: total > 0
                  ? ((total - slaBreached) / total * 100).round()
                  : 0,
              color: SigapColors.selesai,
              subtitle: AppLocalizations.of(
                context,
              )!.kasusBerisikoSLA(stats.slaAtRisk ?? 0),
            ),
          ],
        );
      },
      loading: () => const DashboardSkeleton(),
      error: (_, __) =>
          ErrorCard(message: AppLocalizations.of(context)!.gagalMemuatAnalitik),
    );
  }
}

// ─── Main Dashboard Screen ─────────────────────────────────────────────────────

/// W-02 Dashboard Pemerintah — capability-gated government dashboard.
///
/// Shows different sections based on user capabilities:
/// - `admin.users.manage`: Admin Daerah summary stats
/// - `case.dispatch`: Operator queue cards, backlog trend, mini map, critical cases
/// - `audit.read`: Auditor dashboard section
/// - `analytics.read`: Analytics KPIs and data quality
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Expanded(
          child: Scaffold(
            backgroundColor: SigapColors.bgSurface,
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.dashboard),
              backgroundColor: SigapColors.surface,
              foregroundColor: SigapColors.textPrimary,
              elevation: 0,
            ),
            body: const _DashboardBody(),
          ),
        ),
      ],
    );
  }
}

class _DashboardBody extends ConsumerWidget {
  const _DashboardBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Import Can widget for capability gating
    final canWidget = ref.watch(
      capabilityNotifierProvider.select((s) => s.valueOrNull),
    );

    final statsAsync = ref.watch(dashboardStatsProvider);

    // Build capability check helper
    bool hasCapability(String action) {
      final caps = canWidget?.capabilities ?? {};
      return caps.contains(action);
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(SigapSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Admin Daerah section (admin.users.manage)
          if (hasCapability('admin.users.manage')) ...[
            const _AdminDaerahSection(),
            const SizedBox(height: SigapSpacing.xl),
          ],

          // Operator queue section (case.dispatch)
          if (hasCapability('case.dispatch')) ...[
            const _OperatorQueueSection(),
            const SizedBox(height: SigapSpacing.xl),
          ],

          // Auditor section (audit.read)
          if (hasCapability('audit.read')) ...[
            const _AuditorSection(),
            const SizedBox(height: SigapSpacing.xl),
          ],

          // Analytics section (analytics.read)
          if (hasCapability('analytics.read')) ...[
            const _AnalyticsSection(),
            const SizedBox(height: SigapSpacing.xl),
          ],

          // Show skeleton while loading
          statsAsync.when(
            data: (_) => const SizedBox.shrink(),
            loading: () => const DashboardSkeleton(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
