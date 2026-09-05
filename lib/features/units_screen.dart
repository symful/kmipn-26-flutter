import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/exceptions.dart';
import '../../../api/client.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../../providers/providers.dart';
import '../../../theme/tokens.dart';
import '../../../widgets/design_system/design_system.dart';

class UnitsScreen extends ConsumerStatefulWidget {
  const UnitsScreen({super.key});

  @override
  ConsumerState<UnitsScreen> createState() => _UnitsScreenState();
}

class _UnitsScreenState extends ConsumerState<UnitsScreen> {
  List<Unit> _items = [];
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
      final data = await client.getUnits(limit: 100);
      setState(() {
        _items = data.entries;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = extractErrorMessage(e);
        _loading = false;
      });
    }
  }

  List<Unit> get _filtered {
    if (_searchQuery.trim().isEmpty) return _items;
    final q = _searchQuery.toLowerCase();
    return _items.where((item) {
      final name = (item.name ?? '').toLowerCase();
      final region = (item.region ?? '').toLowerCase();
      return name.contains(q) || region.contains(q);
    }).toList();
  }

  Future<void> _createItem() async {
    final nameController = TextEditingController();
    final wilayahIdController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx)!;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SigapRadius.lg),
          ),
          backgroundColor: SigapColors.surface,
          title: Row(
            children: [
              const Icon(Icons.business, color: SigapColors.primary),
              const SizedBox(width: SigapSpacing.sm),
              Text(
                l10n.tambahUnitKerja,
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
                  l10n.daftarkanUnit,
                  style: const TextStyle(
                    fontSize: SigapTypography.bodySmall,
                    color: SigapColors.textSecondary,
                  ),
                ),
                const SizedBox(height: SigapSpacing.md),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: l10n.namaUnitWAJIB,
                    hintText: l10n.hintUnitName,
                    prefixIcon: const Icon(Icons.apartment_outlined, size: 20),
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
                  controller: wilayahIdController,
                  decoration: InputDecoration(
                    labelText: l10n.labelKodeWilayah,
                    hintText: l10n.hintWilayahSearch,
                    prefixIcon: const Icon(Icons.map_outlined, size: 20),
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
                l10n.batal,
                style: TextStyle(color: SigapColors.textSecondary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: SigapColors.primary,
                foregroundColor: SigapColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SigapRadius.sm),
                ),
              ),
              onPressed: () async {
                if (nameController.text.trim().isEmpty ||
                    wilayahIdController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                      content: Text(l10n.namaUnitWilayahWajibDiisi),
                      backgroundColor: SigapColors.warning,
                    ),
                  );
                  return;
                }
                try {
                  final client = ref.read(apiClientProvider);
                  await client.createUnit(
                    name: nameController.text.trim(),
                    region: wilayahIdController.text.trim(),
                  );
                  if (ctx.mounted) Navigator.pop(ctx, true);
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(
                        content: Text(
                          l10n.errorDenganPesan(extractErrorMessage(e)),
                        ),
                        backgroundColor: SigapColors.perluTindakan,
                      ),
                    );
                  }
                }
              },
              child: Text(l10n.simpan),
            ),
          ],
        );
      },
    );
    if (result == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final activeRole = ref.watch(authNotifierProvider).activeRole ?? '';
    return AuthenticatedShell(
      activeRole: activeRole,
      useScaffold: true,
      backgroundColor: SigapColors.bgScreen,
      appBar: SigapAppBar(
        title: l10n.kelolaUnit,
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
        foregroundColor: SigapColors.surface,
        icon: const Icon(Icons.add),
        label: Text(l10n.tambahUnit),
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
                hintText: l10n.hintSearchUnit,
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
                      icon: Icons.business_outlined,
                      title: l10n.tidakAdaUnit,
                      subtitle: _searchQuery.isNotEmpty
                          ? '${l10n.tidakAdaWilayahCocok} "$_searchQuery".'
                          : l10n.belumAdaUnitKerjaTerdaftar,
                      action: OutlinedButton.icon(
                        onPressed: _createItem,
                        icon: const Icon(Icons.add),
                        label: Text(l10n.tambahUnitBaru),
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
                        final name = item.name ?? '-';
                        final region = item.region ?? '-';

                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: SigapSpacing.sm,
                          ),
                          child: SigapCard(
                            borderTopColor: SigapColors.diproses,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: SigapSpacing.md,
                                vertical: SigapSpacing.xs,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: SigapColors.diproses
                                    .withValues(alpha: 0.1),
                                foregroundColor: SigapColors.diproses,
                                child: const Icon(
                                  Icons.apartment,
                                  size: 20,
                                  color: SigapColors.diproses,
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
                                  l10n.wilayahPrefix(region),
                                  style: const TextStyle(
                                    fontSize: SigapTypography.bodySmall,
                                    color: SigapColors.textSecondary,
                                  ),
                                ),
                              ),
                              trailing: StatusPill(
                                label: region,
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
}
