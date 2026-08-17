import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../api/exceptions.dart';
import '../../../l10n/strings.dart';
import '../../../providers/providers.dart';
import '../../../theme/tokens.dart';
import '../../../utils/logger.dart';

final _logger = Logger('AuditorAuditLogScreen');

class AuditorAuditLogScreen extends ConsumerStatefulWidget {
  const AuditorAuditLogScreen({super.key});

  @override
  ConsumerState<AuditorAuditLogScreen> createState() =>
      _AuditorAuditLogScreenState();
}

class _AuditorAuditLogScreenState extends ConsumerState<AuditorAuditLogScreen> {
  static const int _pageSize = 20;

  List<Map<String, dynamic>> _logs = [];
  bool _loading = true;
  String? _error;
  int _offset = 0;
  bool _hasMore = true;

  // Filters
  String? _actorIdFilter;
  String? _actionFilter;
  DateTimeRange? _dateRange;
  String? _objectTypeFilter;
  String? _objectIdFilter;

  final _actorIdController = TextEditingController();
  final _objectIdController = TextEditingController();
  final _wilayahController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool reset = false}) async {
    if (reset) {
      setState(() {
        _offset = 0;
        _hasMore = true;
        _logs = [];
      });
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final client = ref.read(apiClientProvider);
      final page = (_offset ~/ _pageSize) + 1;
      final data = await client.getAuditorAuditSearch(
        actorId: _actorIdFilter,
        action: _actionFilter,
        objectType: _objectTypeFilter,
        objectId: _objectIdFilter,
        from: _dateRange?.start.toIso8601String(),
        to: _dateRange?.end.toIso8601String(),
        page: page,
        limit: _pageSize,
      );
      final entries = (data['entries'] as List? ?? [])
          .cast<Map<String, dynamic>>();
      setState(() {
        if (reset) {
          _logs = entries;
        } else {
          _logs.addAll(entries);
        }
        _hasMore = entries.length >= _pageSize;
        _loading = false;
      });
    } catch (e, _) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
      rethrow;
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _loading) return;
    setState(() => _offset += _pageSize);
    await _load();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          decoration: BoxDecoration(
            color: SigapColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Text(
                      Strings.filter,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setSheetState(() {
                          _actorIdFilter = null;
                          _actionFilter = null;
                          _dateRange = null;
                          _objectTypeFilter = null;
                          _objectIdFilter = null;
                          _actorIdController.clear();
                          _objectIdController.clear();
                          _wilayahController.clear();
                        });
                      },
                      child: const Text(Strings.reset),
                    ),
                  ],
                ),
                const SizedBox(height: SigapSpacing.md),
                TextField(
                  controller: _actorIdController,
                  decoration: const InputDecoration(
                    labelText: 'Actor ID / Nama',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => setSheetState(() => _actorIdFilter = v),
                ),
                const SizedBox(height: SigapSpacing.sm),
                TextField(
                  controller: _objectIdController,
                  decoration: const InputDecoration(
                    labelText: 'Object ID',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => setSheetState(() => _objectIdFilter = v),
                ),
                const SizedBox(height: SigapSpacing.sm),
                TextField(
                  controller: _wilayahController,
                  decoration: const InputDecoration(
                    labelText: 'Wilayah',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: SigapSpacing.sm),
                DropdownButtonFormField<String>(
                  initialValue: _actionFilter,
                  decoration: const InputDecoration(
                    labelText: 'Action',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Semua')),
                    DropdownMenuItem(value: 'CREATE', child: Text('CREATE')),
                    DropdownMenuItem(value: 'UPDATE', child: Text('UPDATE')),
                    DropdownMenuItem(value: 'DELETE', child: Text('DELETE')),
                    DropdownMenuItem(value: 'APPROVE', child: Text('APPROVE')),
                    DropdownMenuItem(value: 'REJECT', child: Text('REJECT')),
                  ],
                  onChanged: (v) => setSheetState(() => _actionFilter = v),
                ),
                const SizedBox(height: SigapSpacing.sm),
                DropdownButtonFormField<String>(
                  initialValue: _objectTypeFilter,
                  decoration: const InputDecoration(
                    labelText: 'Object Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Semua')),
                    DropdownMenuItem(value: 'report', child: Text('Report')),
                    DropdownMenuItem(value: 'user', child: Text('User')),
                    DropdownMenuItem(
                      value: 'category',
                      child: Text('Category'),
                    ),
                    DropdownMenuItem(value: 'wilayah', child: Text('Wilayah')),
                    DropdownMenuItem(value: 'unit', child: Text('Unit')),
                  ],
                  onChanged: (v) => setSheetState(() => _objectTypeFilter = v),
                ),
                const SizedBox(height: SigapSpacing.sm),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    _dateRange == null
                        ? 'Date Range: (belum dipilih)'
                        : 'Date Range: ${_dateRange!.start.toLocal().toString().split(' ')[0]} - ${_dateRange!.end.toLocal().toString().split(' ')[0]}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDateRangePicker(
                      context: ctx,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      initialDateRange: _dateRange,
                    );
                    if (picked != null) {
                      setSheetState(() => _dateRange = picked);
                    }
                  },
                ),
                const SizedBox(height: SigapSpacing.lg),
                ElevatedButton(
                  onPressed: () {
                    _actorIdFilter = _actorIdController.text.trim().isNotEmpty
                        ? _actorIdController.text.trim()
                        : null;
                    _objectIdFilter = _objectIdController.text.trim().isNotEmpty
                        ? _objectIdController.text.trim()
                        : null;
                    Navigator.pop(ctx);
                    _load(reset: true);
                  },
                  child: const Text('Terapkan Filter'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDiffViewer(Map<String, dynamic> log) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (ctx, scrollController) => Container(
          decoration: BoxDecoration(
            color: SigapColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(SigapSpacing.lg),
                child: Row(
                  children: [
                    Text(
                      'Detail: ${log['action'] ?? '-'}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(SigapSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _DiffSection(
                        title: 'Before',
                        data: log['before'] as Map<String, dynamic>?,
                      ),
                      const SizedBox(height: SigapSpacing.lg),
                      _DiffSection(
                        title: 'After',
                        data: log['after'] as Map<String, dynamic>?,
                      ),
                      if (log['metadata'] != null || log['extra'] != null) ...[
                        const SizedBox(height: SigapSpacing.lg),
                        _DiffSection(
                          title: 'Metadata',
                          data:
                              (log['metadata'] ?? log['extra'])
                                  as Map<String, dynamic>?,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showExportDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Export Audit Log'),
        content: const Text('Pilih format export:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'csv'),
            child: const Text('CSV'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'json'),
            child: const Text('JSON'),
          ),
        ],
      ),
    );

    if (result == null || !mounted) return;

    try {
      final client = ref.read(apiClientProvider);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Mengunduh data...')));

      final content = await client.getAuditorAuditExport(
        actorId: _actorIdFilter,
        action: _actionFilter,
        objectType: _objectTypeFilter,
        objectId: _objectIdFilter,
        from: _dateRange?.start.toIso8601String(),
        to: _dateRange?.end.toIso8601String(),
        format: result,
      );

      await Share.share(
        content,
        subject: 'Audit Log Export (${result.toUpperCase()})',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export gagal: ${extractErrorMessage(e)}')),
        );
      }
    }
  }

  @override
  void dispose() {
    _actorIdController.dispose();
    _objectIdController.dispose();
    _wilayahController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
            tooltip: Strings.filter,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _showExportDialog,
            tooltip: 'Export',
          ),
        ],
      ),
      body: _loading && _logs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _error != null && _logs.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: SigapColors.perluTindakan,
                  ),
                  Text('Gagal: $_error'),
                  ElevatedButton(
                    onPressed: () => _load(reset: true),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            )
          : _logs.isEmpty
          ? const Center(child: Text('Tidak ada data audit log'))
          : NotificationListener<ScrollNotification>(
              onNotification: (n) {
                if (n is ScrollEndNotification &&
                    n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
                  _loadMore();
                }
                return false;
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(SigapSpacing.lg),
                itemCount: _logs.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= _logs.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(SigapSpacing.md),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  final log = _logs[index];
                  return _AuditLogCard(
                    log: log,
                    onTap: () => _showDiffViewer(log),
                  );
                },
              ),
            ),
    );
  }
}

