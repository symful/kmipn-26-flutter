import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sigap/api/client.dart';
import 'package:sigap/providers/providers.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/widgets/design_system/phone_frame.dart';
import 'package:sigap/widgets/design_system/skeleton_loaders.dart';
import 'package:sigap/widgets/design_system/sigap_card.dart';
import 'package:sigap/widgets/design_system/status_bar.dart';
import 'package:sigap/providers/capability_provider.dart';

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
        const Text(
          'Ringkasan Operasional Daerah',
          style: TextStyle(
            fontSize: SigapTypography.size18,
            fontWeight: FontWeight.w700,
            color: SigapColors.textPrimary,
          ),
        ),
        const SizedBox(height: SigapSpacing.xs),
        const Text(
          'Data penanganan kasus daerah',
          style: TextStyle(
            fontSize: SigapTypography.size12,
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
                      child: _StatCard(
                        label: 'Total Kasus',
                        value: totalCases.toString(),
                        severityColor: SigapColors.primary,
                      ),
                    ),
                    const SizedBox(width: SigapSpacing.sm),
                    Expanded(
                      child: _StatCard(
                        label: 'SLA Terlewat',
                        value: slaBreached.toString(),
                        severityColor: SigapColors.danger,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SigapSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Sedang Diproses',
                        value: inProgress.toString(),
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
          error: (_, __) => const _ErrorCard(message: 'Gagal memuat statistik'),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color severityColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.severityColor,
  });

  @override
  Widget build(BuildContext context) {
    return SigapCard(
      borderLeftColor: severityColor,
      padding: const EdgeInsets.all(SigapSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: SigapTypography.size11,
              fontWeight: FontWeight.w500,
              color: SigapColors.textMuted,
            ),
          ),
          const SizedBox(height: SigapSpacing.xs),
          Text(
            value,
            style: const TextStyle(
              fontSize: SigapTypography.size24,
              fontWeight: FontWeight.w700,
              color: SigapColors.textPrimary,
            ),
          ),
        ],
      ),
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
        const Text(
          'Apa yang harus ditangani hari ini?',
          style: TextStyle(
            fontSize: SigapTypography.size18,
            fontWeight: FontWeight.w700,
            color: SigapColors.textPrimary,
          ),
        ),
        const SizedBox(height: SigapSpacing.lg),

        // Queue cards
        queueAsync.when(
          data: (queue) => _QueueCardsRow(queue: queue),
          loading: () => const _QueueCardsLoading(),
          error: (_, __) => const _ErrorCard(message: 'Gagal memuat antrean'),
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
                data: (backlog) => _BacklogChart(backlog: backlog),
                loading: () => const _BacklogChartLoading(),
                error: (_, __) =>
                    const _ErrorCard(message: 'Gagal memuat tren'),
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
          loading: () => const _CriticalCasesLoading(),
          error: (_, __) =>
              const _ErrorCard(message: 'Gagal memuat kasus kritis'),
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
          child: _QueueCard(
            value: queue.newReports.toString(),
            label: 'Kasus baru',
            color: SigapColors.info,
          ),
        ),
        const SizedBox(width: SigapSpacing.sm),
        Expanded(
          child: _QueueCard(
            value: queue.needsVerification.toString(),
            label: 'Perlu verifikasi',
            color: SigapColors.warning,
          ),
        ),
        const SizedBox(width: SigapSpacing.sm),
        Expanded(
          child: _QueueCard(
            value: queue.slaBreached.toString(),
            label: 'SLA terlewat',
            color: SigapColors.danger,
          ),
        ),
        const SizedBox(width: SigapSpacing.sm),
        Expanded(
          child: _QueueCard(
            value: queue.highPriority.toString(),
            label: 'Prioritas tinggi',
            color: SigapColors.primary,
          ),
        ),
        const SizedBox(width: SigapSpacing.sm),
        Expanded(
          child: _QueueCard(
            value: queue.needsCompletion.toString(),
            label: 'Perlu kelengkapan',
            color: SigapColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _QueueCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _QueueCard({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SigapSpacing.md),
      decoration: BoxDecoration(
        color: SigapColors.surface,
        borderRadius: BorderRadius.circular(SigapRadius.md),
        border: Border.all(color: SigapColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: SigapTypography.size22,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          SizedBox(height: SigapSpacing.xxs),
          Text(
            label,
            style: const TextStyle(
              fontSize: SigapTypography.size10,
              color: SigapColors.textTertiary,
            ),
          ),
        ],
      ),
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

class _BacklogChart extends StatelessWidget {
  final List<BacklogPoint> backlog;

  const _BacklogChart({required this.backlog});

  @override
  Widget build(BuildContext context) {
    if (backlog.isEmpty) {
      return SigapCard(
        padding: const EdgeInsets.all(SigapSpacing.md),
        child: const Center(
          child: Text(
            'Tidak ada data tren',
            style: TextStyle(
              color: SigapColors.textMuted,
              fontSize: SigapTypography.size13,
            ),
          ),
        ),
      );
    }

    final maxValue = backlog.fold<int>(
      1,
      (max, p) =>
          [max, p.laporanCount, p.kasusCount].reduce((a, b) => a > b ? a : b),
    );

    return SigapCard(
      padding: const EdgeInsets.all(SigapSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Umur backlog kasus',
                style: TextStyle(
                  fontSize: SigapTypography.size13,
                  fontWeight: FontWeight.w600,
                  color: SigapColors.textPrimary,
                ),
              ),
              Row(
                children: [
                  const _LegendDot(color: SigapColors.info),
                  const SizedBox(width: SigapSpacing.xs),
                  const Text(
                    'laporan',
                    style: TextStyle(
                      fontSize: SigapTypography.size10,
                      color: SigapColors.textTertiary,
                    ),
                  ),
                  const SizedBox(width: SigapSpacing.sm),
                  const _LegendDot(color: SigapColors.primary),
                  const SizedBox(width: SigapSpacing.xs),
                  const Text(
                    'kasus',
                    style: TextStyle(
                      fontSize: SigapTypography.size10,
                      color: SigapColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: SigapSpacing.md),
          SizedBox(
            height: 110,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: backlog.map((point) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: FractionallySizedBox(
                            heightFactor: maxValue > 0
                                ? point.laporanCount / maxValue
                                : 0,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: SigapColors.info,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Flexible(
                          child: FractionallySizedBox(
                            heightFactor: maxValue > 0
                                ? point.kasusCount / maxValue
                                : 0,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: SigapColors.primary,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;

  const _LegendDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _BacklogChartLoading extends StatelessWidget {
  const _BacklogChartLoading();

  @override
  Widget build(BuildContext context) {
    return SigapCard(
      padding: const EdgeInsets.all(SigapSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 120, height: 14, borderRadius: 4),
          const SizedBox(height: SigapSpacing.md),
          SizedBox(
            height: 110,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(
                10,
                (_) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: SkeletonBox(height: 80, borderRadius: 2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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
              const Text(
                'Peta ringkas kasus',
                style: TextStyle(
                  fontSize: SigapTypography.size13,
                  fontWeight: FontWeight.w600,
                  color: SigapColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/map'),
                child: const Text(
                  'Buka Peta →',
                  style: TextStyle(
                    fontSize: SigapTypography.size11,
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
              child: const Center(
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
                      'Lihat semua kasus di peta',
                      style: TextStyle(
                        fontSize: SigapTypography.size11,
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
    return SigapCard(
      padding: const EdgeInsets.all(SigapSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kasus kritis',
            style: TextStyle(
              fontSize: SigapTypography.size13,
              fontWeight: FontWeight.w600,
              color: SigapColors.textPrimary,
            ),
          ),
          const SizedBox(height: SigapSpacing.md),
          if (cases.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(SigapSpacing.lg),
                child: Text(
                  'Tidak ada kasus kritis',
                  style: TextStyle(
                    fontSize: SigapTypography.size12,
                    color: SigapColors.textTertiary,
                  ),
                ),
              ),
            )
          else
            ...cases.map((c) => _CriticalCaseItem(caseItem: c)),
        ],
      ),
    );
  }
}

class _CriticalCaseItem extends StatelessWidget {
  final CriticalCaseItem caseItem;

  const _CriticalCaseItem({required this.caseItem});

  @override
  Widget build(BuildContext context) {
    final urgencyColor = caseItem.isOverdue
        ? SigapColors.danger
        : SigapColors.warning;
    final slaText = caseItem.isOverdue
        ? 'Overdue'
        : '${caseItem.slaHoursRemaining}h';

    return Padding(
      padding: const EdgeInsets.only(bottom: SigapSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: urgencyColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: SigapSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  caseItem.title,
                  style: const TextStyle(
                    fontSize: SigapTypography.size12,
                    fontWeight: FontWeight.w500,
                    color: SigapColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${caseItem.caseCode} · ${caseItem.village}',
                  style: const TextStyle(
                    fontSize: SigapTypography.size10,
                    color: SigapColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            slaText,
            style: TextStyle(
              fontSize: SigapTypography.size11,
              fontWeight: FontWeight.w600,
              color: urgencyColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _CriticalCasesLoading extends StatelessWidget {
  const _CriticalCasesLoading();

  @override
  Widget build(BuildContext context) {
    return SigapCard(
      padding: const EdgeInsets.all(SigapSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 100, height: 14, borderRadius: 4),
          const SizedBox(height: SigapSpacing.md),
          for (int i = 0; i < 3; i++) ...[
            Row(
              children: [
                SkeletonBox(width: 8, height: 8, borderRadius: 4),
                const SizedBox(width: SigapSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(
                        width: double.infinity,
                        height: 12,
                        borderRadius: 4,
                      ),
                      const SizedBox(height: SigapSpacing.xxs),
                      SkeletonBox(width: 100, height: 10, borderRadius: 4),
                    ],
                  ),
                ),
                const SizedBox(width: SigapSpacing.sm),
                SkeletonBox(width: 40, height: 12, borderRadius: 4),
              ],
            ),
            if (i < 2) const SizedBox(height: SigapSpacing.sm),
          ],
        ],
      ),
    );
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
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard Auditor',
                    style: TextStyle(
                      fontSize: SigapTypography.size16,
                      fontWeight: FontWeight.w700,
                      color: SigapColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Audit & Integrity Monitoring',
                    style: TextStyle(
                      fontSize: SigapTypography.size11,
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
                child: const Text(
                  'Lihat Log Aktivitas →',
                  style: TextStyle(
                    fontSize: SigapTypography.size12,
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
                  child: _KPICard(
                    label: 'Total Antrean',
                    value: total.toString(),
                    color: SigapColors.textPrimary,
                  ),
                ),
                const SizedBox(width: SigapSpacing.sm),
                Expanded(
                  child: _KPICard(
                    label: 'Selesai',
                    value: resolved.toString(),
                    color: SigapColors.selesai,
                  ),
                ),
              ],
            ),
            const SizedBox(height: SigapSpacing.lg),

            // Data quality panel
            _DataQualityPanel(
              qualityPercent: total > 0
                  ? ((total - slaBreached) / total * 100).round()
                  : 0,
              waitingCount: stats.slaAtRisk ?? 0,
            ),
          ],
        );
      },
      loading: () => const DashboardSkeleton(),
      error: (_, __) => const _ErrorCard(message: 'Gagal memuat analitik'),
    );
  }
}

class _KPICard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _KPICard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SigapCard(
      padding: const EdgeInsets.all(SigapSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: SigapTypography.size11,
              color: SigapColors.textMuted,
            ),
          ),
          const SizedBox(height: SigapSpacing.xs),
          Text(
            value,
            style: TextStyle(
              fontSize: SigapTypography.size28,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _DataQualityPanel extends StatelessWidget {
  final int qualityPercent;
  final int waitingCount;

  const _DataQualityPanel({
    required this.qualityPercent,
    required this.waitingCount,
  });

  @override
  Widget build(BuildContext context) {
    return SigapCard(
      padding: const EdgeInsets.all(SigapSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kepatuhan SLA',
            style: TextStyle(
              fontSize: SigapTypography.size13,
              fontWeight: FontWeight.w600,
              color: SigapColors.textPrimary,
            ),
          ),
          const SizedBox(height: SigapSpacing.md),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tepat Waktu',
                          style: TextStyle(
                            fontSize: SigapTypography.size11,
                            color: SigapColors.textMuted,
                          ),
                        ),
                        Text(
                          '$qualityPercent%',
                          style: const TextStyle(
                            fontSize: SigapTypography.size12,
                            fontWeight: FontWeight.w600,
                            color: SigapColors.selesai,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: SigapSpacing.xs),
                    LinearProgressIndicator(
                      value: qualityPercent / 100,
                      backgroundColor: SigapColors.surface,
                      valueColor: const AlwaysStoppedAnimation(
                        SigapColors.selesai,
                      ),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: SigapSpacing.sm),
          Text(
            '$waitingCount kasus berisiko SLA',
            style: const TextStyle(
              fontSize: SigapTypography.size11,
              color: SigapColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Error Card ───────────────────────────────────────────────────────────────

class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return SigapCard(
      padding: const EdgeInsets.all(SigapSpacing.lg),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: SigapColors.danger, size: 24),
          const SizedBox(width: SigapSpacing.sm),
          Text(
            message,
            style: const TextStyle(
              color: SigapColors.textSecondary,
              fontSize: SigapTypography.size13,
            ),
          ),
        ],
      ),
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
    return PhoneFrame(
      child: Column(
        children: [
          const StatusBar(),
          Expanded(
            child: Scaffold(
              backgroundColor: SigapColors.bgSurface,
              appBar: AppBar(
                title: const Text('Dashboard'),
                backgroundColor: SigapColors.surface,
                foregroundColor: SigapColors.textPrimary,
                elevation: 0,
              ),
              body: const _DashboardBody(),
            ),
          ),
        ],
      ),
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
