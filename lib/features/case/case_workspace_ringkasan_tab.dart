import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../api/client.dart';
import '../../theme/tokens.dart';
import '../../widgets/design_system/design_system.dart';

/// W-04 Ringkasan Tab Content
///
/// Summary tab for case workspace showing:
/// - Header card (title, status, category, priority)
/// - Photo gallery
/// - Description
/// - Location
/// - AI Assessment
///
/// This content was consolidated from ReportDetailScreen into the
/// case_workspace_screen tab structure.
class CaseWorkspaceRingkasanTab extends StatelessWidget {
  final CaseDetail caseDetail;
  final Map<String, dynamic>? assessmentData;
  final bool assessmentError;

  const CaseWorkspaceRingkasanTab({
    super.key,
    required this.caseDetail,
    this.assessmentData,
    required this.assessmentError,
  });

  @override
  Widget build(BuildContext context) {
    final report = caseDetail.report;
    final status = report?.status?.value ?? '';
    final title = report?.title ?? '';
    final categoryName = report?.category;
    final priority = report?.priority;
    final photoUrls = report?.photos ?? [];
    final description = report?.description ?? '';
    final lat = report?.location?['lat'] as double?;
    final lng = report?.location?['lng'] as double?;
    final createdAtStr = report?.createdAt;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(SigapSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Card
          SigapCard(
            borderTopColor: _statusBorderColor(status),
            padding: const EdgeInsets.all(SigapSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: SigapTypography.size18,
                    fontWeight: FontWeight.bold,
                    color: SigapColors.textPrimary,
                  ),
                ),
                const SizedBox(height: SigapSpacing.sm),
                Wrap(
                  spacing: SigapSpacing.sm,
                  runSpacing: SigapSpacing.sm,
                  children: [
                    StatusPill(
                      label: _statusLabel(status),
                      tone: _statusTone(status),
                    ),
                    if (categoryName != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: SigapSpacing.sm,
                          vertical: SigapSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: SigapColors.primaryLight,
                          borderRadius: BorderRadius.circular(SigapRadius.sm),
                        ),
                        child: Text(
                          categoryName,
                          style: const TextStyle(
                            color: SigapColors.primaryDark,
                            fontSize: SigapTypography.size12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    if (priority != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: SigapSpacing.sm,
                          vertical: SigapSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: SigapColors.warningBg,
                          borderRadius: BorderRadius.circular(SigapRadius.sm),
                        ),
                        child: Text(
                          'Prioritas: ${priority.value}',
                          style: const TextStyle(
                            color: SigapColors.warningText,
                            fontSize: SigapTypography.size12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: SigapSpacing.lg),

          // Photo Gallery
          if (photoUrls.isNotEmpty) ...[
            _SectionLabel(label: 'Foto'),
            const SizedBox(height: SigapSpacing.sm),
            _buildPhotoGallery(context, photoUrls),
            const SizedBox(height: SigapSpacing.lg),
          ],

          // Description
          _SectionLabel(label: 'Deskripsi'),
          const SizedBox(height: SigapSpacing.sm),
          SigapCard(
            padding: const EdgeInsets.all(SigapSpacing.md),
            child: Text(
              description.isNotEmpty ? description : 'Tidak ada deskripsi.',
              style: const TextStyle(
                fontSize: SigapTypography.size14,
                color: SigapColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: SigapSpacing.lg),

          // Location
          _SectionLabel(label: 'Lokasi'),
          const SizedBox(height: SigapSpacing.sm),
          SigapCard(
            padding: const EdgeInsets.all(SigapSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report?.addressArea ??
                      report?.address ??
                      (lat != null && lng != null
                          ? 'Koordinat: ${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}'
                          : 'Lokasi tidak tersedia'),
                  style: const TextStyle(
                    fontSize: SigapTypography.size13,
                    fontFamily: 'monospace',
                    color: SigapColors.textPrimary,
                  ),
                ),
                const SizedBox(height: SigapSpacing.sm),
                OutlinedButton.icon(
                  onPressed: () => context.push('/map'),
                  icon: const Icon(Icons.map, size: 16),
                  label: const Text('Lihat di Peta'),
                ),
              ],
            ),
          ),
          const SizedBox(height: SigapSpacing.lg),

          // Created At
          _SectionLabel(label: 'Dibuat'),
          const SizedBox(height: SigapSpacing.sm),
          SigapCard(
            padding: const EdgeInsets.all(SigapSpacing.md),
            child: Text(
              createdAtStr != null ? _formatApiDate(createdAtStr) : '-',
              style: const TextStyle(
                fontSize: SigapTypography.size14,
                color: SigapColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: SigapSpacing.xl),

          // AI Assessment
          if (assessmentData != null) ...[
            _SectionLabel(label: 'Penilaian AI'),
            const SizedBox(height: SigapSpacing.sm),
            AiAssessmentCard(assessment: assessmentData!),
          ] else if (assessmentError) ...[
            _SectionLabel(label: 'Penilaian AI'),
            const SizedBox(height: SigapSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SigapSpacing.md,
                vertical: SigapSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: SigapColors.dangerBg,
                borderRadius: BorderRadius.circular(SigapRadius.sm),
                border: Border.all(color: SigapColors.dangerBorder),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: SigapColors.danger,
                  ),
                  SizedBox(width: SigapSpacing.sm),
                  Text(
                    'Assessment tidak tersedia',
                    style: TextStyle(
                      color: SigapColors.dangerTextStrong,
                      fontSize: SigapTypography.size13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: SigapSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildPhotoGallery(BuildContext context, List<String> photoUrls) {
    if (photoUrls.length == 1) {
      return GestureDetector(
        onTap: () => _showPhotoFullScreen(context, photoUrls, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(SigapRadius.md),
          child: Image.network(
            photoUrls.first,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 200,
              color: SigapColors.bgSoft,
              child: const Center(child: Icon(Icons.image_not_supported)),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: photoUrls.length,
        separatorBuilder: (_, __) => const SizedBox(width: SigapSpacing.sm),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _showPhotoFullScreen(context, photoUrls, index),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(SigapRadius.md),
              child: Image.network(
                photoUrls[index],
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 120,
                  height: 120,
                  color: SigapColors.bgSoft,
                  child: const Center(
                    child: Icon(Icons.image_not_supported, size: 32),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showPhotoFullScreen(BuildContext ctx, List<String> photos, int index) {
    PhotoFullScreen.show(ctx, photos, index);
  }

  StatusTone _statusTone(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
      case 'rejected':
        return StatusTone.danger;
      case 'under_review':
      case 'in_progress':
        return StatusTone.warning;
      case 'verified':
      case 'resolved':
        return StatusTone.success;
      default:
        return StatusTone.neutral;
    }
  }

  Color _statusBorderColor(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
      case 'rejected':
        return SigapColors.danger;
      case 'under_review':
      case 'in_progress':
        return SigapColors.warning;
      case 'verified':
      case 'resolved':
        return SigapColors.success;
      default:
        return SigapColors.textMuted;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return 'Submitted';
      case 'under_review':
        return 'Under Review';
      case 'in_progress':
        return 'Diproses';
      case 'verified':
        return 'Terverifikasi';
      case 'resolved':
        return 'Selesai';
      case 'rejected':
        return 'Ditolak';
      default:
        return status.isNotEmpty ? status : '-';
    }
  }

  String _formatApiDate(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoString;
    }
  }
}

/// Section label widget for consistent styling across tabs.
class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: SigapTypography.size15,
        fontWeight: FontWeight.bold,
        color: SigapColors.textPrimary,
      ),
    );
  }
}
