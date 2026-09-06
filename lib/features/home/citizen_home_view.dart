import 'package:sigap/l10n/category_label.dart';
import 'package:sigap/l10n/generated/app_localizations.dart';
import 'package:sigap/theme/sigap_color_scheme.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:sigap/providers/providers.dart';
import 'package:sigap/api/client.dart';
import 'package:sigap/l10n/status_label.dart';
import 'package:sigap/widgets/design_system/mobile_title_bar.dart';
import 'package:sigap/widgets/design_system/status_grid.dart';

class CitizenHomeView extends ConsumerWidget {
  const CitizenHomeView({super.key, this.position});
  final Position? position;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(authNotifierProvider).userName ?? 'Pengguna';
    final pending = ref.watch(pendingCountProvider);
    final pendingReports =
        ref
            .watch(localReportsProvider)
            .valueOrNull
            ?.where((report) => report.syncStatus == 0)
            .length ??
        0;
    final stats = ref.watch(wargaStatsProvider);
    return Scaffold(
      backgroundColor: SigapColorScheme.of(context).bgSurface,
      appBar: MobileTitleBar(
        title: AppLocalizations.of(context)!.beranda,
        subtitle: AppLocalizations.of(context)!.mobileActiveAreaDeviceLocation,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(wargaStatsProvider);
          ref.invalidate(wargaReportsProvider);
          ref.invalidate(nearbyReportsProvider);
        },
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Text(
              (AppLocalizations.of(context)!.greetingPerson(name)),
              style: TextStyle(
                fontSize: 11,
                color: SigapColorScheme.of(context).textMuted,
              ),
            ),
            SizedBox(height: 6),
            Text(
              (AppLocalizations.of(
                context,
              )!.mobileABetterVillageStartsWithOurCare),
              style: TextStyle(
                fontSize: 23,
                height: 1.35,
                fontWeight: FontWeight.w700,
                letterSpacing: -.5,
              ),
            ),
            SizedBox(height: 18),
            InkWell(
              onTap: () => context.push('/create'),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 17),
                decoration: BoxDecoration(
                  color: SigapColorScheme.of(context).primary,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: SigapColorScheme.of(
                        context,
                      ).primary.withValues(alpha: .12),
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 41,
                      height: 41,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.add, color: Colors.white, size: 24),
                    ),
                    SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.buatLaporan,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            AppLocalizations.of(
                              context,
                            )!.mobilePhotoLocationAndFieldConditions,
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFFD5EEE8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.north_east, color: Colors.white, size: 19),
                  ],
                ),
              ),
            ),
            SizedBox(height: 18),
            pending.when(
              data: (count) => count > 0
                  ? Container(
                      padding: EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: SigapColorScheme.of(context).offlineBg,
                        border: Border.all(
                          color: SigapColorScheme.of(context).offlineBorder,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (AppLocalizations.of(
                              context,
                            )!.pendingSyncCount(count)),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 7),
                          Text(
                            AppLocalizations.of(
                              context,
                            )!.mobileSafeOnThisDeviceSendWhenConnected,
                            style: TextStyle(fontSize: 11),
                          ),
                          TextButton(
                            onPressed: () => context.push('/sync-center'),
                            child: Text(
                              AppLocalizations.of(
                                context,
                              )!.bukaPusatSinkronisasiLink,
                              style: TextStyle(fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Row(
                      children: [
                        Icon(
                          Icons.sync,
                          size: 14,
                          color: SigapColorScheme.of(context).primaryDark,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(
                              context,
                            )!.mobileAllReportsSynced,
                            style: TextStyle(
                              fontSize: 10,
                              color: SigapColorScheme.of(context).primaryDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          ('✓'),
                          style: TextStyle(
                            color: SigapColorScheme.of(context).primaryDark,
                          ),
                        ),
                      ],
                    ),
              loading: () => LinearProgressIndicator(),
              error: (_, __) => Text(
                AppLocalizations.of(context)!.mobileSyncStatusIsUnavailable,
                style: TextStyle(fontSize: 10),
              ),
            ),
            SizedBox(height: 18),
            _section(
              context,
              AppLocalizations.of(context)!.mobileMyReports,
              AppLocalizations.of(context)!.mobileViewAll,
              '/laporan',
            ),
            stats.when(
              data: (value) => InkWell(
                onTap: () => context.push('/laporan'),
                child: StatusGrid(
                  perluTindakan: value.needsCompletion == null
                      ? null
                      : value.needsCompletion! + pendingReports,
                  diproses: value.processing,
                  selesai: value.resolved,
                ),
              ),
              loading: () => LinearProgressIndicator(),
              error: (_, __) => TextButton(
                onPressed: () => ref.invalidate(wargaStatsProvider),
                child: Text(
                  AppLocalizations.of(context)!.mobileReloadReportSummary,
                ),
              ),
            ),
            SizedBox(height: 18),
            _section(
              context,
              AppLocalizations.of(context)!.mobileCasesNearYou,
              AppLocalizations.of(context)!.mobileOpenMap,
              '/map',
            ),
            if (position == null)
              Text(
                AppLocalizations.of(
                  context,
                )!.mobileAllowDeviceLocationToSeeNearbyCases,
                style: TextStyle(
                  fontSize: 12,
                  color: SigapColorScheme.of(context).textMuted,
                ),
              )
            else
              ref
                  .watch(
                    nearbyReportsProvider((
                      lat: position!.latitude,
                      lng: position!.longitude,
                    )),
                  )
                  .when(
                    data: (reports) => reports.isEmpty
                        ? Text(
                            AppLocalizations.of(
                              context,
                            )!.mobileNoNearbyCasesYet,
                            style: TextStyle(fontSize: 12),
                          )
                        : Column(
                            children: reports
                                .take(3)
                                .map((report) => MobileCaseCard(report: report))
                                .toList(),
                          ),
                    loading: () => LinearProgressIndicator(),
                    error: (_, __) => TextButton(
                      onPressed: () => ref.invalidate(nearbyReportsProvider),
                      child: Text(
                        AppLocalizations.of(context)!.mobileReloadNearbyCases,
                      ),
                    ),
                  ),
            SizedBox(height: 18),
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 20,
                  color: SigapColorScheme.of(context).textMuted,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppLocalizations.of(
                      context,
                    )!.mobileYourIdentityIsSafePublicReportsDoNotShow,
                    style: TextStyle(
                      fontSize: 10,
                      height: 1.6,
                      color: SigapColorScheme.of(context).textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(
    BuildContext context,
    String title,
    String action,
    String route,
  ) => Padding(
    padding: EdgeInsets.only(bottom: 11),
    child: Row(
      children: [
        Expanded(
          child: Text(
            (title),
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ),
        InkWell(
          onTap: () => context.push(route),
          child: Text(
            (action),
            style: TextStyle(
              fontSize: 10,
              color: SigapColorScheme.of(context).primary,
            ),
          ),
        ),
      ],
    ),
  );
}

class MobileCaseCard extends ConsumerWidget {
  const MobileCaseCard({super.key, required this.report});
  final NearbyReport report;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photo = report.photoUrl;
    final url = photo == null || photo.isEmpty
        ? null
        : ref.read(apiClientProvider).resolveMediaUrl(photo);
    final village = report.village;
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: SigapColorScheme.of(context).surface,
        border: Border.all(color: SigapColorScheme.of(context).border),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/laporan/${report.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 150,
              child: url == null
                  ? ColoredBox(
                      color: SigapColorScheme.of(context).bgSoft,
                      child: Center(
                        child: Icon(
                          Icons.photo_outlined,
                          color: SigapColorScheme.of(context).textMuted,
                        ),
                      ),
                    )
                  : Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Center(child: Icon(Icons.broken_image_outlined)),
                    ),
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          categoryLabel(
                            context,
                            report.category ?? '',
                          ).toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            letterSpacing: 1,
                            color: SigapColorScheme.of(context).primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (report.reportCount != null)
                        Text(
                          (AppLocalizations.of(
                            context,
                          )!.reportCount(report.reportCount!)),
                          style: TextStyle(
                            fontSize: 9,
                            color: SigapColorScheme.of(context).textMuted,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 7),
                  Text(
                    report.title ??
                        AppLocalizations.of(context)!.mobileFacilityReport,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  if (village != null && village.isNotEmpty)
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 12),
                        SizedBox(width: 3),
                        Text(
                          (AppLocalizations.of(
                            context,
                          )!.villageWithName(village)),
                          style: TextStyle(
                            fontSize: 10,
                            color: SigapColorScheme.of(context).textTertiary,
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 9),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: SigapColorScheme.of(context).primaryLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusLabel(context, report.status),
                      style: TextStyle(
                        fontSize: 10,
                        color: SigapColorScheme.of(context).primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