class _AuditLogCard extends StatelessWidget {
  final Map<String, dynamic> log;
  final VoidCallback onTap;
  const _AuditLogCard({required this.log, required this.onTap});

  Color get _actionColor {
    switch ((log['action'] ?? '').toString().toUpperCase()) {
      case 'CREATE':
        return SigapColors.selesai;
      case 'UPDATE':
        return SigapColors.diproses;
      case 'DELETE':
        return SigapColors.perluTindakan;
      case 'APPROVE':
        return SigapColors.primary;
      case 'REJECT':
        return SigapColors.offlineDot;
      default:
        return SigapColors.textMuted;
    }
  }

  String _formatTimestamp(String? ts) {
    if (ts == null) return '-';
    try {
      final dt = DateTime.parse(ts);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e, s) {
      _logger.warning('Error parsing timestamp "$ts"', e, s);
      return ts;
    }
  }

  @override
  Widget build(BuildContext context) {
    final actorId =
        log['actor_id'] as String? ??
        log['actor_name'] as String? ??
        log['actor'] as String? ??
        '-';
    final action = log['action'] as String? ?? '-';
    final objectType =
        log['object_type'] as String? ?? log['resource'] as String? ?? '-';
    final objectId =
        log['object_id'] as String? ?? log['resource_id'] as String? ?? '-';
    final wilayah = log['wilayah'] as String? ?? '-';
    final timestamp =
        log['timestamp'] as String? ?? log['created_at'] as String?;

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
                      color: _actionColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(SigapRadius.sm),
                    ),
                    child: Text(
                      action,
                      style: TextStyle(
                        color: _actionColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: SigapSpacing.sm),
                  Expanded(
                    child: Text(
                      actorId,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SigapSpacing.xs),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '$objectType / $objectId',
                      style: TextStyle(
                        fontSize: 12,
                        color: SigapColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    _formatTimestamp(timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: SigapColors.textMuted,
                    ),
                  ),
                ],
              ),
              if (wilayah != '-')
                Padding(
                  padding: const EdgeInsets.only(top: SigapSpacing.xs),
                  child: Text(
                    'Wilayah: $wilayah',
                    style: TextStyle(
                      fontSize: 11,
                      color: SigapColors.textMuted,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              if (log['before'] != null || log['after'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: SigapSpacing.xs),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.expand_more,
                        size: 16,
                        color: SigapColors.primary,
                      ),
                      Text(
                        'Lihat detail perubahan',
                        style: TextStyle(
                          fontSize: 11,
                          color: SigapColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DiffSection extends StatelessWidget {
  final String title;
  final Map<String, dynamic>? data;
  const _DiffSection({required this.title, this.data});

  @override
  Widget build(BuildContext context) {
    if (data == null || data!.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: SigapSpacing.xs),
          Container(
            padding: const EdgeInsets.all(SigapSpacing.md),
            decoration: BoxDecoration(
              color: SigapColors.textMuted.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(SigapRadius.sm),
            ),
            child: Text(
              '(kosong)',
              style: TextStyle(fontSize: 12, color: SigapColors.textMuted),
            ),
          ),
        ],
      );
    }

    final formatted = const JsonEncoder.withIndent('  ').convert(data);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: SigapSpacing.xs),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(SigapSpacing.md),
          decoration: BoxDecoration(
            color: title == 'Before'
                ? SigapColors.perluTindakan.withValues(alpha: 0.05)
                : SigapColors.selesai.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(SigapRadius.sm),
            border: Border.all(
              color: title == 'Before'
                  ? SigapColors.perluTindakan.withValues(alpha: 0.1)
                  : SigapColors.selesai.withValues(alpha: 0.1),
            ),
          ),
          child: SelectableText(
            formatted,
            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
          ),
        ),
      ],
    );
  }
}
