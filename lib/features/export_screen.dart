import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sigap/providers/providers.dart';
import 'package:sigap/theme/tokens.dart';

/// Export screen for exporting reports as CSV, GeoJSON, or PDF.
///
/// This screen provides data export functionality for operators and administrators.
/// It wraps the backend /api/export endpoints (CSV, GeoJSON, PDF).
class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  String? _statusFilter;
  String? _categoryFilter;
  bool _loadingCsv = false;
  bool _loadingGeojson = false;
  bool _loadingPdf = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SigapColors.bgScreen,
      appBar: AppBar(
        title: const Text('Export Data'),
        backgroundColor: SigapColors.surface,
        foregroundColor: SigapColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(SigapSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info Card
            Container(
              padding: const EdgeInsets.all(SigapSpacing.md),
              decoration: BoxDecoration(
                color: SigapColors.primaryLight,
                borderRadius: BorderRadius.circular(SigapRadius.md),
                border: Border.all(
                  color: SigapColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: SigapColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: SigapSpacing.sm),
                  Expanded(
                    child: Text(
                      'Export laporan dalam format CSV, GeoJSON, atau PDF. Data akan difilter sesuai opsi yang dipilih.',
                      style: TextStyle(
                        fontSize: SigapTypography.size12,
                        color: SigapColors.primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SigapSpacing.xl),

            // Export Options
            Text(
              'Format Export',
              style: TextStyle(
                fontSize: SigapTypography.size14,
                fontWeight: FontWeight.bold,
                color: SigapColors.textPrimary,
              ),
            ),
            const SizedBox(height: SigapSpacing.md),

            // CSV Export
            _ExportTile(
              icon: Icons.table_chart,
              title: 'CSV (Spreadsheet)',
              description:
                  'Export data laporan dalam format CSV untuk Excel atau Google Sheets.',
              isLoading: _loadingCsv,
              onTap: _exportCsv,
            ),
            const SizedBox(height: SigapSpacing.md),

            // GeoJSON Export
            _ExportTile(
              icon: Icons.map,
              title: 'GeoJSON (Geospatial)',
              description:
                  'Export data laporan dengan koordinat geospasial untuk GIS.',
              isLoading: _loadingGeojson,
              onTap: _exportGeojson,
            ),
            const SizedBox(height: SigapSpacing.md),

            // PDF Export
            _ExportTile(
              icon: Icons.picture_as_pdf,
              title: 'PDF (Laporan)',
              description: 'Export laporan lengkap dalam format PDF.',
              isLoading: _loadingPdf,
              onTap: _exportPdf,
            ),

            if (_error != null) ...[
              const SizedBox(height: SigapSpacing.lg),
              Container(
                padding: const EdgeInsets.all(SigapSpacing.md),
                decoration: BoxDecoration(
                  color: SigapColors.dangerBg,
                  borderRadius: BorderRadius.circular(SigapRadius.md),
                  border: Border.all(color: SigapColors.dangerBorder),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: SigapColors.perluTindakan,
                      size: 20,
                    ),
                    const SizedBox(width: SigapSpacing.sm),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(
                          fontSize: SigapTypography.size12,
                          color: SigapColors.perluTindakan,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _exportCsv() async {
    setState(() {
      _loadingCsv = true;
      _error = null;
    });
    try {
      final client = ref.read(apiClientProvider);
      final csv = await client.exportReportsCsv(
        status: _statusFilter,
        categoryId: _categoryFilter,
      );
      await Share.share(csv, subject: 'SIGAP Reports Export (CSV)');
    } catch (e) {
      setState(() => _error = 'Export CSV gagal: ${e.toString()}');
    } finally {
      setState(() => _loadingCsv = false);
    }
  }

  Future<void> _exportGeojson() async {
    setState(() {
      _loadingGeojson = true;
      _error = null;
    });
    try {
      final client = ref.read(apiClientProvider);
      final geojson = await client.getExportGeojson(
        status: _statusFilter,
        categoryId: _categoryFilter,
      );
      final featureCount = geojson.features?.length ?? 0;
      final jsonStr = featureCount > 0
          ? 'Type: ${geojson.type}, Features: $featureCount'
          : 'Empty GeoJSON';
      await Share.share(jsonStr, subject: 'SIGAP Reports Export (GeoJSON)');
    } catch (e) {
      setState(() => _error = 'Export GeoJSON gagal: ${e.toString()}');
    } finally {
      setState(() => _loadingGeojson = false);
    }
  }

  Future<void> _exportPdf() async {
    setState(() {
      _loadingPdf = true;
      _error = null;
    });
    try {
      final client = ref.read(apiClientProvider);
      final pdfBytes = await client.exportPdf(
        status: _statusFilter,
        categoryId: _categoryFilter,
      );
      await Share.share(
        'PDF Export (${pdfBytes.length} bytes)',
        subject: 'SIGAP Reports Export (PDF)',
      );
    } catch (e) {
      setState(() => _error = 'Export PDF gagal: ${e.toString()}');
    } finally {
      setState(() => _loadingPdf = false);
    }
  }
}

class _ExportTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isLoading;
  final VoidCallback onTap;

  const _ExportTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SigapColors.surface,
        borderRadius: BorderRadius.circular(SigapRadius.md),
        border: Border.all(color: SigapColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: SigapSpacing.md,
          vertical: SigapSpacing.sm,
        ),
        leading: Container(
          padding: const EdgeInsets.all(SigapSpacing.sm),
          decoration: BoxDecoration(
            color: SigapColors.primaryLight,
            borderRadius: BorderRadius.circular(SigapRadius.sm),
          ),
          child: Icon(icon, color: SigapColors.primary, size: 24),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: SigapTypography.size13,
            fontWeight: FontWeight.w600,
            color: SigapColors.textPrimary,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: SigapSpacing.xxs),
          child: Text(
            description,
            style: TextStyle(
              fontSize: SigapTypography.size11,
              color: SigapColors.textSecondary,
            ),
          ),
        ),
        trailing: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(Icons.download, color: SigapColors.primary),
        onTap: isLoading ? null : onTap,
      ),
    );
  }
}
