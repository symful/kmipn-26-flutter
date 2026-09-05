import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/client.dart';
import '../../capabilities/can.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/providers.dart';
import '../../theme/tokens.dart';
import '../../widgets/design_system/design_system.dart';

/// W-04 Riwayat Audit Tab Content
///
/// Audit timeline tab for case workspace showing:
/// - Chronological list of all actions on this case
/// - Immutable audit log with actor, action, and timestamp
/// - Each entry shows who did what and when
///
/// Ported from Web SPA's Audit.tsx for case-specific audit trail.
/// API: GET /api/auditor/audit-search?object_id={caseId}&object_type=report
class CaseWorkspaceAuditTab extends ConsumerStatefulWidget {
  final String caseId;

  const CaseWorkspaceAuditTab({super.key, required this.caseId});

  @override
  ConsumerState<CaseWorkspaceAuditTab> createState() =>
      _CaseWorkspaceAuditTabState();
}

class _CaseWorkspaceAuditTabState extends ConsumerState<CaseWorkspaceAuditTab> {
  bool _loading = true;
  String? _error;
  List<AuditEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _loadAuditEntries();
  }

  Future<void> _loadAuditEntries() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final client = ref.read(apiClientProvider);
      final entries = await client.getAudit(reportId: widget.caseId);

      setState(() {
        _entries = entries;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Role-gated: Only users with audit.view capability can see audit trail
    return Can(
      action: 'audit.view',
      resource: Resource(type: 'case', id: widget.caseId),
      fallback: AccessDeniedCard(message: l10n.andaTidakAksesAudit),
      child: _buildAuditContent(),
    );
  }

  Widget _buildAuditContent() {
    final l10n = AppLocalizations.of(context)!;
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: SigapColors.primary),
      );
    }

    if (_error != null && _entries.isEmpty) {
      return Center(
        child: ErrorRetryView(
          message: l10n.gagalMemuatRiwayat,
          onRetry: _loadAuditEntries,
        ),
      );
    }

    if (_entries.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadAuditEntries,
      color: SigapColors.primary,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(SigapSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.history, color: SigapColors.primary, size: 20),
                const SizedBox(width: SigapSpacing.sm),
                Text(
                  l10n.entriAuditCount(_entries.length),
                  style: const TextStyle(
                    fontSize: SigapTypography.subtitle,
                    fontWeight: FontWeight.bold,
                    color: SigapColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: SigapSpacing.md),

            // Audit entries timeline
            SigapCard(
              padding: const EdgeInsets.all(SigapSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < _entries.length; i++) ...[
                    _AuditEntryTile(
                      entry: _entries[i],
                      isLast: i == (_entries.length - 1),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: SigapSpacing.lg),

            // Info note
            Container(
              padding: const EdgeInsets.all(SigapSpacing.md),
              decoration: BoxDecoration(
                color: SigapColors.bgSoft,
                borderRadius: BorderRadius.circular(SigapRadius.md),
                border: Border.all(color: SigapColors.borderCard),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: SigapColors.textTertiary,
                  ),
                  const SizedBox(width: SigapSpacing.sm),
                  Expanded(
                    child: Text(
                      l10n.riwayatAuditInfo,
                      style: TextStyle(
                        fontSize: SigapTypography.bodySmall,
                        color: SigapColors.textTertiary,
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

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SigapSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: SigapColors.bgSurface,
                shape: BoxShape.circle,
                border: Border.all(color: SigapColors.borderCard, width: 2),
              ),
              child: const Icon(
                Icons.history,
                size: 36,
                color: SigapColors.textTertiary,
              ),
            ),
            const SizedBox(height: SigapSpacing.md),
            Text(
              l10n.belumAdaRiwayatAudit,
              style: TextStyle(
                fontSize: SigapTypography.bodyLarge,
                fontWeight: FontWeight.w700,
                color: SigapColors.textPrimary,
              ),
            ),
            const SizedBox(height: SigapSpacing.xs),
            Text(
              l10n.semuaTindakanTercatatDiSini,
              style: TextStyle(
                fontSize: SigapTypography.bodyText,
                color: SigapColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SigapSpacing.lg),
            OutlinedButton.icon(
              onPressed: _loadAuditEntries,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(l10n.segarkanData),
            ),
          ],
        ),
      ),
    );
  }
}

/// Audit entry tile widget displaying a single audit log entry.
class _AuditEntryTile extends StatelessWidget {
  final AuditEntry entry;
  final bool isLast;

  const _AuditEntryTile({required this.entry, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 11,
                  height: 11,
                  decoration: const BoxDecoration(
                    color: SigapColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 2, color: SigapColors.borderCard),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatAction(entry.action ?? '-'),
                  style: const TextStyle(
                    fontSize: SigapTypography.bodyText,
                    fontWeight: FontWeight.w600,
                    color: SigapColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatTimestamp(entry.timestamp ?? '-'),
                  style: const TextStyle(
                    fontSize: SigapTypography.bodySmall,
                    color: SigapColors.textTertiary,
                  ),
                ),
                if (entry.userId != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    l10n.olehLabel(entry.userId!),
                    style: const TextStyle(
                      fontSize: SigapTypography.captionMedium,
                      color: SigapColors.textDisabled,
                    ),
                  ),
                ],
                if (entry.resource != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    l10n.resourceLabel(entry.resource ?? '-'),
                    style: const TextStyle(
                      fontSize: SigapTypography.captionMedium,
                      fontFamily: SigapTypography.fontFamilyMono,
                      color: SigapColors.textDisabled,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatAction(String action) {
    // Convert snake_case to Title Case for display
    return action
        .split('_')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
              : word,
        )
        .join(' ');
  }

  String _formatTimestamp(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoString;
    }
  }
}
