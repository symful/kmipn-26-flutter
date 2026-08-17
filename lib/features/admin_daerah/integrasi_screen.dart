import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/exceptions.dart';
import '../../../l10n/strings.dart';
import '../../../providers/providers.dart';
import '../../../theme/tokens.dart';
import '../../utils/logger.dart';

final _logger = Logger('AdminDaerahIntegrasiScreen');

class AdminDaerahIntegrasiScreen extends ConsumerStatefulWidget {
  const AdminDaerahIntegrasiScreen({super.key});

  @override
  ConsumerState<AdminDaerahIntegrasiScreen> createState() =>
      _AdminDaerahIntegrasiScreenState();
}

class _AdminDaerahIntegrasiScreenState
    extends ConsumerState<AdminDaerahIntegrasiScreen> {
  Map<String, dynamic>? _outbox;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final client = ref.read(apiClientProvider);
      final data = await client.getAdminOutbox();
      setState(() {
        _outbox = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = extractErrorMessage(e);
        _loading = false;
      });
    }
  }

  Future<void> _retryItem(String id) async {
    try {
      final client = ref.read(apiClientProvider);
      await client.retryAdminDaerahIntegration(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Retry berhasil dijadwalkan')),
        );
      }
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${extractErrorMessage(e)}')),
        );
      }
    }
  }

  Future<void> _reconcile() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rekonsiliasi'),
        content: const Text(
          'Rekonsiliasi akan mencocokkan data outbox dengan sistem tujuan. Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(Strings.batal),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Rekonsiliasi'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final client = ref.read(apiClientProvider);
      await client.reconcileAdminDaerahIntegration();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Rekonsiliasi dimulai')));
      }
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${extractErrorMessage(e)}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final items =
        (_outbox?['items'] as List? ??
        _outbox?['data'] as List? ??
        <Map<String, dynamic>>[]);
    final failedCount = items
        .where((i) => i['status'] == 'failed' || i['status'] == 'error')
        .length;
    final pendingCount = items
        .where((i) => i['status'] == 'pending' || i['status'] == 'queued')
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Integrasi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reconcile,
            tooltip: 'Rekonsiliasi',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: SigapColors.perluTindakan,
                  ),
                  Text('Gagal: $_error'),
                  ElevatedButton(
                    onPressed: _load,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(SigapSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Summary row
                    Row(
                      children: [
                        Expanded(
                          child: _OutboxStatCard(
                            label: 'Pending',
                            count: pendingCount,
                            color: SigapColors.offlineDot,
                          ),
                        ),
                        const SizedBox(width: SigapSpacing.md),
                        Expanded(
                          child: _OutboxStatCard(
                            label: 'Failed',
                            count: failedCount,
                            color: SigapColors.perluTindakan,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: SigapSpacing.lg),

                    // Reconcile button
                    OutlinedButton.icon(
                      onPressed: _reconcile,
                      icon: const Icon(Icons.sync),
                      label: const Text('Jalankan Rekonsiliasi'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                    const SizedBox(height: SigapSpacing.lg),

                    // Outbox items
                    const Text(
                      'Outbox',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: SigapSpacing.md),
                    if (items.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(SigapSpacing.xl),
                          child: Text('Tidak ada item outbox'),
                        ),
                      )
                    else
                      ...items.map(
                        (item) => _OutboxItemCard(
                          item: item,
                          onRetry: () => _retryItem(item['id'].toString()),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _OutboxStatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _OutboxStatCard({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SigapSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(SigapRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }
}

class _OutboxItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onRetry;
  const _OutboxItemCard({required this.item, required this.onRetry});

  Color get _statusColor {
    switch ((item['status'] ?? '').toString().toLowerCase()) {
      case 'failed':
      case 'error':
        return Colors.red;
      case 'pending':
      case 'queued':
        return Colors.orange;
      case 'sent':
      case 'success':
        return SigapColors.selesai;
      default:
        return SigapColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final destination =
        item['destination'] as String? ?? item['target'] as String? ?? '-';
    final status = item['status'] as String? ?? '-';
    final lastAttempt =
        item['last_attempt'] as String? ?? item['updated_at'] as String?;
    final retryCount = item['retry_count'] as int? ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: SigapSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(SigapSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    destination,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
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
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      color: _statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: SigapSpacing.xs),
            Text(
              'Attempt: $retryCount â€” ${lastAttempt != null ? _formatDate(lastAttempt) : "-"}',
              style: TextStyle(fontSize: 11, color: SigapColors.textMuted),
            ),
            if (status == 'failed' || status == 'error')
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Retry'),
                  onPressed: onRetry,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e, s) {
      _logger.warning('Error parsing date', e, s);
      return iso;
    }
  }
}
