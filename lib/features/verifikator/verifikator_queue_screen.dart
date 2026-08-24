import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../api/types.g.dart';
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
  List<Report> _entries = [];
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
        _entries = result.items;
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
      await client.acceptCase(id);
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
      await client.rejectCase(id, reason: reason);
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
      backgroundColor: SigapColors.bgSurface,
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
                      padding: const EdgeInsets.all(SigapSpacing.md),
                      itemCount: _entries.length,
                      itemBuilder: (context, i) {
                        final entry = _entries[i];
                        return _QueueEntryCard(
                          entry: entry,
                          onTap: () =>
                              context.push('/verifikator/cases/${entry.id}'),
                          onAccept: () => _acceptCase(entry.id!),
                          onReject: () => _rejectCase(entry.id!),
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
          Icon(Icons.inbox_outlined, size: 64, color: SigapColors.textTertiary),
          const SizedBox(height: SigapSpacing.md),
          Text(
            'Tidak ada laporan',
            style: TextStyle(
              fontSize: SigapTypography.size16,
              color: SigapColors.textSecondary,
            ),
          ),
          if (_statusFilter != null || _kategoriFilter != null) ...[
            const SizedBox(height: SigapSpacing.sm),
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
  final Report entry;
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
    final categoryName = entry.category ?? '-';
    final description = entry.description ?? '';
    final status = entry.status?.value ?? 'pending';
    final id = entry.id ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: SigapSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SigapRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(SigapSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SigapSpacing.sm,
                      vertical: SigapSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(SigapRadius.sm),
                    ),
                    child: Text(
                      _getStatusLabel(status),
                      style: TextStyle(
                        fontSize: SigapTypography.size11,
                        color: _getStatusColor(status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: SigapSpacing.sm),
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
                      categoryName,
                      style: TextStyle(
                        fontSize: SigapTypography.size11,
                        color: SigapColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '#${id.length > 8 ? id.substring(0, 8) : id}',
                    style: TextStyle(
                      fontSize: SigapTypography.size10,
                      color: SigapColors.textTertiary,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SigapSpacing.sm),
              Text(
                description.isNotEmpty ? description : '-',
                style: TextStyle(
                  fontSize: SigapTypography.size14,
                  color: SigapColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: SigapSpacing.md),
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
        return SigapColors.warning;
      case 'under_review':
        return SigapColors.info;
      case 'in_progress':
        return SigapColors.diproses;
      case 'verified':
      case 'completed':
        return SigapColors.primary;
      case 'rejected':
        return SigapColors.danger;
      default:
        return SigapColors.textTertiary;
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
              const Text(
                'Filter Antrean',
                style: TextStyle(
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
          const Text(
            'Status',
            style: TextStyle(
              fontSize: SigapTypography.size14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: SigapSpacing.sm),
          Wrap(
            spacing: SigapSpacing.sm,
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
          const SizedBox(height: SigapSpacing.lg),
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
