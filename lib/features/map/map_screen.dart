import 'package:sigap/l10n/generated/app_localizations.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sigap/widgets/request_error_details.dart';
import 'package:flutter_map/flutter_map.dart' show TileProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/client.dart';
import '../../config/map_constants.dart';
import '../../db/database.dart' show LocalReport;

import '../../l10n/status_label.dart';
import '../../providers/providers.dart';
import '../../theme/sigap_color_scheme.dart';
import '../../widgets/design_system/mobile_title_bar.dart';
import 'report_map_widget.dart';

final mapTileProviderProvider = Provider<TileProvider?>((ref) => null);

/// Citizens see generalized public cases; field workers see their task locations.
/// Public data is cached separately from account-scoped offline task downloads.
final mapMarkersProvider = FutureProvider.autoDispose<List<ReportMapMarker>>((
  ref,
) async {
  final role = ref.watch(
    authNotifierProvider.select((state) => state.userRole),
  );
  final offline = ref.watch(offlineModeProvider);
  if (role == 'PETUGAS') {
    final cache = ref.watch(taskCacheRepositoryProvider);
    if (!offline) {
      try {
        final page = await ref.watch(apiClientProvider).getTasks();
        return page.tasks
            .where((task) => validMapPoint(task.lat, task.lng))
            .map(ReportMapMarker.fromTask)
            .toList();
      } catch (_) {
        final saved = await cache.readTasks();
        if (saved.isEmpty) rethrow;
      }
    }
    final saved = await cache.readTasks();
    return saved
        .where((task) => validMapPoint(task.lat, task.lng))
        .map(
          (task) => ReportMapMarker.fromTask(
            PetugasTask(
              reportId: task.reportId,
              reportTitle: task.reportTitle,
              reportDescription: task.description,
              status: task.status,
              categoryName: task.categoryName,
              address: task.address,
              lat: task.lat,
              lng: task.lng,
              createdAt: DateTime.tryParse(task.assignedAt ?? ''),
            ),
          ),
        )
        .toList();
  }

  final localFuture = ref.watch(localReportsProvider.future);
  final publicApi = ref.watch(publicApiClientProvider);
  var local = <LocalReport>[];
  try {
    local = await localFuture;
  } catch (_) {
    /* Public map can load without a local database. */
  }
  final drafts = local
      .where(
        (report) =>
            report.syncStatus != 1 && validMapPoint(report.lat, report.lng),
      )
      .map(ReportMapMarker.fromLocalReport)
      .toList();
  SharedPreferences? prefs;
  try {
    prefs = await SharedPreferences.getInstance();
  } catch (_) {
    /* Cache is optional. */
  }
  GeoJSONFeatureCollection? collection;
  if (!offline) {
    try {
      collection = await publicApi.getMapGeoJson();
      try {
        await prefs?.setString(
          'public_map_cache',
          jsonEncode({
            'type': 'FeatureCollection',
            'features':
                collection.features
                    ?.map((feature) => feature.toJson())
                    .toList() ??
                [],
          }),
        );
      } catch (_) {
        /* Cache failure must not hide a successful server response. */
      }
    } catch (_) {
      final cached = prefs?.getString('public_map_cache');
      if (cached == null && drafts.isEmpty) rethrow;
    }
  }
  final cached = prefs?.getString('public_map_cache');
  if (collection == null && cached != null) {
    try {
      collection = GeoJSONFeatureCollection.fromJson(
        (jsonDecode(cached) as Map).cast<String, dynamic>(),
      );
    } catch (_) {
      /* Ignore an incompatible cache and retain local drafts. */
    }
  }
  final markers = <ReportMapMarker>[];
  for (final feature in collection?.features ?? <GeoJSONFeature>[]) {
    try {
      final marker = ReportMapMarker.fromGeoJSONFeature(feature);
      if (validMapPoint(marker.point.latitude, marker.point.longitude)) {
        markers.add(marker);
      }
    } on FormatException {
      /* Malformed geometry is never placed at a fake origin. */
    }
  }
  final serverIds = markers.map((marker) => marker.id).toSet();
  markers.addAll(drafts.where((draft) => !serverIds.contains(draft.id)));
  return markers;
});

bool validMapPoint(double? lat, double? lng) =>
    lat != null &&
    lng != null &&
    lat.isFinite &&
    lng.isFinite &&
    lat >= -90 &&
    lat <= 90 &&
    lng >= -180 &&
    lng <= 180;

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fieldWorker = ref.watch(authNotifierProvider).userRole == 'PETUGAS';
    final markers = ref.watch(mapMarkersProvider);
    return Scaffold(
      backgroundColor: SigapColorScheme.of(context).bgScreen,
      appBar: MobileTitleBar(
        title: AppLocalizations.of(context)!.mobileNearbyMap,
        subtitle: fieldWorker
            ? AppLocalizations.of(context)!.mobileTaskLocations
            : AppLocalizations.of(
                context,
              )!.mobilePublicCasesGeneralizedLocations,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(mapMarkersProvider);
          await ref.read(mapMarkersProvider.future);
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            SizedBox(
              height: 430,
              child: markers.when(
                data: (items) => ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ReportMapWidget(
                    markers: items,
                    generalizedLocations: !fieldWorker,
                    tileProvider: ref.watch(mapTileProviderProvider),
                    onMarkerTap: (marker) => _showDetails(context, marker),
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RequestErrorDetails(details: error.toString()),
                      TextButton(
                        onPressed: () => ref.invalidate(mapMarkersProvider),
                        child: Text(AppLocalizations.of(context)!.mobileRetry),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SigapColorScheme.of(context).bgSoft,
                border: Border.all(color: SigapColorScheme.of(context).border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                (fieldWorker
                    ? AppLocalizations.of(
                        context,
                      )!.mobileTapAMarkerToSeeTheTaskSummary
                    : AppLocalizations.of(
                        context,
                      )!.mobileTapAPinToSeeFacilityDetailsPublicCoordinates),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetails(BuildContext context, ReportMapMarker marker) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                marker.title ?? marker.categoryName ?? marker.description,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              Text(statusLabel(context, marker.status)),
              if (marker.description.isNotEmpty &&
                  marker.description != marker.title) ...[
                const SizedBox(height: 10),
                Text(marker.description),
              ],
              if (marker.addressArea?.isNotEmpty == true) ...[
                const SizedBox(height: 10),
                Text(marker.addressArea!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
