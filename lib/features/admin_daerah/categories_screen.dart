import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/exceptions.dart';
import '../../../l10n/strings.dart';
import '../../../providers/providers.dart';
import '../../../theme/tokens.dart';

class AdminDaerahCategoriesScreen extends ConsumerStatefulWidget {
  const AdminDaerahCategoriesScreen({super.key});

  @override
  ConsumerState<AdminDaerahCategoriesScreen> createState() =>
      _AdminDaerahCategoriesScreenState();
}

class _AdminDaerahCategoriesScreenState
    extends ConsumerState<AdminDaerahCategoriesScreen> {
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
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SigapRadius.lg),
        ),
        backgroundColor: SigapColors.surface,
        title: const Row(
          children: [
            Icon(Icons.category, color: SigapColors.primary),
            SizedBox(width: SigapSpacing.sm),
            Text(
              'Tambah Kategori',
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
                'Buat kategori laporan baru untuk memudahkan klasifikasi pengaduan masyarakat.',
                style: TextStyle(
                  fontSize: SigapTypography.size12,
                  color: SigapColors.textSecondary,
                ),
              ),
              const SizedBox(height: SigapSpacing.md),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: Strings.namaWAJIB,
                  hintText: 'Misal: Jalan Rusak, Sampah Liar',
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
                  labelText: 'Slug (opsional)',
                  hintText: 'misal: jalan-rusak',
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
                  labelText: 'Icon / Simbol (opsional)',
                  hintText: 'misal: road, trash, lightbulb',
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
                    content: Text('Nama kategori wajib diisi'),
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
    );
    if (result == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SigapColors.bgScreen,
      appBar: AppBar(
        title: const Text('Kelola Kategori'),
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
        label: const Text('Tambah Kategori'),
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
                hintText: 'Cari kategori berdasarkan nama atau slug...',
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
                              'Gagal Memuat Kategori',
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
                              Icons.category_outlined,
                              size: 48,
                              color: SigapColors.primary,
                            ),
                          ),
                          const SizedBox(height: SigapSpacing.md),
                          const Text(
                            'Tidak Ada Kategori',
                            style: TextStyle(
                              fontSize: SigapTypography.size16,
                              fontWeight: FontWeight.bold,
                              color: SigapColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: SigapSpacing.xs),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'Tidak ada kategori yang cocok dengan pencarian "$_searchQuery".'
                                : 'Belum ada kategori laporan yang terdaftar.',
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
                            label: const Text('Tambah Kategori Baru'),
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
                        final name = item['name'] as String? ?? '-';
                        final slug = item['slug'] as String? ?? '-';
                        final icon = item['icon'] as String?;

                        return Container(
                          margin: const EdgeInsets.only(bottom: SigapSpacing.sm),
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
                                fontSize: SigapTypography.size14,
                                color: SigapColors.textPrimary,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                'Slug: $slug',
                                style: const TextStyle(
                                  fontSize: SigapTypography.size12,
                                  color: SigapColors.textSecondary,
                                ),
                              ),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: SigapSpacing.sm,
                                vertical: SigapSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: SigapColors.bgSurface,
                                borderRadius: BorderRadius.circular(SigapRadius.pill),
                                border: Border.all(color: SigapColors.border),
                              ),
                              child: Text(
                                slug,
                                style: const TextStyle(
                                  fontSize: SigapTypography.size11,
                                  fontFamily: 'monospace',
                                  color: SigapColors.textMuted,
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
