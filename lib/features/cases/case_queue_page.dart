import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import '../../api/client.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/capability_provider.dart';
import '../../providers/providers.dart';
import '../../theme/tokens.dart';
import '../../widgets/design_system/design_system.dart';

/// Unified Case Queue Page.
///
/// Replaces both [VerifikatorQueueScreen] and [OperatorCaseListScreen].
/// Displays a list of cases with role-based filtering and actions:
/// - VERIFIKATOR: Accept/Reject actions, kategori filter
/// - OPERATOR: PDF export, sort by date/priority
///
/// Route: /cases/queue
class CaseQueuePage extends ConsumerStatefulWidget {
  const CaseQueuePage({super.key});

  @override
  ConsumerState<CaseQueuePage> createState() => _CaseQueuePageState();
}

class _CaseQueuePageState extends ConsumerState<CaseQueuePage> {
  // Filter state
  String? _statusFilter;
  String? _kategoriFilter;
  String _sortBy = 'date';

  // Data state
  List<Report> _entries = [];
  bool _loading = true;
  String? _errorMessage;
  bool _exporting = false;

  bool get _canExportPdf {
    final caps = ref.read(capabilityNotifierProvider).valueOrNull;
    return caps?.can('case.export') ?? false;
  }

  bool get _canVerify {
    final caps = ref.read(capabilityNotifierProvider).valueOrNull;
    return caps?.can('case.verify') ?? false;
  }

  bool get _canReject {
    final caps = ref.read(capabilityNotifierProvider).valueOrNull;
    return caps?.can('case.reject') ?? false;
  }

  String get _detailRoute => '/case-workspace';

  @override
  void initState() {
    super.initState();
    _loadQueue();
  }

  Future<void> _loadQueue() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final client = ref.read(apiClientProvider);
      final result = await client.getReports(
        status: (_statusFilter?.isNotEmpty ?? false) ? _statusFilter : null,
        categoryId: (_kategoriFilter?.isNotEmpty ?? false)
            ? _kategoriFilter
            : null,
        limit: 100,
      );
      var entries = result.data;

      // If server returned empty, merge with local Drift reports so non-warga
      // roles can still see reports that warga submitted offline.
      if (entries.isEmpty) {
        try {
          final localRepo = ref.read(reportRepositoryProvider);
          final localReports = await localRepo.getAllReports();
          if (localReports.isNotEmpty) {
            entries = localReports
                .map(
                  (r) => Report.fromJson({
                    'id': r.serverId ?? r.idempotencyKey,
                    'idempotency_key': r.idempotencyKey,
                    'category_id': r.categoryId,
                    'description': r.description,
                    'lat': r.lat,
                    'lng': r.lng,
                    'status': r.status,
                    'created_at': r.createdAt.toIso8601String(),
                    'updated_at': r.updatedAt.toIso8601String(),
                  }),
                )
                .toList();
          }
        } catch (_) {
          // Local Drift unavailable — proceed with empty server list
        }
      }

