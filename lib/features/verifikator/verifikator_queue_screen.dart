import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../theme/tokens.dart';

/// Verifikator Queue Screen - displays queue with status/kategori filters.
///
/// Route: /verifikator/queue
class VerifikatorQueueScreen extends ConsumerStatefulWidget {
  const VerifikatorQueueScreen({super.key});

  @override
  ConsumerState<VerifikatorQueueScreen> createState() =>
      _VerifikatorQueueScreenState();
}

class _VerifikatorQueueScreenState
    extends ConsumerState<VerifikatorQueueScreen> {
  // Filter state
  String? _statusFilter;
  String? _kategoriFilter;
  List<Map<String, dynamic>> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadQueue();
  }

  Future<void> _loadQueue() async {
    setState(() {
      _loading = true;
    });
    try {
      final client = ref.read(apiClientProvider);
      final result = await client.getVerifikatorQueue(
        status: _statusFilter,
        kategori: _kategoriFilter,
        limit: 100,
      );
      setState(() {
        _entries =
            (result['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _acceptCase(String id) async {
    try {
      final client = ref.read(apiClientProvider);
      await client.acceptVerifikatorCase(id);
      await _loadQueue();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Laporan diterima')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal: $e')));
      }
    }
  }

  Future<void> _rejectCase(String id) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Tolak Laporan'),
        content: TextField(
          decoration: const InputDecoration(labelText: 'Alasan penolakan'),
          maxLines: 2,
          onChanged: (v) {},
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, 'Laporan tidak jelas'),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
    if (reason == null) return;
    try {
      final client = ref.read(apiClientProvider);
      await client.rejectVerifikatorCase(id, reason: reason);
      await _loadQueue();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      appBar: AppBar(
        title: const Text('Verifikator - Antrian'),
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadQueue,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadQueue,
              child: _entries.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: _entries.length,
                      itemBuilder: (context, i) {
                        final entry = _entries[i];
                        return _QueueEntryCard(
                          entry: entry,
                          onTap: () =>
                              context.push('/verifikator/cases/${entry['id']}'),
                          onAccept: () => _acceptCase(entry['id'] as String),
                          onReject: () => _rejectCase(entry['id'] as String),
                        );
                      },
                    ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: AppColors.textTertiary),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Tidak ada laporan',
            style: TextStyle(
              fontSize: AppTypography.size16,
              color: AppColors.textSecondary,
            ),
          ),
          if (_statusFilter != null || _kategoriFilter != null) ...[
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () {
                setState(() {
                  _statusFilter = null;
                  _kategoriFilter = null;
                });
                _loadQueue();
              },
              child: const Text('Hapus filter'),
            ),
          ],
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => _FilterSheet(
        currentStatus: _statusFilter,
        currentKategori: _kategoriFilter,
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

class _QueueEntryCard extends StatelessWidget {
  final Map<String, dynamic> entry;
  final VoidCallback onTap;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _QueueEntryCard({
    required this.entry,
    required this.onTap,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final categoryName =
        (entry['category'] is Map
                ? (entry['category'] as Map)['name']
                : entry['category'])
            as String? ??
        '-';
    final description = entry['description'] as String? ?? '';
    final status = entry['status'] as String? ?? 'pending';
    final id = entry['id'] as String? ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      _getStatusLabel(status),
                      style: TextStyle(
                        fontSize: AppTypography.size11,
                        color: _getStatusColor(status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      categoryName,
                      style: TextStyle(
                        fontSize: AppTypography.size11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '#${id.length > 8 ? id.substring(0, 8) : id}',
                    style: TextStyle(
                      fontSize: AppTypography.size10,
                      color: AppColors.textTertiary,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                description.isNotEmpty ? description : '-',
                style: TextStyle(
                  fontSize: AppTypography.size14,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check_circle),
                    color: Colors.green,
                    onPressed: onAccept,
                    tooltip: 'Terima',
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel),
                    color: Colors.red,
                    onPressed: onReject,
                    tooltip: 'Tolak',
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: onTap,
                    tooltip: 'Detail',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'submitted':
        return AppColors.warning;
      case 'under_review':
        return AppColors.info;
      case 'in_progress':
        return AppColors.diproses;
      case 'verified':
      case 'completed':
        return AppColors.primary;
      case 'rejected':
        return AppColors.danger;
      default:
        return AppColors.textTertiary;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'submitted':
        return 'Menunggu';
      case 'under_review':
        return 'Diproses';
      case 'in_progress':
        return 'Dalam Proses';
      case 'verified':
      case 'completed':
        return 'Diverifikasi';
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }
}

class _FilterSheet extends StatefulWidget {
  final String? currentStatus;
  final String? currentKategori;
  final void Function(String? status, String? kategori) onApply;

  const _FilterSheet({
    this.currentStatus,
    this.currentKategori,
    required this.onApply,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  String? _selectedStatus;
  String? _selectedKategori;

  final _statusOptions = [
    ('pending', 'Menunggu'),
    ('submitted', 'Submitted'),
    ('under_review', 'Diproses'),
    ('in_progress', 'Dalam Proses'),
    ('verified', 'Diverifikasi'),
    ('rejected', 'Ditolak'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.currentStatus;
    _selectedKategori = widget.currentKategori;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text(
                'Filter Antrean',
                style: TextStyle(
                  fontSize: AppTypography.size19,
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
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'Status',
            style: TextStyle(
              fontSize: AppTypography.size14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: _statusOptions.map((opt) {
              final selected = _selectedStatus == opt.$1;
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
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedStatus = null;
                    _selectedKategori = null;
                  });
                },
                child: const Text('Reset'),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () {
                  widget.onApply(_selectedStatus, _selectedKategori);
                  Navigator.pop(context);
                },
                child: const Text('Terapkan'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
