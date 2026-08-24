import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import '../../../api/types.g.dart';
import '../../../providers/providers.dart';
import '../../../theme/tokens.dart';

/// Operator case list screen.
///
/// Uses getVerifikatorQueue (returns Report items) for the case list.
/// Supports sorting by date/priority and filtering by status.
class OperatorCaseListScreen extends ConsumerStatefulWidget {
  const OperatorCaseListScreen({super.key});

  @override
  ConsumerState<OperatorCaseListScreen> createState() =>
      _OperatorCaseListScreenState();
}

class _OperatorCaseListScreenState
    extends ConsumerState<OperatorCaseListScreen> {
  List<Report> _cases = [];
  bool _loading = true;
  bool _exporting = false;
  String? _error;
  String _statusFilter = 'all';
  String _sortBy = 'date';

  @override
  void initState() {
    super.initState();
    _loadCases();
  }

  Future<void> _loadCases() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final client = ref.read(apiClientProvider);
      final page = await client.getVerifikatorQueue();
      setState(() {
        _cases = page.items;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('PDF saved: ${file.path}')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  List<Report> get _filteredAndSorted {
    var result = _cases;
    if (_statusFilter != 'all') {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Kasus'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sortir',
            onSelected: (v) => setState(() => _sortBy = v),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'date',
                child: Row(
                  children: [
                    if (_sortBy == 'date') const Icon(Icons.check, size: 16),
                    const SizedBox(width: 8),
                    const Text('Terbaru'),
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
                    const Text('Prioritas Tertinggi'),
                  ],
                ),
              ),
            ],
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter Status',
            onSelected: (v) => setState(() => _statusFilter = v),
            itemBuilder: (_) => [
              _filterItem('all', 'Semua', _statusFilter),
              _filterItem('submitted', 'Submitted', _statusFilter),
              _filterItem('under_review', 'Under Review', _statusFilter),
              _filterItem('in_progress', 'Diproses', _statusFilter),
              _filterItem('resolved', 'Selesai', _statusFilter),
              _filterItem('rejected', 'Ditolak', _statusFilter),
            ],
          ),
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
              tooltip: 'Ekspor PDF',
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _ErrorRetry(error: _error!, onRetry: _loadCases)
          : _filteredAndSorted.isEmpty
          ? const Center(child: Text('Tidak ada kasus'))
          : RefreshIndicator(
              onRefresh: _loadCases,
              child: ListView.builder(
                padding: const EdgeInsets.all(SigapSpacing.lg),
                itemCount: _filteredAndSorted.length,
                itemBuilder: (context, index) {
                  final c = _filteredAndSorted[index];
                  return _CaseCard(caseData: c);
                },
              ),
            ),
    );
  }

  PopupMenuItem<String> _filterItem(
    String value,
    String label,
    String current,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          if (current == value) const Icon(Icons.check, size: 16),
          if (current != value) const SizedBox(width: 16),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}

class _CaseCard extends StatelessWidget {
  final Report caseData;
  const _CaseCard({required this.caseData});

  Color get _statusColor {
    final status = caseData.status?.value ?? '';
    switch (status.toLowerCase()) {
      case 'submitted':
        return SigapColors.perluTindakan;
      case 'under_review':
        return SigapColors.offlineDot;
      case 'in_progress':
        return SigapColors.diproses;
      case 'resolved':
        return SigapColors.selesai;
      case 'rejected':
        return SigapColors.perluTindakan;
      case 'duplicate_merged':
        return SigapColors.diproses;
      default:
        return SigapColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final id = caseData.id ?? '-';
    final desc = caseData.description ?? '-';
    final truncated = desc.length > 80 ? '${desc.substring(0, 80)}...' : desc;

    return Card(
      margin: const EdgeInsets.only(bottom: SigapSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SigapRadius.md),
        side: const BorderSide(color: SigapColors.border),
      ),
      child: InkWell(
        onTap: () => context.push('/operator/cases/$id'),
        borderRadius: BorderRadius.circular(SigapRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(SigapSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'ID: ${id.toString().length > 8 ? id.toString().substring(0, 8) : id}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SigapSpacing.sm,
                      vertical: SigapSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(SigapRadius.sm),
                    ),
                    child: Text(
                      caseData.status?.value ?? '-',
                      style: TextStyle(
                        color: _statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SigapSpacing.sm),
              Text(
                truncated,
                style: TextStyle(
                  fontSize: 13,
                  color: SigapColors.textSecondary,
                ),
              ),
              const SizedBox(height: SigapSpacing.sm),
              Row(
                children: [
                  if (caseData.priority != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SigapSpacing.sm,
                        vertical: SigapSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: SigapColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(SigapRadius.sm),
                      ),
                      child: Text(
                        'Prioritas: ${caseData.priority?.value}',
                        style: const TextStyle(
                          color: SigapColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  const Spacer(),
                  const Icon(Icons.chevron_right, size: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorRetry({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 64, color: SigapColors.perluTindakan),
          const SizedBox(height: 16),
          Text('Gagal memuat: $error'),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Coba Lagi')),
        ],
      ),
    );
  }
}
