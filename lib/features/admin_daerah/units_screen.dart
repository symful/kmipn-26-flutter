import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/exceptions.dart';
import '../../../providers/providers.dart';
import '../../../theme/tokens.dart';

class AdminDaerahUnitsScreen extends ConsumerStatefulWidget {
  const AdminDaerahUnitsScreen({super.key});

  @override
  ConsumerState<AdminDaerahUnitsScreen> createState() =>
      _AdminDaerahUnitsScreenState();
}

class _AdminDaerahUnitsScreenState
    extends ConsumerState<AdminDaerahUnitsScreen> {
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
      final data = await client.get('/api/admin-daerah/units');
      setState(() {
        _items = (data['items'] as List? ?? data['data'] as List? ?? []).cast();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = extractErrorMessage(e);
        _loading = false;
      });
    }
  }

  Future<void> _createItem() async {
    final nameController = TextEditingController();
    final wilayahIdController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Unit'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Unit (WAJIB)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: SigapSpacing.sm),
              TextField(
                controller: wilayahIdController,
                decoration: const InputDecoration(
                  labelText: 'Wilayah ID (WAJIB)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty ||
                  wilayahIdController.text.trim().isEmpty) {
                return;
              }
              try {
                final client = ref.read(apiClientProvider);
                await client.post(
                  '/api/admin-daerah/units',
                  data: {
                    'name': nameController.text.trim(),
                    'wilayah_id': wilayahIdController.text.trim(),
                  },
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
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (result == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Unit')),
      floatingActionButton: FloatingActionButton(
        onPressed: _createItem,
        child: const Icon(Icons.add),
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
          : _items.isEmpty
          ? const Center(child: Text('Tidak ada unit'))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(SigapSpacing.lg),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: SigapSpacing.sm),
                    child: ListTile(
                      leading: const Icon(
                        Icons.group,
                        color: SigapColors.primary,
                      ),
                      title: Text(
                        item['name'] as String? ?? '-',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        'Wilayah: ${item['wilayah_id'] ?? '-'}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
