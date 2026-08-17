import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/providers.dart';
import '../../../theme/tokens.dart';

class OperatorCaseListScreen extends ConsumerStatefulWidget {
  const OperatorCaseListScreen({super.key});

  @override
  ConsumerState<OperatorCaseListScreen> createState() =>
      _OperatorCaseListScreenState();
}

class _OperatorCaseListScreenState
    extends ConsumerState<OperatorCaseListScreen> {
  List<Map<String, dynamic>> _cases = [];
  bool _loading = true;
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
      final data = await client.getOperatorCases();
      final items = data['items'] as List? ?? [];
      setState(() {
        _cases = items.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredAndSorted {
    var result = _cases;
    if (_statusFilter != 'all') {
      result = result
          .where((c) => c['status']?.toString().toLowerCase() == _statusFilter)
          .toList();
    }
    switch (_sortBy) {
      case 'priority':
        result.sort(
          (a, b) => (b['severity'] ?? 0).compareTo(a['severity'] ?? 0),
        );
        break;
      case 'date':
      default:
        result.sort((a, b) {
          final aDate =
              DateTime.tryParse(a['created_at'] ?? '') ?? DateTime.now();
          final bDate =
              DateTime.tryParse(b['created_at'] ?? '') ?? DateTime.now();
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
  final Map<String, dynamic> caseData;
  const _CaseCard({required this.caseData});

  Color get _statusColor {
    switch ((caseData['status'] ?? '').toString().toLowerCase()) {
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
    final id = caseData['id'] ?? '-';
    final desc = caseData['description'] ?? '-';
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
                      caseData['status'] ?? '-',
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
                  if (caseData['severity'] != null)
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
                        'Prioritas: ${caseData['severity']}',
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
