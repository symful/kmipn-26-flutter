import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/exceptions.dart';
import '../../../api/types.g.dart';
import '../../../l10n/strings.dart';
import '../../../providers/providers.dart';
import '../../../theme/tokens.dart';
import '../../../widgets/design_system/design_system.dart';

class SlaScreen extends ConsumerStatefulWidget {
  const SlaScreen({super.key});

  @override
  ConsumerState<SlaScreen> createState() => _SlaScreenState();
}

class _SlaScreenState extends ConsumerState<SlaScreen> {
  List<SlaConfig> _items = [];
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
      final data = await client.getSlaConfigs(limit: 100);
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

  Future<void> _editItem(SlaConfig item) async {
    final slaHoursController = TextEditingController(
      text: (item.slaDays ?? '').toString(),
    );
    bool isActive = item.isActive ?? true;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SigapRadius.lg),
          ),
          backgroundColor: SigapColors.surface,
          title: Row(
            children: [
              const Icon(Icons.timer, color: SigapColors.primary),
              const SizedBox(width: SigapSpacing.sm),
              Expanded(
                child: Text(
                  'Edit SLA: ${item.name ?? '-'}',
                  style: const TextStyle(
                    fontSize: SigapTypography.size16,
                    fontWeight: FontWeight.bold,
                    color: SigapColors.textPrimary,
                  ),
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
                  'Tentukan batas waktu standar penanganan (SLA) untuk kategori laporan ini.',
                  style: TextStyle(
                    fontSize: SigapTypography.size12,
                    color: SigapColors.textSecondary,
                  ),
                ),
                const SizedBox(height: SigapSpacing.md),
                TextField(
                  controller: slaHoursController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Target Batas Waktu SLA (jam)',
                    hintText: 'Contoh: 24, 48, 72',
                    suffixText: 'Jam',
                    prefixIcon: const Icon(Icons.hourglass_bottom, size: 20),
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
                Container(
                  decoration: BoxDecoration(
                    color: SigapColors.bgSurface,
                    borderRadius: BorderRadius.circular(SigapRadius.md),
                    border: Border.all(color: SigapColors.border),
                  ),
                  child: SwitchListTile(
                    title: const Text(
                      'Status SLA Aktif',
                      style: TextStyle(
                        fontSize: SigapTypography.size13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text(
                      'Jika dinonaktifkan, peringatan keterlambatan tidak dihitung',
                      style: TextStyle(fontSize: SigapTypography.size11),
                    ),
                    value: isActive,
                    activeTrackColor: SigapColors.primary,
                    onChanged: (val) => setDialogState(() => isActive = val),
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
                if (slaHoursController.text.trim().isEmpty) return;
                try {
                  final client = ref.read(apiClientProvider);
                  final id = item.id.toString();
                  await client.updateSla(
                    id,
                    SlaConfig(
                      name: item.name,
                      slaDays:
                          int.tryParse(slaHoursController.text.trim()) ?? 0,
                      priority: item.priority,
                      isActive: isActive,
                    ),
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
    if (saved == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SigapColors.bgScreen,
      appBar: AppBar(
        title: const Text('Konfigurasi SLA'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Segarkan',
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: SigapColors.primary),
            )
          : _error != null
          ? Padding(
              padding: const EdgeInsets.all(SigapSpacing.lg),
              child: ErrorRetryView(message: _error!, onRetry: _load),
            )
          : _items.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(SigapSpacing.lg),
              child: EmptyState(
                icon: Icons.timer_outlined,
                title: 'Tidak Ada Data SLA',
                subtitle:
                    'Belum ada konfigurasi batas waktu penanganan pengaduan.',
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              color: SigapColors.primary,
              child: ListView.builder(
                padding: const EdgeInsets.all(SigapSpacing.lg),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  final categoryName = item.name ?? '-';
                  final slaHours = item.slaDays ?? 0;
                  final isActive = item.isActive ?? true;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: SigapSpacing.sm),
                    child: SigapCard(
                      borderTopColor: isActive
                          ? SigapColors.selesai
                          : SigapColors.textMuted,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: SigapSpacing.md,
                          vertical: SigapSpacing.xs,
                        ),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isActive
                                ? SigapColors.primary.withValues(alpha: 0.1)
                                : SigapColors.textMuted.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(SigapRadius.sm),
                            border: Border.all(
                              color: isActive
                                  ? SigapColors.primary.withValues(alpha: 0.25)
                                  : SigapColors.border,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${slaHours}h',
                              style: TextStyle(
                                fontSize: SigapTypography.size14,
                                fontWeight: FontWeight.bold,
                                color: isActive
                                    ? SigapColors.primary
                                    : SigapColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          categoryName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: SigapTypography.size14,
                            color: SigapColors.textPrimary,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Row(
                            children: [
                              StatusPill(
                                label: isActive ? 'Aktif' : 'Nonaktif',
                                tone: isActive
                                    ? StatusTone.success
                                    : StatusTone.neutral,
                              ),
                              const SizedBox(width: SigapSpacing.sm),
                              Text(
                                'Target: $slaHours jam (${(slaHours / 24).toStringAsFixed(slaHours % 24 == 0 ? 0 : 1)} hari)',
                                style: const TextStyle(
                                  fontSize: SigapTypography.size12,
                                  color: SigapColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 20,
                            color: SigapColors.primary,
                          ),
                          tooltip: 'Edit SLA',
                          onPressed: () => _editItem(item),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
