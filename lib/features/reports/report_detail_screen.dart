import 'package:intl/intl.dart';
import 'package:sigap/utils/server_timestamp.dart';
import 'package:sigap/theme/sigap_color_scheme.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sigap/api/client.dart' as api_client;
import 'package:sigap/providers/providers.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/l10n/generated/app_localizations.dart';
import 'package:sigap/l10n/status_label.dart';
import 'package:sigap/config/api_config.dart';
import 'package:sigap/widgets/design_system/mobile_title_bar.dart';
import 'package:sigap/widgets/design_system/photo_full_screen.dart';
import 'package:sigap/widgets/request_error_details.dart';

import 'package:sigap/widgets/design_system/timeline_event.dart';

/// Provider that fetches a single report from the API by ID.
/// Resolves local idempotency keys to server IDs when possible.
final apiReportProvider = FutureProvider.family<api_client.Report, String>((
  ref,
  id,
) async {
  final apiClient = ref.read(apiClientProvider);

  // First, try to resolve local idempotency key to server ID
  final reportRepo = ref.read(reportRepositoryProvider);
  final localReport = await reportRepo.getByIdempotencyKey(id);
  if (localReport != null) {
    // If it has a server ID, use that for the API call
    if (localReport.serverId != null && localReport.serverId!.isNotEmpty) {
      return apiClient.getReportById(localReport.serverId!);
    }
    // Local-only draft — no server ID yet
    // Throw a specific error so the UI can show local data
    throw LocalDraftException(localReport);
  }

  // Not a local idempotency key — try as server ID
  return apiClient.getReportById(id);
});

/// Exception thrown when a report is a local-only draft (not yet synced).
class LocalDraftException implements Exception {
  final dynamic localReport;
  const LocalDraftException(this.localReport);
  @override
  String toString() => 'LocalDraft: Report not yet synced to server';
}

/// Provider that fetches the timeline for a report.
final reportTimelineProvider =
    FutureProvider.family<api_client.TimelineEnvelope, String>((ref, id) async {
      final apiClient = ref.read(apiClientProvider);
      return apiClient.getReportTimeline(id);
    });

/// Provider that fetches OG meta for share preview.
final shareMetadataProvider =
    FutureProvider.family<api_client.ShareMetadata, String>((ref, id) async {
      final apiClient = ref.read(apiClientProvider);
      return apiClient.getShareMetadata(id);
    });

