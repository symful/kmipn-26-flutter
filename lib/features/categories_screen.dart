import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/exceptions.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../../providers/providers.dart';
import '../../../theme/tokens.dart';
import '../../../widgets/design_system/design_system.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  List<Map<String, dynamic>> _items = [];
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
      final data = await client.getCategories();
      setState(() {
        _items = data.map((c) => c.toJson()).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = extractErrorMessage(e);
        _loading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filtered {
    if (_searchQuery.trim().isEmpty) return _items;
    final q = _searchQuery.toLowerCase();
    return _items.where((item) {
      final name = (item['name'] as String? ?? '').toLowerCase();
      final slug = (item['slug'] as String? ?? '').toLowerCase();
      return name.contains(q) || slug.contains(q);
    }).toList();
  }

  Future<void> _createItem() async {
    final nameController = TextEditingController();
    final slugController = TextEditingController();
    final iconController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final dl10n = AppLocalizations.of(ctx)!;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SigapRadius.lg),
          ),
          backgroundColor: SigapColors.surface,
          title: Row(
            children: [
              const Icon(Icons.category, color: SigapColors.primary),
              const SizedBox(width: SigapSpacing.sm),
              Text(
                dl10n.tambahKategori,
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
                  dl10n.buatKategori,
                  style: const TextStyle(
                    fontSize: SigapTypography.bodySmall,
                    color: SigapColors.textSecondary,
                  ),
                ),
                const SizedBox(height: SigapSpacing.md),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: dl10n.namaWAJIB,
                    hintText: dl10n.hintKategoriName,
                    prefixIcon: const Icon(Icons.label_outline, size: 20),
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
                TextField(
                  controller: slugController,
                  decoration: InputDecoration(
                    labelText: dl10n.labelSlug,
                    hintText: dl10n.hintKategoriSlug,
                    prefixIcon: const Icon(Icons.link, size: 20),
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
                TextField(
                  controller: iconController,
                  decoration: InputDecoration(
                    labelText: dl10n.labelIcon,
                    hintText: dl10n.hintKategoriIcon,
                    prefixIcon: const Icon(Icons.emoji_symbols, size: 20),
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
                      content: Text(dl10n.namaKategoriWajibDiisi),
                      backgroundColor: SigapColors.warning,
                    ),
                  );
                  return;
                }
                try {
                  final client = ref.read(apiClientProvider);
                  await client.dio.post(
                    '/api/categories',
                    data: {
                      'name': nameController.text.trim(),
                      if (slugController.text.trim().isNotEmpty)
                        'slug': slugController.text.trim(),
                      if (iconController.text.trim().isNotEmpty)
                        'icon': iconController.text.trim(),
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
    );
    if (result == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final dl10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: SigapColors.bgScreen,
      appBar: AppBar(
        title: Text(dl10n.kelolaKategori),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: dl10n.segarkan,
            onPressed: _load,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createItem,
        backgroundColor: SigapColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(dl10n.tambahKategori),
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
                hintText: dl10n.hintSearchKategori,
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
                ? Padding(
                    padding: const EdgeInsets.all(SigapSpacing.lg),
                    child: ErrorRetryView(message: _error!, onRetry: _load),
                  )
                : _filtered.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(SigapSpacing.lg),
                    child: EmptyState(
                      icon: Icons.category_outlined,
                      title: dl10n.tidakAdaKategori,
                      subtitle: _searchQuery.isNotEmpty
                          ? '${dl10n.tidakAdaWilayahCocok} "$_searchQuery".'
                          : dl10n.belumAdaKategoriLaporanTerdaftar,
                      action: OutlinedButton.icon(
                        onPressed: _createItem,
                        icon: const Icon(Icons.add),
                        label: Text(dl10n.tambahKategoriBaru),
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
                        final name = item['name'] as String? ?? '-';
                        final slug = item['slug'] as String? ?? '-';
                        final icon = item['icon'] as String?;

                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: SigapSpacing.sm,
                          ),
                          child: SigapCard(
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: SigapSpacing.md,
                                vertical: SigapSpacing.xs,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: SigapColors.primaryLight,
                                foregroundColor: SigapColors.primary,
                                child: Icon(
                                  _mapCategoryIcon(icon),
                                  size: 20,
                                  color: SigapColors.primary,
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
                                  'Slug: $slug',
                                  style: const TextStyle(
                                    fontSize: SigapTypography.bodySmall,
                                    color: SigapColors.textSecondary,
                                  ),
                                ),
                              ),
                              trailing: StatusPill(
                                label: slug,
                                tone: StatusTone.neutral,
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

  IconData _mapCategoryIcon(String? iconName) {
    if (iconName == null || iconName.isEmpty) return Icons.category;
    switch (iconName.toLowerCase()) {
      case 'road':
      case 'jalan':
        return Icons.add_road;
      case 'trash':
      case 'sampah':
        return Icons.delete_outline;
      case 'lightbulb':
      case 'lampu':
        return Icons.lightbulb_outline;
      case 'water':
      case 'air':
      case 'banjir':
        return Icons.water_drop_outlined;
      case 'tree':
      case 'pohon':
        return Icons.park_outlined;
      case 'building':
      case 'bangunan':
        return Icons.location_city;
      case 'traffic':
      case 'macet':
        return Icons.traffic;
      case 'hospital':
      case 'kesehatan':
        return Icons.local_hospital;
      default:
        return Icons.category_outlined;
    }
  }
}
