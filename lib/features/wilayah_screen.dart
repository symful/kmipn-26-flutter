import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/exceptions.dart';
import '../../../api/client.dart';
import '../../../l10n/generated/app_localizations.dart';
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
        builder: (ctx, setDialogState) {
          final dl10n = AppLocalizations.of(ctx)!;
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SigapRadius.lg),
            ),
            backgroundColor: SigapColors.surface,
            title: Row(
              children: [
                const Icon(Icons.location_city, color: SigapColors.primary),
                const SizedBox(width: SigapSpacing.sm),
                Text(
                  dl10n.tambahWilayah,
                  style: const TextStyle(
                    fontSize: SigapTypography.bodyLarge,
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
                  Text(
                    dl10n.daftarkanWilayah,
                    style: const TextStyle(
                      fontSize: SigapTypography.bodySmall,
                      color: SigapColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: SigapSpacing.md),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: dl10n.namaWilayahWAJIB,
                      hintText: dl10n.hintWilayahName,
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
                      labelText: dl10n.labelTingkatAdministratif,
                      prefixIcon: const Icon(Icons.layers_outlined, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(SigapRadius.md),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: SigapSpacing.md,
                        vertical: SigapSpacing.sm,
                      ),
                    ),
                    items: [
                      DropdownMenuItem(value: 'rt_rw', child: Text(dl10n.rtRw)),
                      DropdownMenuItem(
                        value: 'kelurahan',
                        child: Text(dl10n.kelurahanDesa),
                      ),
                      DropdownMenuItem(
                        value: 'kecamatan',
                        child: Text(dl10n.kecamatan),
                      ),
                      DropdownMenuItem(
                        value: 'kota',
                        child: Text(dl10n.kotaKabupaten),
                      ),
                      DropdownMenuItem(
                        value: 'provinsi',
                        child: Text(dl10n.provinsi),
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
                      labelText: dl10n.labelParentIdWilayah,
                      hintText: dl10n.hintParentWilayahId,
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
                child: Text(
                  dl10n.batal,
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
                      SnackBar(
                        content: Text(dl10n.namaWilayahWajibDiisi),
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
                          content: Text(
                            dl10n.errorDenganPesan(extractErrorMessage(e)),
                          ),
                          backgroundColor: SigapColors.perluTindakan,
                        ),
                      );
                    }
                  }
                },
                child: Text(dl10n.simpan),
              ),
            ],
          );
        },
      ),
    );
    if (result == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: SigapColors.bgScreen,
      appBar: AppBar(
        title: Text(l10n.kelolaWilayah),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.segarkan,
            onPressed: _load,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createItem,
        backgroundColor: SigapColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(l10n.tambahWilayah),
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
                hintText: l10n.hintSearchWilayah,
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
                            Text(
                              l10n.gagalMemuatWilayah,
                              style: const TextStyle(
                                fontSize: SigapTypography.bodyLarge,
                                fontWeight: FontWeight.bold,
                                color: SigapColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: SigapSpacing.xs),
                            Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: SigapTypography.bodySmall,
                                color: SigapColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: SigapSpacing.lg),
                            ElevatedButton.icon(
                              onPressed: _load,
                              icon: const Icon(Icons.refresh, size: 18),
                              label: Text(l10n.cobaLagi),
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
                          Text(
                            l10n.tidakAdaWilayah,
                            style: const TextStyle(
                              fontSize: SigapTypography.bodyLarge,
                              fontWeight: FontWeight.bold,
                              color: SigapColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: SigapSpacing.xs),
                          Text(
                            _searchQuery.isNotEmpty
                                ? '${l10n.tidakAdaWilayahCocok} "$_searchQuery".'
                                : l10n.belumAdaWilayahTerdaftar,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: SigapTypography.bodyText,
                              color: SigapColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: SigapSpacing.lg),
                          OutlinedButton.icon(
                            onPressed: _createItem,
                            icon: const Icon(Icons.add),
                            label: Text(l10n.tambahWilayahBaru),
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
                                fontSize: SigapTypography.bodyMedium,
                                color: SigapColors.textPrimary,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                'ID: ${id.length > 8 ? id.substring(0, 8) : id}',
                                style: const TextStyle(
                                  fontSize: SigapTypography.captionMedium,
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
                                  fontSize: SigapTypography.captionSmall,
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
