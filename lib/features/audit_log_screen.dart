import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sigap/api/client.dart';
import '../../../api/exceptions.dart';
import '../../../l10n/strings.dart';
import '../../../providers/providers.dart';
import '../../../theme/tokens.dart';
import '../../../utils/logger.dart';

final _logger = Logger('AuditLogScreen');

class AuditLogScreen extends ConsumerStatefulWidget {
  const AuditLogScreen({super.key});

  @override
  ConsumerState<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends ConsumerState<AuditLogScreen> {
  static const int _pageSize = 20;

  List<AuditEntry> _logs = [];
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

  bool get _hasActiveFilters =>
      _actorIdFilter != null ||
      _actionFilter != null ||
      _dateRange != null ||
      _objectTypeFilter != null ||
      _objectIdFilter != null;

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
      final data = await client.getAuditSearch(
        actorId: _actorIdFilter,
        action: _actionFilter,
        objectType: _objectTypeFilter,
        objectId: _objectIdFilter,
        from: _dateRange?.start.toIso8601String(),
        to: _dateRange?.end.toIso8601String(),
        page: page,
        limit: _pageSize,
      );
      final entries = data.entries;
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
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _loading) return;
    setState(() => _offset += _pageSize);
    await _load();
  }

  void _clearAllFilters() {
    setState(() {
      _actorIdFilter = null;
      _actionFilter = null;
      _dateRange = null;
      _objectTypeFilter = null;
      _objectIdFilter = null;
      _actorIdController.clear();
      _objectIdController.clear();
      _wilayahController.clear();
    });
    _load(reset: true);
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.only(
            left: SigapSpacing.xl,
            right: SigapSpacing.xl,
            top: SigapSpacing.xl,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + SigapSpacing.xl,
          ),
          decoration: BoxDecoration(
            color: SigapColors.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(SigapRadius.xl),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.filter_alt, color: SigapColors.primary),
                    const SizedBox(width: SigapSpacing.sm),
                    const Text(
                      'Filter Audit Log',
                      style: TextStyle(
                        fontSize: SigapTypography.size16,
                        fontWeight: FontWeight.bold,
                        color: SigapColors.textPrimary,
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
                      child: const Text(
                        Strings.reset,
                        style: TextStyle(color: SigapColors.textSecondary),
                      ),
                    ),
                  ],
                ),
                const Divider(color: SigapColors.border),
                const SizedBox(height: SigapSpacing.sm),
                TextField(
                  controller: _actorIdController,
                  decoration: InputDecoration(
                    labelText: 'ID / Nama Pengguna (Actor)',
                    prefixIcon: const Icon(Icons.person_outline, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(SigapRadius.md),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: SigapSpacing.md,
                      vertical: SigapSpacing.sm,
                    ),
                  ),
                  onChanged: (v) => setSheetState(() => _actorIdFilter = v),
                ),
                const SizedBox(height: SigapSpacing.md),
                TextField(
                  controller: _objectIdController,
                  decoration: InputDecoration(
                    labelText: 'ID Objek (Resource ID)',
                    prefixIcon: const Icon(Icons.tag, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(SigapRadius.md),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: SigapSpacing.md,
                      vertical: SigapSpacing.sm,
                    ),
                  ),
                  onChanged: (v) => setSheetState(() => _objectIdFilter = v),
                ),
                const SizedBox(height: SigapSpacing.md),
                DropdownButtonFormField<String>(
                  initialValue: _actionFilter,
                  decoration: InputDecoration(
                    labelText: 'Aksi (Action)',
                    prefixIcon: const Icon(Icons.bolt, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(SigapRadius.md),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: SigapSpacing.md,
                      vertical: SigapSpacing.sm,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Semua Aksi')),
                    DropdownMenuItem(
                      value: 'CREATE',
                      child: Text('CREATE (Buat)'),
                    ),
                    DropdownMenuItem(
                      value: 'UPDATE',
                      child: Text('UPDATE (Ubah)'),
                    ),
                    DropdownMenuItem(
                      value: 'DELETE',
                      child: Text('DELETE (Hapus)'),
                    ),
                    DropdownMenuItem(
                      value: 'APPROVE',
                      child: Text('APPROVE (Setujui)'),
                    ),
                    DropdownMenuItem(
                      value: 'REJECT',
                      child: Text('REJECT (Tolak)'),
                    ),
                  ],
                  onChanged: (v) => setSheetState(() => _actionFilter = v),
                ),
                const SizedBox(height: SigapSpacing.md),
                DropdownButtonFormField<String>(
                  initialValue: _objectTypeFilter,
                  decoration: InputDecoration(
                    labelText: 'Tipe Objek (Resource Type)',
                    prefixIcon: const Icon(Icons.category_outlined, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(SigapRadius.md),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: SigapSpacing.md,
                      vertical: SigapSpacing.sm,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: null,
                      child: Text('Semua Tipe Objek'),
                    ),
                    DropdownMenuItem(
                      value: 'report',
                      child: Text('Laporan (Report)'),
                    ),
                    DropdownMenuItem(
                      value: 'user',
                      child: Text('Pengguna (User)'),
                    ),
                    DropdownMenuItem(
                      value: 'category',
                      child: Text('Kategori (Category)'),
                    ),
                    DropdownMenuItem(value: 'wilayah', child: Text('Wilayah')),
                    DropdownMenuItem(value: 'unit', child: Text('Unit Kerja')),
                  ],
                  onChanged: (v) => setSheetState(() => _objectTypeFilter = v),
                ),
                const SizedBox(height: SigapSpacing.md),
                Container(
                  decoration: BoxDecoration(
                    color: SigapColors.bgSurface,
                    borderRadius: BorderRadius.circular(SigapRadius.md),
                    border: Border.all(color: SigapColors.border),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.calendar_today,
                      color: SigapColors.primary,
                      size: 20,
                    ),
                    title: Text(
                      _dateRange == null
                          ? 'Rentang Tanggal: (Semua)'
                          : '${_dateRange!.start.day}/${_dateRange!.start.month}/${_dateRange!.start.year} - ${_dateRange!.end.day}/${_dateRange!.end.month}/${_dateRange!.end.year}',
                      style: const TextStyle(
                        fontSize: SigapTypography.size13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: _dateRange != null
                        ? IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () =>
                                setSheetState(() => _dateRange = null),
                          )
                        : const Icon(Icons.chevron_right, size: 20),
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
                ),
                const SizedBox(height: SigapSpacing.lg),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SigapColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: SigapSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(SigapRadius.md),
                    ),
                  ),
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
                  child: const Text(
                    'Terapkan Filter',
                    style: TextStyle(
                      fontSize: SigapTypography.size14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDiffViewer(AuditEntry log) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (ctx, scrollController) => Container(
          decoration: BoxDecoration(
            color: SigapColors.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(SigapRadius.xl),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(SigapSpacing.lg),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: SigapColors.border)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.history_edu, color: SigapColors.primary),
                    const SizedBox(width: SigapSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Detail Perubahan: ${log.action ?? '-'}',
                            style: const TextStyle(
                              fontSize: SigapTypography.size16,
                              fontWeight: FontWeight.bold,
                              color: SigapColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${log.resource ?? '-'} / ${log.resourceId ?? '-'}',
                            style: const TextStyle(
                              fontSize: SigapTypography.size12,
                              color: SigapColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                        title: 'Kondisi Sebelumnya (Before)',
                        data: log.metadata?['before'],
                        isBefore: true,
                      ),
                      const SizedBox(height: SigapSpacing.lg),
                      _DiffSection(
                        title: 'Kondisi Sesudahnya (After)',
                        data: log.metadata?['after'],
                        isBefore: false,
                      ),
                      if (log.metadata != null) ...[
                        const SizedBox(height: SigapSpacing.lg),
                        _DiffSection(
                          title: 'Metadata Tambahan',
                          data: log.metadata,
                          isBefore: false,
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SigapRadius.lg),
        ),
        backgroundColor: SigapColors.surface,
        title: const Row(
          children: [
            Icon(Icons.download, color: SigapColors.primary),
            SizedBox(width: SigapSpacing.sm),
            Text(
              'Export Audit Log',
              style: TextStyle(
                fontSize: SigapTypography.size16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          'Pilih format file export log audit yang diinginkan:',
          style: TextStyle(
            fontSize: SigapTypography.size13,
            color: SigapColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              Strings.batal,
              style: TextStyle(color: SigapColors.textSecondary),
            ),
          ),
          OutlinedButton.icon(
            icon: const Icon(Icons.table_chart, size: 18),
            label: const Text('CSV Format'),
            onPressed: () => Navigator.pop(ctx, 'csv'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: SigapColors.primary,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.code, size: 18),
            label: const Text('JSON Format'),
            onPressed: () => Navigator.pop(ctx, 'json'),
          ),
        ],
      ),
    );

    if (result == null || !mounted) return;

    try {
      final client = ref.read(apiClientProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mengunduh data audit log...'),
          duration: Duration(seconds: 2),
        ),
      );

      final content = await client.getAuditExport(
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
          SnackBar(
            content: Text('Export gagal: ${extractErrorMessage(e)}'),
            backgroundColor: SigapColors.perluTindakan,
          ),
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
      backgroundColor: SigapColors.bgScreen,
      appBar: AppBar(
        title: const Text('Audit Log'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: _hasActiveFilters ? SigapColors.primary : null,
            ),
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
      body: Column(
        children: [
          // Active filters strip
          if (_hasActiveFilters)
            Container(
              color: SigapColors.surface,
              padding: const EdgeInsets.symmetric(
                horizontal: SigapSpacing.lg,
                vertical: SigapSpacing.xs,
              ),
              child: Row(
                children: [
                  const Text(
                    'Filter Aktif: ',
                    style: TextStyle(
                      fontSize: SigapTypography.size11,
                      fontWeight: FontWeight.bold,
                      color: SigapColors.textSecondary,
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          if (_actionFilter != null)
                            _FilterBadge(
                              label: 'Aksi: $_actionFilter',
                              onClear: () {
                                setState(() => _actionFilter = null);
                                _load(reset: true);
                              },
                            ),
                          if (_objectTypeFilter != null)
                            _FilterBadge(
                              label: 'Objek: $_objectTypeFilter',
                              onClear: () {
                                setState(() => _objectTypeFilter = null);
                                _load(reset: true);
                              },
                            ),
                          if (_actorIdFilter != null)
                            _FilterBadge(
                              label: 'Actor: $_actorIdFilter',
                              onClear: () {
                                setState(() => _actorIdFilter = null);
                                _actorIdController.clear();
                                _load(reset: true);
                              },
                            ),
                          if (_dateRange != null)
                            _FilterBadge(
                              label: 'Tanggal: Terpilih',
                              onClear: () {
                                setState(() => _dateRange = null);
                                _load(reset: true);
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _clearAllFilters,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Hapus Semua',
                      style: TextStyle(
                        fontSize: SigapTypography.size11,
                        color: SigapColors.perluTindakan,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (_hasActiveFilters)
            const Divider(height: 1, color: SigapColors.border),

          // Content
          Expanded(
            child: _loading && _logs.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(
                      color: SigapColors.primary,
                    ),
                  )
                : _error != null && _logs.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(SigapSpacing.xl),
                      child: Container(
                        padding: const EdgeInsets.all(SigapSpacing.lg),
                        decoration: BoxDecoration(
                          color: SigapColors.surface,
                          borderRadius: BorderRadius.circular(SigapRadius.md),
                          border: Border.all(color: SigapColors.dangerBorder),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: SigapColors.perluTindakan,
                            ),
                            const SizedBox(height: SigapSpacing.md),
                            const Text(
                              'Gagal Memuat Audit Log',
                              style: TextStyle(
                                fontSize: SigapTypography.size16,
                                fontWeight: FontWeight.bold,
                                color: SigapColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: SigapSpacing.xs),
                            Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: SigapTypography.size12,
                                color: SigapColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: SigapSpacing.lg),
                            ElevatedButton.icon(
                              onPressed: () => _load(reset: true),
                              icon: const Icon(Icons.refresh, size: 18),
                              label: const Text('Coba Lagi'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: SigapColors.primary,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : _logs.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(SigapSpacing.xl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(SigapSpacing.lg),
                            decoration: const BoxDecoration(
                              color: SigapColors.primaryLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.fact_check_outlined,
                              size: 48,
                              color: SigapColors.primary,
                            ),
                          ),
                          const SizedBox(height: SigapSpacing.md),
                          const Text(
                            'Tidak Ada Data Audit Log',
                            style: TextStyle(
                              fontSize: SigapTypography.size16,
                              fontWeight: FontWeight.bold,
                              color: SigapColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: SigapSpacing.xs),
                          Text(
                            _hasActiveFilters
                                ? 'Tidak ditemukan riwayat log dengan kriteria filter saat ini.'
                                : 'Belum ada aktivitas yang tercatat di audit log.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: SigapTypography.size13,
                              color: SigapColors.textSecondary,
                            ),
                          ),
                          if (_hasActiveFilters) ...[
                            const SizedBox(height: SigapSpacing.lg),
                            OutlinedButton.icon(
                              onPressed: _clearAllFilters,
                              icon: const Icon(Icons.filter_alt_off),
                              label: const Text('Hapus Filter'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => _load(reset: true),
                    color: SigapColors.primary,
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (n) {
                        if (n is ScrollEndNotification &&
                            n.metrics.pixels >=
                                n.metrics.maxScrollExtent - 200) {
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
                                child: CircularProgressIndicator(
                                  color: SigapColors.primary,
                                ),
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
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterBadge extends StatelessWidget {
  final String label;
  final VoidCallback onClear;
  const _FilterBadge({required this.label, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: SigapSpacing.xs),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: SigapColors.primaryLight,
        borderRadius: BorderRadius.circular(SigapRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: SigapTypography.size11,
              fontWeight: FontWeight.w600,
              color: SigapColors.primary,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onClear,
            child: const Icon(
              Icons.close,
              size: 14,
              color: SigapColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AuditLogCard extends StatelessWidget {
  final AuditEntry log;
  final VoidCallback onTap;
  const _AuditLogCard({required this.log, required this.onTap});

  Color get _actionColor {
    switch (log.action.toString().toUpperCase()) {
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
    final actorId = log.userId ?? '-';
    final action = log.action ?? '-';
    final objectType = log.resource ?? '-';
    final objectId = log.resourceId ?? '-';
    final wilayah = log.metadata?['wilayah'] as String? ?? '-';
    final timestamp = log.timestamp;

    return Container(
      margin: const EdgeInsets.only(bottom: SigapSpacing.sm),
      decoration: BoxDecoration(
        color: SigapColors.surface,
        borderRadius: BorderRadius.circular(SigapRadius.md),
        border: Border.all(color: SigapColors.border),
      ),
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
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _actionColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(SigapRadius.pill),
                      border: Border.all(
                        color: _actionColor.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      action,
                      style: TextStyle(
                        color: _actionColor,
                        fontSize: SigapTypography.size11,
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
                        fontSize: SigapTypography.size13,
                        color: SigapColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    _formatTimestamp(timestamp),
                    style: const TextStyle(
                      fontSize: SigapTypography.size11,
                      color: SigapColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SigapSpacing.sm),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: SigapColors.bgSurface,
                      borderRadius: BorderRadius.circular(SigapRadius.sm),
                    ),
                    child: Text(
                      '$objectType : $objectId',
                      style: const TextStyle(
                        fontSize: SigapTypography.size11,
                        fontFamily: 'monospace',
                        color: SigapColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (wilayah != '-') ...[
                    const SizedBox(width: SigapSpacing.sm),
                    Expanded(
                      child: Text(
                        'Wilayah: $wilayah',
                        style: const TextStyle(
                          fontSize: SigapTypography.size11,
                          color: SigapColors.textTertiary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
              if (log.metadata?['before'] != null ||
                  log.metadata?['after'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: SigapSpacing.xs),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.visibility_outlined,
                        size: 14,
                        color: SigapColors.primary,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Lihat detail perubahan (diff)',
                        style: TextStyle(
                          fontSize: SigapTypography.size11,
                          color: SigapColors.primary,
                          fontWeight: FontWeight.w500,
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
  final bool isBefore;
  const _DiffSection({required this.title, this.data, required this.isBefore});

  @override
  Widget build(BuildContext context) {
    if (data == null || data!.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: SigapTypography.size13,
              fontWeight: FontWeight.bold,
              color: SigapColors.textPrimary,
            ),
          ),
          const SizedBox(height: SigapSpacing.xs),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(SigapSpacing.md),
            decoration: BoxDecoration(
              color: SigapColors.bgSurface,
              borderRadius: BorderRadius.circular(SigapRadius.sm),
              border: Border.all(color: SigapColors.border),
            ),
            child: const Text(
              '(Kosong / Tidak ada data)',
              style: TextStyle(
                fontSize: SigapTypography.size12,
                color: SigapColors.textMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      );
    }

    final formatted = const JsonEncoder.withIndent('  ').convert(data);
    final borderColor = isBefore
        ? SigapColors.perluTindakan
        : SigapColors.selesai;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: SigapTypography.size13,
            fontWeight: FontWeight.bold,
            color: SigapColors.textPrimary,
          ),
        ),
        const SizedBox(height: SigapSpacing.xs),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(SigapSpacing.md),
          decoration: BoxDecoration(
            color: borderColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(SigapRadius.sm),
            border: Border.all(color: borderColor.withValues(alpha: 0.3)),
          ),
          child: SelectableText(
            formatted,
            style: TextStyle(
              fontSize: SigapTypography.size12,
              fontFamily: 'monospace',
              color: SigapColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
