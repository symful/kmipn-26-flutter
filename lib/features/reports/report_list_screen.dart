import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sigap/l10n/generated/app_localizations.dart';
import 'package:sigap/l10n/status_label.dart';
import 'package:sigap/providers/providers.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/features/reports/models/report_item.dart';
import 'package:sigap/theme/sigap_color_scheme.dart';
import 'package:sigap/widgets/design_system/mobile_title_bar.dart';

class ReportListScreen extends ConsumerStatefulWidget {
  const ReportListScreen({super.key});

  @override
  ConsumerState<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends ConsumerState<ReportListScreen> {
  String _filter = 'Semua';

  @override
  Widget build(BuildContext context) {
    final localAsync = ref.watch(localReportsProvider);
    final serverAsync = ref.watch(wargaReportsProvider);
    final all = mergeReports(
      localAsync.valueOrNull ?? [],
      serverAsync.valueOrNull ?? [],
    );
    final reports = _filterReports(all);
    return Scaffold(
      backgroundColor: SigapColorScheme.of(context).bgSurface,
      appBar: MobileTitleBar(
        title: AppLocalizations.of(context)!.mobileMyReports,
        subtitle: AppLocalizations.of(
          context,
        )!.protectedReportCount(all.length),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(localReportsProvider);
          ref.invalidate(wargaReportsProvider);
          await ref.read(wargaReportsProvider.future);
        },
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Row(
              children: ['Semua', 'Antrean', 'Selesai']
                  .map(
                    (label) => Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: _FilterPill(
                        label: switch (label) {
                          'Semua' => AppLocalizations.of(context)!.semua,
                          'Antrean' => AppLocalizations.of(
                            context,
                          )!.mobileQueued,
                          'Selesai' => AppLocalizations.of(context)!.selesai,
                          _ => label,
                        },
                        selected: _filter == label,
                        onTap: () => setState(() => _filter = label),
                      ),
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: 18),
            if (localAsync.isLoading || serverAsync.isLoading)
              LinearProgressIndicator()
            else if (localAsync.hasError || serverAsync.hasError)
              _ErrorView(
                message: AppLocalizations.of(context)!.reportsUnavailable,
                onRetry: () {
                  ref.invalidate(localReportsProvider);
                  ref.invalidate(wargaReportsProvider);
                },
              )
            else if (reports.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  AppLocalizations.of(
                    context,
                  )!.mobileNoReportsInThisCategoryYet,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: SigapColorScheme.of(context).textMuted,
                  ),
                ),
              )
            else
              ...reports.map((report) => MobileReportRow(report: report)),
            SizedBox(height: 18),
            FilledButton(
              onPressed: () => context.push('/create'),
              style: FilledButton.styleFrom(
                backgroundColor: SigapColorScheme.of(context).primary,
                padding: EdgeInsets.all(14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.mobileCreateNewReport,
                style: TextStyle(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<ReportItem> _filterReports(List<ReportItem> reports) {
    if (_filter == 'Semua') return reports;
    return reports.where((r) {
      if (_filter == 'Antrean') {
        return r.syncStatus != 1;
      }
      if (_filter == 'Selesai') {
        return r.status == 'resolved';
      }
      return true;
    }).toList();
  }
}

/// Filter pill button (mobile.css .m-pills button).
class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: SigapSpacing.md,
          vertical: SigapSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: selected
              ? Color(0xFF1F2925)
              : SigapColorScheme.of(context).surface,
          borderRadius: BorderRadius.circular(SigapRadius.pill),
          border: Border.all(
            color: selected
                ? Color(0xFF1F2925)
                : SigapColorScheme.of(context).border,
          ),
        ),
        child: Text(
          (label),
          style: TextStyle(
            fontSize: SigapTypography.captionSmall,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected
                ? Colors.white
                : SigapColorScheme.of(context).textSecondary,
          ),
        ),
      ),
    );
  }
}

class MobileReportRow extends StatelessWidget {
  const MobileReportRow({super.key, required this.report});
  final ReportItem report;
  @override
  Widget build(BuildContext context) => Container(
    margin: EdgeInsets.only(bottom: 18),
    decoration: BoxDecoration(
      color: SigapColorScheme.of(context).surface,
      border: Border.all(color: SigapColorScheme.of(context).border),
      borderRadius: BorderRadius.circular(12),
    ),
    child: InkWell(
      onTap: () => context.push('/laporan/${report.navKey}'),
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    (report.serverId ?? report.key),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'monospace',
                      color: SigapColorScheme.of(context).textMuted,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: report.syncStatus == 1
                        ? SigapColorScheme.of(context).primaryLight
                        : SigapColorScheme.of(context).offlineBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    (report.syncStatus == 1
                        ? statusLabel(context, report.status)
                        : AppLocalizations.of(context)!.mobileAwaitingSync),
                    style: TextStyle(
                      fontSize: 10,
                      color: SigapColorScheme.of(context).primaryDark,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              (report.title ?? report.description),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
            SizedBox(height: 6),
            if (report.createdAt != null || report.village != null)
              Text(
                [
                  if (report.createdAt != null)
                    DateFormat.yMMMd(
                      AppLocalizations.of(context)!.localeName,
                    ).format(report.createdAt!.toLocal()),
                  if (report.village != null)
                    AppLocalizations.of(
                      context,
                    )!.villageWithName(report.village!),
                ].join(' · '),
                style: TextStyle(
                  fontSize: 12,
                  color: SigapColorScheme.of(context).textTertiary,
                ),
              ),
            SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.mobileViewProgress,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: SigapColorScheme.of(context).primary,
              ),
            ),
          ],
        ),
      ),
    ),
  );
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
          SizedBox(height: SigapSpacing.md),
          Text(
            (l10n.gagalMemuatLaporan),
            style: TextStyle(
              fontSize: SigapTypography.bodyLarge,
              fontWeight: FontWeight.w600,
              color: SigapColorScheme.of(context).textPrimary,
            ),
          ),
          SizedBox(height: SigapSpacing.xs),
          Text(
            (message),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: SigapTypography.bodySmall,
              color: SigapColorScheme.of(context).textMuted,
            ),
          ),
          SizedBox(height: SigapSpacing.md),
          ElevatedButton(onPressed: onRetry, child: Text((l10n.cobaLagi))),
        ],
      ),
    );
  }
}