      setState(() {
        _entries = entries;
        _loading = false;
      });
    } catch (e) {
      // On network error, try local Drift as fallback
      try {
        final localRepo = ref.read(reportRepositoryProvider);
        final localReports = await localRepo.getAllReports();
        if (localReports.isNotEmpty) {
          setState(() {
            _entries = localReports
                .map(
                  (r) => Report.fromJson({
                    'id': r.serverId ?? r.idempotencyKey,
                    'idempotency_key': r.idempotencyKey,
                    'category_id': r.categoryId,
                    'description': r.description,
                    'lat': r.lat,
                    'lng': r.lng,
                    'status': r.status,
                    'created_at': r.createdAt.toIso8601String(),
                    'updated_at': r.updatedAt.toIso8601String(),
                  }),
                )
                .toList();
            _loading = false;
          });
          return;
        }
      } catch (_) {
        // Local Drift unavailable
      }
      setState(() {
        _loading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _acceptCase(String id) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final client = ref.read(apiClientProvider);
      await client.caseAction(caseId: id, action: 'verify');
      await _loadQueue();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.laporanDiterima)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${l10n.gagal}: $e')));
      }
    }
  }

  Future<void> _rejectCase(String id) async {
    final l10n = AppLocalizations.of(context)!;
    final reason = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l10n.tolakLaporan),
        content: TextField(
          decoration: InputDecoration(labelText: l10n.alasanPenolakan),
          maxLines: 2,
          onChanged: (v) {},
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: Text(l10n.batal),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, l10n.laporanTidakJelas),
            child: Text(l10n.tolak),
          ),
        ],
      ),
    );
    if (reason == null) return;
    try {
      final client = ref.read(apiClientProvider);
      await client.caseAction(caseId: id, action: 'reject', note: reason);
      await _loadQueue();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${l10n.gagal}: $e')));
      }
    }
  }

  Future<void> _exportPdf() async {
    setState(() => _exporting = true);
    try {
      final client = ref.read(apiClientProvider);
      final bytes = await client.exportPdf(
        status: _statusFilter == 'all' ? null : _statusFilter,
      );
      final dir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${dir.path}/sigap-reports-$timestamp.pdf');
      await file.writeAsBytes(bytes);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.pdfSaved}: ${file.path}')),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${l10n.error}: $e')));
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  List<Report> get _filteredAndSorted {
    var result = _entries;
    if (_statusFilter != null && _statusFilter != 'all') {
      result = result
          .where((c) => c.status?.value.toLowerCase() == _statusFilter)
          .toList();
    }
    switch (_sortBy) {
      case 'priority':
        result.sort((a, b) {
          final aPri = a.priority?.value ?? '';
          final bPri = b.priority?.value ?? '';
          return bPri.compareTo(aPri);
        });
        break;
      case 'date':
      default:
        result.sort((a, b) {
          final aDate = a.createdAt ?? '';
          final bDate = b.createdAt ?? '';
          return bDate.compareTo(aDate);
        });
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final activeRole = ref.watch(authNotifierProvider).activeRole ?? '';
    final l10n = AppLocalizations.of(context)!;

    final pageTitle = _canVerify ? l10n.verifikatorAntrian : l10n.daftarKasus;

    return AuthenticatedShell(
      activeRole: activeRole,
      useScaffold: true,
      appBar: AppBar(
        title: Text(pageTitle),
        automaticallyImplyLeading: true,
        actions: [
          // Sort button (available when can export)
          if (_canExportPdf) ...[
            PopupMenuButton<String>(
              icon: const Icon(Icons.sort),
              tooltip: l10n.sortir,
              onSelected: (v) => setState(() => _sortBy = v),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'date',
                  child: Row(
                    children: [
                      if (_sortBy == 'date') const Icon(Icons.check, size: 16),
                      const SizedBox(width: 8),
                      Text(l10n.terbaru),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'priority',
                  child: Row(
                    children: [
                      if (_sortBy == 'priority')
                        const Icon(Icons.check, size: 16),
                      const SizedBox(width: 8),
                      Text(l10n.prioritasTertinggi),
                    ],
                  ),
                ),
              ],
            ),
          ],
          // Filter button
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
            tooltip: l10n.filter,
          ),
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadQueue,
            tooltip: l10n.refresh,
          ),
          // PDF export (available when can export)
          if (_canExportPdf) ...[
            if (_exporting)
              const Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              IconButton(
                icon: const Icon(Icons.picture_as_pdf),
                onPressed: _exportPdf,
                tooltip: l10n.exportPdf,
              ),
          ],
        ],
      ),
      body: _loading
          ? Padding(
              padding: const EdgeInsets.all(SigapSpacing.lg),
              child: SkeletonLoader.list(),
            )
          : _errorMessage != null
          ? Padding(
              padding: const EdgeInsets.all(SigapSpacing.xl),
              child: ErrorRetryView(
                message: l10n.gagalMemuatTugas,
                onRetry: _loadQueue,
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadQueue,
              color: SigapColors.primary,
              child: _filteredAndSorted.isEmpty
                  ? _buildEmptyState(l10n)
                  : ListView.builder(
                      padding: const EdgeInsets.all(SigapSpacing.md),
                      itemCount: _filteredAndSorted.length,
                      itemBuilder: (context, i) {
                        final entry = _filteredAndSorted[i];
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: SigapSpacing.sm,
                          ),
                          child: ReportListItem(
                            report: entry,
                            onTap: () =>
                                context.push('$_detailRoute/${entry.id}'),
                            trailingActions: _buildTrailingActions(entry),
                            showId: true,
                            showSeverity: true,
                            showPriorityScore: true,
                          ),
                        );
                      },
                    ),
            ),
    );
  }

  List<Widget>? _buildTrailingActions(Report entry) {
    final l10n = AppLocalizations.of(context)!;
    final actions = <Widget>[];

    // Accept action (case.verify capability)
    if (_canVerify) {
      actions.add(
        IconButton(
          icon: const Icon(Icons.check_circle_outline),
          color: SigapColors.selesai,
          onPressed: () => _acceptCase(entry.id!),
          tooltip: l10n.terima,
        ),
      );
    }

    // Reject action (case.reject capability)
    if (_canReject) {
      actions.add(
        IconButton(
          icon: const Icon(Icons.highlight_off),
          color: SigapColors.perluTindakan,
          onPressed: () => _rejectCase(entry.id!),
          tooltip: l10n.tolak,
        ),
      );
    }

    // Common action: View detail
    actions.add(
      IconButton(
        icon: const Icon(Icons.chevron_right),
        color: SigapColors.textTertiary,
        onPressed: () => context.push('$_detailRoute/${entry.id}'),
        tooltip: l10n.detail,
      ),
    );

    return actions;
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    final hasActiveFilters =
        _statusFilter != null ||
        _kategoriFilter != null ||
        (_statusFilter != 'all');

    String subtitle;
    if (_canVerify) {
      subtitle = hasActiveFilters
          ? l10n.tidakAdaLaporanSesuaiFilter
          : l10n.semuaLaporanSelesaiDiverifikasi;
    } else {
      subtitle = hasActiveFilters
          ? l10n.tidakAdaKasusDenganFilter
          : l10n.belumAdaKasusMasuk;
    }

    Widget? action;
    if (hasActiveFilters) {
      action = SizedBox(
        height: 48,
        child: OutlinedButton.icon(
          onPressed: () {
            setState(() {
              _statusFilter = null;
              _kategoriFilter = null;
            });
            _loadQueue();
          },
          icon: const Icon(Icons.clear, size: 16),
          label: Text(l10n.hapusFilter),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(SigapSpacing.xl),
      child: EmptyState(
        icon: Icons.inbox_outlined,
        title: _canVerify ? l10n.tidakAdaLaporanDiAntrean : l10n.tidakAdaKasus,
        subtitle: subtitle,
        action: action,
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => _FilterSheet(
        currentStatus: _statusFilter,
        currentKategori: _kategoriFilter,
        isOperator: _canExportPdf,
        onApply: (status, kategori) {
          setState(() {
            _statusFilter = status;
            _kategoriFilter = kategori;
          });
          _loadQueue();
        },
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final String? currentStatus;
  final String? currentKategori;
  final bool isOperator;
  final void Function(String? status, String? kategori) onApply;

  const _FilterSheet({
    this.currentStatus,
    this.currentKategori,
    required this.isOperator,
    required this.onApply,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  String? _selectedStatus;
  String? _selectedKategori;

  // NOTE: Status options are intentionally static (not fetched from API).
  // These values are stable RBAC status values defined in ReportStatus enum.
  // If the backend introduces dynamic status configuration, this should be
  // refactored to fetch from /api/statuses or similar endpoint.
  static const _verifikatorStatusKeys = [
    ('pending', 'menunggu'),
    ('submitted', 'submitted'),
    ('under_review', 'diproses'),
    ('in_progress', 'dalamProses'),
    ('verified', 'diverifikasi'),
    ('rejected', 'ditolak'),
  ];

  // NOTE: Status options are intentionally static (not fetched from API).
  // These values are stable RBAC status values defined in ReportStatus enum.
  static const _operatorStatusKeys = [
    ('all', 'semua'),
    ('submitted', 'submitted'),
    ('under_review', 'diproses'),
    ('in_progress', 'dalamProses'),
    ('resolved', 'diselesaikan'),
    ('rejected', 'ditolak'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.currentStatus;
    _selectedKategori = widget.currentKategori;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final statusKeys = widget.isOperator
        ? _operatorStatusKeys
        : _verifikatorStatusKeys;
    final statusOptions = statusKeys.map((opt) {
      String label;
      switch (opt.$2) {
        case 'menunggu':
          label = l10n.menunggu;
        case 'submitted':
          label = l10n.submitted;
        case 'diproses':
          label = l10n.diproses;
        case 'dalamProses':
          label = l10n.dalamProses;
        case 'diverifikasi':
          label = l10n.diverifikasi;
        case 'ditolak':
          label = l10n.ditolak;
        case 'semua':
          label = l10n.semua;
        case 'diselesaikan':
          label = l10n.diselesaikan;
        default:
          label = opt.$2;
      }
      return (opt.$1, label);
    }).toList();

    return Padding(
      padding: EdgeInsets.only(
        left: SigapSpacing.lg,
        right: SigapSpacing.lg,
        top: SigapSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + SigapSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                l10n.filterAntrean,
                style: const TextStyle(
                  fontSize: SigapTypography.sectionTitle,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: SigapSpacing.lg),
          Text(
            l10n.status,
            style: const TextStyle(
              fontSize: SigapTypography.bodyMedium,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: SigapSpacing.sm),
          Wrap(
            spacing: SigapSpacing.sm,
            children: statusOptions.map((opt) {
              final selected =
                  _selectedStatus == opt.$1 ||
                  (_selectedStatus == null && opt.$1 == 'all') ||
                  (_selectedStatus == null &&
                      widget.isOperator &&
                      opt.$1 == 'all');
              return FilterChip(
                label: Text(opt.$2),
                selected: selected,
                onSelected: (v) {
                  setState(() {
                    _selectedStatus = v ? opt.$1 : null;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: SigapSpacing.lg),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedStatus = widget.isOperator ? 'all' : null;
                    _selectedKategori = null;
                  });
                },
                child: Text(l10n.reset),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () {
                  widget.onApply(_selectedStatus, _selectedKategori);
                  Navigator.pop(context);
                },
                child: Text(l10n.terapkan),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
