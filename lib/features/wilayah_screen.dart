import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/exceptions.dart';
import '../../../api/client.dart';
import '../../../l10n/strings.dart';
import '../../../providers/providers.dart';
import '../../../theme/tokens.dart';

class WilayahScreen extends ConsumerStatefulWidget {
  const WilayahScreen({super.key});

  @override
  ConsumerState<WilayahScreen> createState() => _WilayahScreenState();
}

class _WilayahScreenState extends ConsumerState<WilayahScreen> {
  List<Wilayah> _items = [];
  bool _loading = true;
  String? _error;
  String _searchQuery = '';

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
      final data = await client.getWilayahList();
      setState(() {
        _items = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = extractErrorMessage(e);
        _loading = false;
      });
    }
  }

  List<Wilayah> get _filtered {
    if (_searchQuery.trim().isEmpty) return _items;
    final q = _searchQuery.toLowerCase();
    return _items.where((item) {
      final name = (item.name ?? '').toLowerCase();
      final level = (item.level?.toString() ?? '').toLowerCase();
      return name.contains(q) || level.contains(q);
    }).toList();
  }

  Future<void> _createItem() async {
    final nameController = TextEditingController();
    final parentController = TextEditingController();
    String selectedLevel = 'kelurahan';

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SigapRadius.lg),
          ),
          backgroundColor: SigapColors.surface,
          title: const Row(
            children: [
              Icon(Icons.location_city, color: SigapColors.primary),
              SizedBox(width: SigapSpacing.sm),
              Text(
                'Tambah Wilayah',
                style: TextStyle(
                  fontSize: SigapTypography.size16,
                  fontWeight: FontWeight.bold,
                  color: SigapColors.textPrimary,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Daftarkan wilayah administratif (Kelurahan / Kecamatan / Kota) untuk penugasan dan filter laporan.',
                  style: TextStyle(
                    fontSize: SigapTypography.size12,
                    color: SigapColors.textSecondary,
                  ),
                ),
                const SizedBox(height: SigapSpacing.md),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: Strings.namaWilayahWAJIB,
                    hintText: 'Misal: Kelurahan Cibadak',
                    prefixIcon: const Icon(Icons.pin_drop_outlined, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(SigapRadius.md),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: SigapSpacing.md,
                      vertical: SigapSpacing.sm,
                    ),
                  ),
                ),
                const SizedBox(height: SigapSpacing.md),
                DropdownButtonFormField<String>(
                  initialValue: selectedLevel,
                  decoration: InputDecoration(
                    labelText: 'Tingkat / Level Administratif',
                    prefixIcon: const Icon(Icons.layers_outlined, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(SigapRadius.md),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: SigapSpacing.md,
                      vertical: SigapSpacing.sm,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'rt_rw', child: Text('RT / RW')),
                    DropdownMenuItem(
                      value: 'kelurahan',
                      child: Text('Kelurahan / Desa'),
                    ),
                    DropdownMenuItem(
                      value: 'kecamatan',
                      child: Text('Kecamatan'),
                    ),
                    DropdownMenuItem(
                      value: 'kota',
                      child: Text('Kota / Kabupaten'),
                    ),
                    DropdownMenuItem(
                      value: 'provinsi',
                      child: Text('Provinsi'),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) setDialogState(() => selectedLevel = v);
                  },
                ),
                const SizedBox(height: SigapSpacing.md),
                TextField(
                  controller: parentController,
                  decoration: InputDecoration(
                    labelText: 'Parent ID Wilayah (opsional)',
                    hintText: 'ID Wilayah Induk',
                    prefixIcon: const Icon(
                      Icons.account_tree_outlined,
                      size: 20,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(SigapRadius.md),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: SigapSpacing.md,
                      vertical: SigapSpacing.sm,
                    ),
                  ),
                ),
              ],
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: SigapColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SigapRadius.sm),
                ),
              ),
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                      content: Text('Nama wilayah wajib diisi'),
                      backgroundColor: SigapColors.warning,
                    ),
                  );
                  return;
                }
                try {
                  final client = ref.read(apiClientProvider);
                  await client.dio.post(
                    '/api/admin/wilayah',
                    data: {
                      'name': nameController.text.trim(),
                      if (parentController.text.trim().isNotEmpty)
                        'parent_id': parentController.text.trim(),
                      'level': selectedLevel.trim(),
                    },
                  );
                  if (ctx.mounted) Navigator.pop(ctx, true);
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${extractErrorMessage(e)}'),
                        backgroundColor: SigapColors.perluTindakan,
                      ),
                    );
                  }
                }
              },
              child: const Text(Strings.simpan),
            ),
          ],
        ),
      ),
    );
    if (result == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SigapColors.bgScreen,
      appBar: AppBar(
        title: const Text('Kelola Wilayah'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Segarkan',
            onPressed: _load,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createItem,
        backgroundColor: SigapColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Wilayah'),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: SigapColors.surface,
            padding: const EdgeInsets.symmetric(
              horizontal: SigapSpacing.lg,
              vertical: SigapSpacing.sm,
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari wilayah atau tingkat administratif...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                filled: true,
                fillColor: SigapColors.bgSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SigapRadius.md),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: SigapSpacing.md,
                  vertical: SigapSpacing.xs,
                ),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          const Divider(height: 1, color: SigapColors.border),
          // Content
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: SigapColors.primary,
                    ),
                  )
                : _error != null
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
                              'Gagal Memuat Wilayah',
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
                              onPressed: _load,
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
                : _filtered.isEmpty
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
                              Icons.map_outlined,
                              size: 48,
                              color: SigapColors.primary,
                            ),
                          ),
                          const SizedBox(height: SigapSpacing.md),
                          const Text(
                            'Tidak Ada Wilayah',
                            style: TextStyle(
                              fontSize: SigapTypography.size16,
                              fontWeight: FontWeight.bold,
                              color: SigapColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: SigapSpacing.xs),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'Tidak ada wilayah yang cocok dengan pencarian "$_searchQuery".'
                                : 'Belum ada wilayah administratif yang terdaftar.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: SigapTypography.size13,
                              color: SigapColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: SigapSpacing.lg),
                          OutlinedButton.icon(
                            onPressed: _createItem,
                            icon: const Icon(Icons.add),
                            label: const Text('Tambah Wilayah Baru'),
                          ),
                        ],
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _load,
                    color: SigapColors.primary,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(SigapSpacing.lg),
                      itemCount: _filtered.length,
                      itemBuilder: (context, index) {
                        final item = _filtered[index];
                        final id = item.id?.toString() ?? '';
                        final name = item.name ?? '-';
                        final levelStr = item.level?.toString() ?? '-';
                        final levelCol = _levelColor(levelStr);

                        return Container(
                          margin: const EdgeInsets.only(
                            bottom: SigapSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: SigapColors.surface,
                            borderRadius: BorderRadius.circular(SigapRadius.md),
                            border: Border.all(color: SigapColors.border),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: SigapSpacing.md,
                              vertical: SigapSpacing.xs,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: levelCol.withValues(alpha: 0.12),
                              foregroundColor: levelCol,
                              child: Icon(
                                Icons.location_on,
                                size: 20,
                                color: levelCol,
                              ),
                            ),
                            title: Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: SigapTypography.size14,
                                color: SigapColors.textPrimary,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                'ID: ${id.length > 8 ? id.substring(0, 8) : id}',
                                style: const TextStyle(
                                  fontSize: SigapTypography.size11,
                                  fontFamily: 'monospace',
                                  color: SigapColors.textTertiary,
                                ),
                              ),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: SigapSpacing.sm,
                                vertical: SigapSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: levelCol.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                  SigapRadius.pill,
                                ),
                                border: Border.all(
                                  color: levelCol.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Text(
                                levelStr.toUpperCase(),
                                style: TextStyle(
                                  fontSize: SigapTypography.size10,
                                  color: levelCol,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing:
                                      SigapTypography.letterSpacingLabel,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Color _levelColor(String level) {
    switch (level.toLowerCase()) {
      case 'provinsi':
        return SigapColors.perluTindakan;
      case 'kota':
      case 'kabupaten':
        return SigapColors.diproses;
      case 'kecamatan':
        return SigapColors.primary;
      case 'kelurahan':
      case 'desa':
        return SigapColors.selesai;
      case 'rt_rw':
        return SigapColors.offlineDot;
      default:
        return SigapColors.textMuted;
    }
  }
}
