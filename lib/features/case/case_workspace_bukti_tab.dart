import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../api/client.dart';
import '../../theme/tokens.dart';
import '../../widgets/design_system/design_system.dart';

/// W-04 Bukti & Laporan Tab Content
///
/// Evidence tab for case workspace showing:
/// - Photo gallery (extracted from ReportDetailScreen)
/// - Description
/// - Location
///
/// This content was consolidated from ReportDetailScreen into the
/// case_workspace_screen tab structure.
class CaseWorkspaceBuktiTab extends StatelessWidget {
  final CaseDetail caseDetail;

  const CaseWorkspaceBuktiTab({super.key, required this.caseDetail});

  @override
  Widget build(BuildContext context) {
    final report = caseDetail.report;
    final photoUrls = report?.photos ?? [];
    final description = report?.description ?? '';
    final lat = report?.location?['lat'] as double?;
    final lng = report?.location?['lng'] as double?;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(SigapSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Photo Gallery
          if (photoUrls.isNotEmpty) ...[
            _SectionLabel(label: 'Foto Bukti'),
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

          // Documents placeholder (if report has documents)
          if (report != null) ...[
            _SectionLabel(label: 'Dokumen'),
            const SizedBox(height: SigapSpacing.sm),
            SigapCard(
              padding: const EdgeInsets.all(SigapSpacing.lg),
              child: Column(
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 48,
                    color: SigapColors.textMuted,
                  ),
                  const SizedBox(height: SigapSpacing.md),
                  Text(
                    'Tidak ada dokumen',
                    style: TextStyle(
                      fontSize: SigapTypography.size14,
                      color: SigapColors.textSecondary,
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
