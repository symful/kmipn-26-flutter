import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/exceptions.dart';
import '../../../l10n/strings.dart';
import '../../../providers/providers.dart';
import '../../../theme/tokens.dart';

class AdminDaerahSlaScreen extends ConsumerStatefulWidget {
  const AdminDaerahSlaScreen({super.key});

  @override
  ConsumerState<AdminDaerahSlaScreen> createState() =>
      _AdminDaerahSlaScreenState();
}

class _AdminDaerahSlaScreenState extends ConsumerState<AdminDaerahSlaScreen> {
  List<Map<String, dynamic>> _items = [];
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
      final data = await client.getAdminDaerahSla();
      setState(() {
        _items = (data['data'] as List? ?? []).cast();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = extractErrorMessage(e);
        _loading = false;
      });
    }
  }

  Future<void> _editItem(Map<String, dynamic> item) async {
    final slaHoursController = TextEditingController(
      text: (item['jam'] ?? '').toString(),
    );
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit SLA: ${item['kategori_nama'] ?? '-'}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: slaHoursController,
                decoration: const InputDecoration(
                  labelText: 'SLA (jam)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(Strings.batal),
          ),
          ElevatedButton(
            onPressed: () async {
              if (slaHoursController.text.trim().isEmpty) return;
              try {
                final client = ref.read(apiClientProvider);
                final id = item['id'].toString();
                await client.updateAdminDaerahSla(
                  id,
                  jam: int.tryParse(slaHoursController.text.trim()) ?? 0,
                );
                if (ctx.mounted) Navigator.pop(ctx, true);
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text('Error: ${extractErrorMessage(e)}')),
                  );
                }
              }
            },
            child: const Text(Strings.simpan),
          ),
        ],
      ),
    );
    if (saved == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Konfigurasi SLA')),
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
          : _items.isEmpty
          ? const Center(child: Text('Tidak ada data SLA'))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(SigapSpacing.lg),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  final categoryName = item['kategori_nama'] as String? ?? '-';
                  final slaHours = item['jam'] ?? '-';
                  final isActive = item['is_active'] ?? true;

                  return Card(
                    margin: const EdgeInsets.only(bottom: SigapSpacing.sm),
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isActive
                              ? SigapColors.selesai.withValues(alpha: 0.1)
                              : SigapColors.textMuted.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${slaHours}h',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isActive
                                  ? SigapColors.selesai
                                  : SigapColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        categoryName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        'SLA: $slaHours jam — ${isActive ? "Aktif" : "Nonaktif"}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => _editItem(item),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
