import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import '../../api/types.g.dart';
import '../../l10n/strings.dart';
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

  bool get _isVerifikator {
    final role = ref.read(authNotifierProvider).activeRole;
    return role?.toUpperCase() == 'VERIFIKATOR';
  }

  bool get _isOperator {
    final role = ref.read(authNotifierProvider).activeRole;
    return role?.toUpperCase() == 'OPERATOR';
  }

  String get _pageTitle {
    if (_isVerifikator) return Strings.verifikatorAntrian;
    if (_isOperator) return Strings.daftarKasus;
    return Strings.daftarKasus;
  }

  String get _detailRoute {
    if (_isVerifikator) return '/case-review';
    if (_isOperator) return '/case-action';
    return '/cases';
  }

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
      final activeRole = ref.read(authNotifierProvider).activeRole ?? '';
      final result = await client.getVerifikatorQueue(
        activeRole: activeRole,
        status: _statusFilter,
        kategori: _kategoriFilter,
        limit: 100,
      );
      setState(() {
        _entries = result.items;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _acceptCase(String id) async {
    try {
      final client = ref.read(apiClientProvider);
      await client.acceptCase(id);
      await _loadQueue();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(Strings.laporanDiterima)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${Strings.gagal}: $e')));
      }
    }
  }

  Future<void> _rejectCase(String id) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(Strings.tolakLaporan),
        content: TextField(
          decoration: InputDecoration(labelText: Strings.alasanPenolakan),
          maxLines: 2,
          onChanged: (v) {},
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: Text(Strings.batal),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, Strings.laporanTidakJelas),
            child: Text(Strings.tolak),
          ),
        ],
      ),
    );
    if (reason == null) return;
    try {
      final client = ref.read(apiClientProvider);
      await client.rejectCase(id, reason: reason);
      await _loadQueue();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${Strings.gagal}: $e')));
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${Strings.pdfSaved}: ${file.path}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${Strings.error}: $e')));
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

    return AuthenticatedShell(
      activeRole: activeRole,
      useScaffold: true,
      appBar: AppBar(
        title: Text(_pageTitle),
        automaticallyImplyLeading: true,
        actions: [
          // Sort button (operator only)
          if (_isOperator) ...[
            PopupMenuButton<String>(
              icon: const Icon(Icons.sort),
              tooltip: Strings.sortir,
              onSelected: (v) => setState(() => _sortBy = v),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'date',
                  child: Row(
                    children: [
                      if (_sortBy == 'date') const Icon(Icons.check, size: 16),
                      const SizedBox(width: 8),
                      const Text(Strings.terbaru),
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
                      const Text(Strings.prioritasTertinggi),
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
            tooltip: Strings.filter,
          ),
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadQueue,
            tooltip: Strings.refresh,
          ),
          // PDF export (operator only)
          if (_isOperator) ...[
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
                tooltip: Strings.exportPdf,
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
                message: Strings.gagalMemuatTugas,
                onRetry: _loadQueue,
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadQueue,
              color: SigapColors.primary,
              child: _filteredAndSorted.isEmpty
                  ? _buildEmptyState()
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
    final actions = <Widget>[];

    // Verifikator actions: Accept / Reject
    if (_isVerifikator) {
      actions.addAll([
        IconButton(
          icon: const Icon(Icons.check_circle_outline),
          color: SigapColors.selesai,
          onPressed: () => _acceptCase(entry.id!),
          tooltip: Strings.terima,
        ),
        IconButton(
          icon: const Icon(Icons.highlight_off),
          color: SigapColors.perluTindakan,
          onPressed: () => _rejectCase(entry.id!),
          tooltip: Strings.tolak,
        ),
      ]);
    }

    // Common action: View detail
    actions.add(
      IconButton(
        icon: const Icon(Icons.chevron_right),
        color: SigapColors.textTertiary,
        onPressed: () => context.push('$_detailRoute/${entry.id}'),
        tooltip: Strings.detail,
      ),
    );

    return actions;
  }

  Widget _buildEmptyState() {
    final hasActiveFilters =
        _statusFilter != null ||
        _kategoriFilter != null ||
        (_statusFilter != 'all');

    String subtitle;
    if (_isVerifikator) {
      subtitle = hasActiveFilters
          ? Strings.tidakAdaLaporanSesuaiFilter
          : Strings.semuaLaporanSelesaiDiverifikasi;
    } else {
      subtitle = hasActiveFilters
          ? Strings.tidakAdaKasusDenganFilter
          : Strings.belumAdaKasusMasuk;
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
          label: Text(Strings.hapusFilter),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(SigapSpacing.xl),
      child: EmptyState(
        icon: Icons.inbox_outlined,
        title: _isVerifikator
            ? Strings.tidakAdaLaporanDiAntrean
            : Strings.tidakAdaKasus,
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
        isOperator: _isOperator,
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
  final _verifikatorStatusOptions = [
    ('pending', Strings.menunggu),
    ('submitted', Strings.submitted),
    ('under_review', Strings.diproses),
    ('in_progress', Strings.dalamProses),
    ('verified', Strings.diverifikasi),
    ('rejected', Strings.ditolak),
  ];

  // NOTE: Status options are intentionally static (not fetched from API).
  // These values are stable RBAC status values defined in ReportStatus enum.
  final _operatorStatusOptions = [
    ('all', Strings.semua),
    ('submitted', Strings.submitted),
    ('under_review', Strings.diproses),
    ('in_progress', Strings.dalamProses),
    ('resolved', Strings.diselesaikan),
    ('rejected', Strings.ditolak),
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.currentStatus;
    _selectedKategori = widget.currentKategori;
  }

  @override
  Widget build(BuildContext context) {
    final statusOptions = widget.isOperator
        ? _operatorStatusOptions
        : _verifikatorStatusOptions;

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
                Strings.filterAntrean,
                style: const TextStyle(
                  fontSize: SigapTypography.size19,
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
            Strings.status,
            style: const TextStyle(
              fontSize: SigapTypography.size14,
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
                child: Text(Strings.reset),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () {
                  widget.onApply(_selectedStatus, _selectedKategori);
                  Navigator.pop(context);
                },
                child: Text(Strings.terapkan),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
