import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/exceptions.dart';
import '../../../l10n/strings.dart';
import '../../../providers/providers.dart';
import '../../../theme/tokens.dart';

class AdminDaerahAccountsScreen extends ConsumerStatefulWidget {
  const AdminDaerahAccountsScreen({super.key});

  @override
  ConsumerState<AdminDaerahAccountsScreen> createState() =>
      _AdminDaerahAccountsScreenState();
}

class _AdminDaerahAccountsScreenState
    extends ConsumerState<AdminDaerahAccountsScreen> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  String? _error;
  String _roleFilter = 'all';

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
      final data = await client.getAdminUsers();
      setState(() {
        _items = (data['data'] as List? ?? []).cast<Map<String, dynamic>>();
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
    if (_roleFilter == 'all') return _items;
    return _items
        .where((u) => (u['role'] as String?)?.toLowerCase() == _roleFilter)
        .toList();
  }

  Future<void> _createUser() async {
    final emailController = TextEditingController();
    final nameController = TextEditingController();
    String? selectedRole = 'PETUGAS';
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => AlertDialog(
          title: const Text('Tambah Pengguna'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email (WAJIB)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: SigapSpacing.sm),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: Strings.namaWAJIB,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: SigapSpacing.sm),
                DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'PETUGAS', child: Text('PETUGAS')),
                    DropdownMenuItem(
                      value: 'SURVEYOR',
                      child: Text('SURVEYOR'),
                    ),
                    DropdownMenuItem(
                      value: 'VERIFIKATOR',
                      child: Text('VERIFIKATOR'),
                    ),
                    DropdownMenuItem(
                      value: 'OPERATOR',
                      child: Text('OPERATOR'),
                    ),
                    DropdownMenuItem(
                      value: 'ADMIN_DAERAH',
                      child: Text('ADMIN_DAERAH'),
                    ),
                  ],
                  onChanged: (v) => setSheetState(() => selectedRole = v),
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
                if (emailController.text.trim().isEmpty ||
                    nameController.text.trim().isEmpty) {
                  return;
                }
                try {
                  final client = ref.read(apiClientProvider);
                  await client.post(
                    '/api/admin-daerah/accounts',
                    data: {
                      'email': emailController.text.trim(),
                      'name': nameController.text.trim(),
                      'role': selectedRole,
                    },
                  );
                  if (ctx.mounted) Navigator.pop(ctx, true);
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${extractErrorMessage(e)}'),
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
      appBar: AppBar(
        title: const Text('Kelola Akun'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (v) => setState(() => _roleFilter = v),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'all', child: Text('Semua Role')),
              const PopupMenuItem(value: 'petugas', child: Text('PETUGAS')),
              const PopupMenuItem(value: 'surveyor', child: Text('SURVEYOR')),
              const PopupMenuItem(
                value: 'verifikator',
                child: Text('VERIFIKATOR'),
              ),
              const PopupMenuItem(value: 'operator', child: Text('OPERATOR')),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createUser,
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
          : _filtered.isEmpty
          ? const Center(child: Text('Tidak ada akun'))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(SigapSpacing.lg),
                itemCount: _filtered.length,
                itemBuilder: (context, index) {
                  final user = _filtered[index];
                  final role = user['role'] as String? ?? '-';
                  return Card(
                    margin: const EdgeInsets.only(bottom: SigapSpacing.sm),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: SigapColors.primary.withValues(
                          alpha: 0.1,
                        ),
                        child: Text(
                          (user['name'] as String? ?? '?')[0].toUpperCase(),
                          style: const TextStyle(color: SigapColors.primary),
                        ),
                      ),
                      title: Text(
                        user['name'] as String? ?? '-',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        user['email'] as String? ?? '-',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: SigapSpacing.sm,
                          vertical: SigapSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: _roleColor(role).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(SigapRadius.sm),
                        ),
                        child: Text(
                          role,
                          style: TextStyle(
                            fontSize: 11,
                            color: _roleColor(role),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Color _roleColor(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
      case 'ADMIN_DAERAH':
        return SigapColors.perluTindakan;
      case 'OPERATOR':
        return SigapColors.diproses;
      case 'VERIFIKATOR':
        return SigapColors.diproses;
      case 'SURVEYOR':
        return SigapColors.primary;
      case 'PETUGAS':
        return SigapColors.offlineDot;
      default:
        return SigapColors.textMuted;
    }
  }
}