class ReportDetailScreen extends ConsumerWidget {
  final String id;
  const ReportDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(apiReportProvider(id));
    return Scaffold(
      backgroundColor: SigapColorScheme.of(context).bgSurface,
      appBar: MobileTitleBar(
        title: AppLocalizations.of(context)!.mobileReportDetails,
        subtitle: id,
        onBack: () => context.pop(),
      ),
      body: reportAsync.when(
        data: (report) {
          final title =
              report.title ??
              report.description ??
              AppLocalizations.of(context)!.mobileFacilityReport;
          final photo = report.photos?.firstOrNull;
          final imageUrl = photo == null
              ? null
              : Uri.parse(ApiConfig.baseUrl).resolve(photo).toString();
          return ListView(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Container(
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: SigapColorScheme.of(context).primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (statusLabel(context, report.status?.value)),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      reportStatusExplanation(context, report.status?.value),
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.5,
                        color: SigapColorScheme.of(context).primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 18),
              Text(
                (title),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 18),
              InkWell(
                onTap: imageUrl == null
                    ? null
                    : () => PhotoFullScreen.show(
                        context,
                        report.photos!
                            .map(
                              (url) => Uri.parse(
                                ApiConfig.baseUrl,
                              ).resolve(url).toString(),
                            )
                            .toList(),
                        0,
                      ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AspectRatio(
                    aspectRatio: 1.8,
                    child: imageUrl == null
                        ? ColoredBox(
                            color: SigapColorScheme.of(context).bgSoft,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.reportPhotoMissingExplanation,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          )
                        : Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.reportPhotoLoadExplanation,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              SizedBox(height: 18),
              _referenceCard(
                context,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.reportAddressLabel,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      report.addressArea?.trim().isNotEmpty == true
                          ? report.addressArea!
                          : AppLocalizations.of(
                              context,
                            )!.reportLocationMissingExplanation,
                    ),
                    if (report.lat != null && report.lng != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        '${report.lat!.toStringAsFixed(5)}, ${report.lng!.toStringAsFixed(5)}',
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _referenceCard(
                context,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.mobileRELATEDCASE,
                      style: TextStyle(
                        fontSize: 10,
                        color: SigapColorScheme.of(context).textMuted,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      report.mergedInto != null
                          ? AppLocalizations.of(
                              context,
                            )!.reportRelatedExplanation
                          : AppLocalizations.of(
                              context,
                            )!.reportStandaloneExplanation,
                      style: const TextStyle(fontSize: 12, height: 1.5),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      (title),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 7),
                    Text(
                      [
                        report.mergedInto ?? report.id ?? id,
                        if (report.supportingCount != null)
                          AppLocalizations.of(
                            context,
                          )!.supportingReportCount(report.supportingCount!),
                      ].join(' · '),
                      style: TextStyle(
                        fontSize: 12,
                        color: SigapColorScheme.of(context).textTertiary,
                      ),
                    ),
                    if (report.mergedInto != null)
                      TextButton(
                        onPressed: () =>
                            context.push('/laporan/${report.mergedInto}'),
                        child: Text(
                          AppLocalizations.of(context)!.mobileViewRelatedCase,
                          style: TextStyle(fontSize: 10),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 18),
              _referenceCard(
                context,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.mobileReportProgress,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 14),
                    ref
                        .watch(reportTimelineProvider(report.id ?? id))
                        .when(
                          data: (timeline) => (timeline.events?.isEmpty ?? true)
                              ? Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.mobileNoReportUpdatesYet,
                                  style: TextStyle(fontSize: 12),
                                )
                              : _TimelineWidget(events: timeline.events!),
                          loading: () => LinearProgressIndicator(),
                          error: (_, __) => TextButton(
                            onPressed: () => ref.invalidate(
                              reportTimelineProvider(report.id ?? id),
                            ),
                            child: Text(
                              AppLocalizations.of(
                                context,
                              )!.mobileReloadProgress,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                  ],
                ),
              ),
              if (report.status?.value == 'needs_completion') ...[
                SizedBox(height: 18),
                _referenceCard(
                  context,
                  CitizenEvidenceForm(reportId: report.id ?? id),
                ),
              ],
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
                      )!.mobileOnlyAuthorizedStaffCanAccessReporterDetails,
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
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, _) => error is LocalDraftException
            ? _buildLocalDraftDetail(context, ref, error.localReport)
            : Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RequestErrorDetails(details: error.toString()),
                    TextButton(
                      onPressed: () => ref.invalidate(apiReportProvider(id)),
                      child: Text(
                        AppLocalizations.of(context)!.mobileReloadReport,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _referenceCard(BuildContext context, Widget child) => Container(
    padding: EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: SigapColorScheme.of(context).surface,
      border: Border.all(color: SigapColorScheme.of(context).border),
      borderRadius: BorderRadius.circular(12),
    ),
    child: child,
  );

  Widget _buildLocalDraftDetail(
    BuildContext context,
    WidgetRef ref,
    dynamic report,
  ) => ListView(
    padding: EdgeInsets.fromLTRB(20, 16, 20, 24),
    children: [
      Container(
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: SigapColorScheme.of(context).offlineBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.mobileAwaitingSync,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              AppLocalizations.of(
                context,
              )!.mobileYourReportIsSafeOnThisDeviceOpenSync,
              style: TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
      SizedBox(height: 18),
      Text(
        (report.description as String),
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
      SizedBox(height: 18),
      _referenceCard(
        context,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.mobileRELATEDCASE,
              style: TextStyle(fontSize: 10),
            ),
            SizedBox(height: 10),
            Text(
              AppLocalizations.of(context)!.mobileAwaitingReportSubmission,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 7),
            Text(
              AppLocalizations.of(context)!.mobileNoCaseIDAssignedYet,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      SizedBox(height: 18),
      _referenceCard(
        context,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.mobileReportProgress,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 14),
            Text(
              AppLocalizations.of(context)!.mobileSavedOnDevice,
              style: TextStyle(fontSize: 13),
            ),
            SizedBox(height: 8),
            Text(
              AppLocalizations.of(
                context,
              )!.mobileWaitingForAConnectionToSendTheReport,
              style: TextStyle(fontSize: 10),
            ),
          ],
        ),
      ),
      SizedBox(height: 18),
      TextButton(
        onPressed: () => context.push('/sync-center'),
        child: Text(AppLocalizations.of(context)!.bukaPusatSinkronisasiLink),
      ),
    ],
  );
}

class CitizenEvidenceForm extends ConsumerStatefulWidget {
  const CitizenEvidenceForm({super.key, required this.reportId});
  final String reportId;
  @override
  ConsumerState<CitizenEvidenceForm> createState() =>
      _CitizenEvidenceFormState();
}

class _CitizenEvidenceFormState extends ConsumerState<CitizenEvidenceForm> {
  XFile? _photo;
  bool _sending = false;
  String? _error;
  Future<void> _submit() async {
    if (_photo == null || _sending) return;
    if (ref.read(offlineModeProvider)) {
      setState(
        () => _error = AppLocalizations.of(
          context,
        )!.mobileAnInternetConnectionIsRequiredToSendAdditionalEvidence,
      );
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await ref
          .read(apiClientProvider)
          .addReportEvidence(widget.reportId, _photo!.path);
      ref.invalidate(apiReportProvider(widget.reportId));
      ref.invalidate(reportTimelineProvider(widget.reportId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.mobileAdditionalEvidenceSent,
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        AppLocalizations.of(context)!.mobileStaffRequestedAnotherPhoto,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
      SizedBox(height: 18),
      Text(
        AppLocalizations.of(context)!.mobileNewPhoto,
        style: TextStyle(fontSize: 12),
      ),
      SizedBox(height: 8),
      OutlinedButton.icon(
        onPressed: _sending
            ? null
            : () async {
                final photo = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 85,
                );
                if (mounted && photo != null) setState(() => _photo = photo);
              },
        icon: Icon(Icons.add_photo_alternate_outlined, size: 18),
        label: Text(
          (_photo?.name ??
              AppLocalizations.of(context)!.mobileChoosePhotoFromDevice),
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12),
        ),
      ),
      if (_error != null) RequestErrorDetails(details: _error!),
      SizedBox(height: 18),
      FilledButton(
        onPressed: _photo == null || _sending ? null : _submit,
        child: Text(
          (_sending
              ? AppLocalizations.of(context)!.mobileSending
              : AppLocalizations.of(context)!.mobileSendAdditionalEvidence),
          style: TextStyle(fontSize: 12),
        ),
      ),
    ],
  );
}

class _TimelineWidget extends StatelessWidget {
  final List<api_client.TimelineEvent> events;
  const _TimelineWidget({required this.events});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < events.length; i++)
          _TimelineEventWithPill(
            title: _eventTitle(context, events[i]),
            subtitle: _formatDate(context, events[i].timestamp),
            actor: events[i].userId,
            eventType: events[i].type,
            variant: _getVariant(events[i].type),
            isLast: i == events.length - 1,
          ),
      ],
    );
  }

  String _eventTitle(BuildContext context, api_client.TimelineEvent event) {
    final l10n = AppLocalizations.of(context)!;
    final type = event.type?.trim().toLowerCase();
    final message = event.message;
    final normalized = message?.trim().toLowerCase();
    if (normalized == 'laporan dibuat' && type == 'submitted') {
      return l10n.timelineReportCreated;
    }
    if (normalized == 'laporan anonim dibuat' && type == 'submitted') {
      return l10n.timelineAnonymousReportCreated;
    }
    const systemLabels = {
      'submitted': {'terkirim', 'dikirim', 'laporan dikirim'},
      'needs_completion': {
        'perlu kelengkapan',
        'perlu dilengkapi',
        'laporan perlu dilengkapi',
      },
      'verified': {'diverifikasi', 'terverifikasi', 'laporan diverifikasi'},
      'assigned': {'ditugaskan', 'laporan ditugaskan'},
      'in_progress': {'sedang ditangani', 'dalam pengerjaan'},
      'needs_survey': {'perlu survei', 'laporan memerlukan survei'},
      'resolved': {'selesai', 'laporan selesai'},
      'rejected': {'ditolak', 'laporan ditolak'},
      'closed': {'ditutup', 'laporan ditutup'},
    };
    final generatedStatusMessage =
        normalized == null ||
        normalized.isEmpty ||
        normalized == type ||
        normalized == 'status → $type' ||
        normalized == 'status→$type' ||
        (systemLabels[type]?.contains(normalized) ?? false);
    if (generatedStatusMessage) {
      final label = statusLabel(context, type);
      return label == l10n.unknownLabel
          ? l10n.eventFallback
          : l10n.statusStepRecorded(label);
    }
    // Operator/citizen notes are content, not translation keys.
    return message!;
  }

  TimelineVariant _getVariant(String? eventType) {
    switch (eventType) {
      case 'needs_completion':
        return TimelineVariant.amber;
      default:
        return TimelineVariant.teal;
    }
  }

  String _formatDate(BuildContext context, String? iso) {
    final date = parseServerTimestamp(iso);
    if (date == null) return iso ?? '';
    return DateFormat(
      'd MMM, HH:mm',
      Localizations.localeOf(context).languageCode,
    ).format(date.toLocal());
  }
}

/// Timeline event with a status pill badge (mobile.css timeline pill style).
class _TimelineEventWithPill extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? actor;
  final String? eventType;
  final TimelineVariant variant;
  final bool isLast;

  const _TimelineEventWithPill({
    required this.title,
    required this.subtitle,
    this.actor,
    this.eventType,
    required this.variant,
    this.isLast = false,
  });

  Color _dotColor(BuildContext context) {
    switch (variant) {
      case TimelineVariant.amber:
        return SigapColorScheme.of(context).warning;
      case TimelineVariant.teal:
        return SigapColorScheme.of(context).primary;
      case TimelineVariant.gray:
        return SigapColorScheme.of(context).textDisabled;
    }
  }

  Color _pillColor(BuildContext context) {
    switch (eventType) {
      case 'needs_completion':
        return SigapColorScheme.of(context).warning;
      case 'submitted':
        return SigapColorScheme.of(context).diproses;
      case 'verified':
      case 'resolved':
        return SigapColorScheme.of(context).selesai;
      default:
        return SigapColorScheme.of(context).primary;
    }
  }

  String _pillLabel(BuildContext context) {
    switch (eventType) {
      case 'needs_completion':
      case 'submitted':
      case 'verified':
      case 'resolved':
        return statusLabel(context, eventType);
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final pillLabel = _pillLabel(context);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: _dotColor(context),
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: SigapColorScheme.of(context).borderCard,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        (title),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: SigapColorScheme.of(context).textSecondary,
                        ),
                      ),
                    ),
                    if (pillLabel.isNotEmpty) ...[
                      SizedBox(width: SigapSpacing.xs),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: SigapSpacing.xs,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _pillColor(context).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(SigapRadius.pill),
                        ),
                        child: Text(
                          pillLabel,
                          style: TextStyle(
                            fontSize: SigapTypography.captionMicro,
                            fontWeight: FontWeight.w600,
                            color: _pillColor(context),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 2),
                Text(
                  (subtitle),
                  style: TextStyle(
                    fontSize: 12,
                    color: SigapColorScheme.of(context).textTertiary,
                  ),
                ),
                if (actor != null) ...[
                  SizedBox(height: 2),
                  Text(
                    (actor!),
                    style: TextStyle(
                      fontSize: 11,
                      color: SigapColorScheme.of(context).textDisabled,
                    ),
                  ),
                ],
                SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet for completing a report with additional photos and description.
