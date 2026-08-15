import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/exceptions.dart';
import '../../../providers/providers.dart';
import '../../../theme/tokens.dart';

class AdminDaerahWilayahScreen extends ConsumerStatefulWidget {
  const AdminDaerahWilayahScreen({super.key});

  @override
  ConsumerState<AdminDaerahWilayahScreen> createState() =>
      _AdminDaerahWilayahScreenState();
}

class _AdminDaerahWilayahScreenState
    extends ConsumerState<AdminDaerahWilayahScreen> {
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
      final data = await client.get('/api/admin-daerah/wilayah');
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
    final parentController = TextEditingController();
    final levelController = TextEditingController(text: 'kelurahan');
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Wilayah'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Wilayah (WAJIB)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: SigapSpacing.sm),
              TextField(
                controller: parentController,
                decoration: const InputDecoration(
                  labelText: 'Parent ID (opsional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: SigapSpacing.sm),
              TextField(
                controller: levelController,
                decoration: const InputDecoration(
                  labelText: 'Level',
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
              if (nameController.text.trim().isEmpty) return;
              try {
                final client = ref.read(apiClientProvider);
                await client.post(
                  '/api/admin-daerah/wilayah',
                  data: {
                    'name': nameController.text.trim(),
                    if (parentController.text.trim().isNotEmpty)
                      'parent_id': parentController.text.trim(),
                    'level': levelController.text.trim(),
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
      appBar: AppBar(title: const Text('Kelola Wilayah')),
      floatingActionButton: FloatingActionButton(
        onPressed: _createItem,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _ErrorRetry(error: _error!, onRetry: _load)
          : _items.isEmpty
          ? const Center(child: Text('Tidak ada data'))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(SigapSpacing.lg),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  final id = item['id']?.toString() ?? '';
                  return _ListTile(
                    title: item['name'] as String? ?? '-',
                    subtitle: 'Level: ${item['level'] ?? '-'}',
                    trailing: Text(
                      'ID: ${id.length > 8 ? id.substring(0, 8) : id}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontFamily: 'monospace',
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class _ListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;
  const _ListTile({required this.title, required this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: SigapSpacing.sm),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: trailing,
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorRetry({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: SigapColors.perluTindakan,
          ),
          const SizedBox(height: 12),
          Text('Gagal: $error', style: const TextStyle(fontSize: 13)),
          ElevatedButton(onPressed: onRetry, child: const Text('Coba Lagi')),
        ],
      ),
    );
  }
}
