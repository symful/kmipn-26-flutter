import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sigap/l10n/generated/app_localizations.dart';
import 'package:sigap/providers/providers.dart';
import 'package:sigap/theme/tokens.dart';

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

/// Fetches queue counts for operator dashboard from Stats API.
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

/// W-02 QueueCardsRow widget displaying 5 queue status cards.
///
/// Uses Stats from API - no hardcoded values.
/// Cards: Kasus baru, Perlu verifikasi, SLA terlewat, Prioritas tinggi, Pendah
class QueueCardsRow extends ConsumerWidget {
  const QueueCardsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final queueAsync = ref.watch(queueCountsProvider);

    return queueAsync.when(
      data: (queue) => _QueueCardsRowContent(queue: queue, l10n: l10n),
      loading: () => const _QueueCardsLoading(),
      error: (_, __) => const _QueueCardsError(),
    );
  }
}

class _QueueCardsRowContent extends StatelessWidget {
  final QueueCounts queue;
  final AppLocalizations l10n;

  const _QueueCardsRowContent({required this.queue, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QueueCard(
            value: queue.newReports.toString(),
            label: l10n.labelKasusBaru,
            color: SigapColors.info,
          ),
        ),
        const SizedBox(width: SigapSpacing.sm),
        Expanded(
          child: _QueueCard(
            value: queue.needsVerification.toString(),
            label: l10n.labelPerluVerifikasi,
            color: SigapColors.warning,
          ),
        ),
        const SizedBox(width: SigapSpacing.sm),
        Expanded(
          child: _QueueCard(
            value: queue.slaBreached.toString(),
            label: l10n.labelSlaTerlewat,
            color: SigapColors.danger,
          ),
        ),
        const SizedBox(width: SigapSpacing.sm),
        Expanded(
          child: _QueueCard(
            value: queue.highPriority.toString(),
            label: l10n.labelPrioritasTinggi,
            color: SigapColors.primary,
          ),
        ),
        const SizedBox(width: SigapSpacing.sm),
        Expanded(
          child: _QueueCard(
            value: queue.needsCompletion.toString(),
            label: 'Pendah',
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
              fontSize: SigapTypography.headlineMedium,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          SizedBox(height: SigapSpacing.xxs),
          Text(
            label,
            style: const TextStyle(
              fontSize: SigapTypography.captionSmall,
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
                  Container(
                    width: 40,
                    height: 22,
                    decoration: BoxDecoration(
                      color: SigapColors.bgSurface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: SigapSpacing.xs),
                  Container(
                    width: 60,
                    height: 12,
                    decoration: BoxDecoration(
                      color: SigapColors.bgSurface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _QueueCardsError extends StatelessWidget {
  const _QueueCardsError();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SigapSpacing.md),
      decoration: BoxDecoration(
        color: SigapColors.surface,
        borderRadius: BorderRadius.circular(SigapRadius.md),
        border: Border.all(color: SigapColors.danger.withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.error_outline, color: SigapColors.danger, size: 20),
          SizedBox(width: SigapSpacing.sm),
          Text(
            'Gagal memuat antrean',
            style: TextStyle(
              color: SigapColors.textSecondary,
              fontSize: SigapTypography.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
