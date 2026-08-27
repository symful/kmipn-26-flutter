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

  final List<String> _roleOptions = const [
    'all',
    'petugas',
    'surveyor',
    'verifikator',
    'operator',
    'admin_daerah',
  ];

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
      final data = await client.getUsers(limit: 100);
      setState(() {
        _items = data.entries.map((u) => u.toJson()).toList();
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SigapRadius.lg),
          ),
          backgroundColor: SigapColors.surface,
          title: const Row(
            children: [
              Icon(Icons.person_add, color: SigapColors.primary),
              SizedBox(width: SigapSpacing.sm),
              Text(
                'Tambah Pengguna',
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
                  'Masukkan informasi akun pengguna baru untuk sistem SIGAP.',
                  style: TextStyle(
                    fontSize: SigapTypography.size12,
                    color: SigapColors.textSecondary,
                  ),
                ),
                const SizedBox(height: SigapSpacing.md),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email (Wajib)',
                    hintText: 'contoh@daerah.go.id',
                    prefixIcon: const Icon(Icons.email_outlined, size: 20),
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
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: Strings.namaWAJIB,
                    hintText: 'Nama lengkap pengguna',
                    prefixIcon: const Icon(Icons.badge_outlined, size: 20),
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
                  initialValue: selectedRole,
                  decoration: InputDecoration(
                    labelText: 'Peran / Role',
                    prefixIcon: const Icon(Icons.admin_panel_settings_outlined, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(SigapRadius.md),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: SigapSpacing.md,
                      vertical: SigapSpacing.sm,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'PETUGAS', child: Text('PETUGAS (Lapangan)')),
                    DropdownMenuItem(value: 'SURVEYOR', child: Text('SURVEYOR (Verifikasi Fisik)')),
                    DropdownMenuItem(value: 'VERIFIKATOR', child: Text('VERIFIKATOR (Validasi)')),
                    DropdownMenuItem(value: 'OPERATOR', child: Text('OPERATOR (Disposisi)')),
                    DropdownMenuItem(value: 'ADMIN_DAERAH', child: Text('ADMIN DAERAH')),
                  ],
                  onChanged: (v) => setSheetState(() => selectedRole = v),
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
                if (emailController.text.trim().isEmpty ||
                    nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                      content: Text('Email dan nama wajib diisi'),
                      backgroundColor: SigapColors.warning,
                    ),
                  );
                  return;
                }
                try {
                  final client = ref.read(apiClientProvider);
                  await client.createUser(
                    email: emailController.text.trim(),
                    password: '',
                    name: nameController.text.trim(),
                    role: selectedRole!,
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
        title: const Text('Kelola Akun'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Segarkan',
            onPressed: _load,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createUser,
        backgroundColor: SigapColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Akun'),
      ),
      body: Column(
        children: [
          // Filter Chips Row
          Container(
            color: SigapColors.surface,
            padding: const EdgeInsets.symmetric(
              horizontal: SigapSpacing.lg,
              vertical: SigapSpacing.sm,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _roleOptions.map((role) {
                  final isSelected = _roleFilter == role;
                  final label = role == 'all'
                      ? 'Semua Role (${_items.length})'
                      : '${role.replaceAll('_', ' ').toUpperCase()} (${_items.where((u) => (u['role'] as String?)?.toLowerCase() == role).length})';
                  return Padding(
                    padding: const EdgeInsets.only(right: SigapSpacing.sm),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(label),
                      labelStyle: TextStyle(
                        fontSize: SigapTypography.size12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? Colors.white : SigapColors.textPrimary,
                      ),
                      selectedColor: SigapColors.primary,
                      backgroundColor: SigapColors.bgSurface,
                      checkmarkColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(SigapRadius.pill),
                        side: BorderSide(
                          color: isSelected ? SigapColors.primary : SigapColors.border,
                        ),
                      ),
                      onSelected: (_) => setState(() => _roleFilter = role),
                    ),
                  );
                }).toList(),
              ),
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
                              'Gagal Memuat Akun',
                              style: const TextStyle(
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
                              Icons.people_outline,
                              size: 48,
                              color: SigapColors.primary,
                            ),
                          ),
                          const SizedBox(height: SigapSpacing.md),
                          const Text(
                            'Tidak Ada Akun',
                            style: TextStyle(
                              fontSize: SigapTypography.size16,
                              fontWeight: FontWeight.bold,
                              color: SigapColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: SigapSpacing.xs),
                          Text(
                            _roleFilter == 'all'
                                ? 'Belum ada akun pengguna yang terdaftar.'
                                : 'Tidak ada pengguna dengan peran "${_roleFilter.toUpperCase()}".',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: SigapTypography.size13,
                              color: SigapColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: SigapSpacing.lg),
                          OutlinedButton.icon(
                            onPressed: _createUser,
                            icon: const Icon(Icons.add),
                            label: const Text('Tambah Akun Baru'),
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
                        final user = _filtered[index];
                        final role = (user['role'] as String?) ?? '-';
                        final name = (user['name'] as String?) ?? '-';
                        final email = (user['email'] as String?) ?? '-';
                        final roleCol = _roleColor(role);

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
                              backgroundColor: roleCol.withValues(alpha: 0.12),
                              foregroundColor: roleCol,
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : '?',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: roleCol,
                                ),
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
                                email,
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
                                color: roleCol.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(SigapRadius.pill),
                                border: Border.all(
                                  color: roleCol.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Text(
                                role.toUpperCase(),
                                style: TextStyle(
                                  fontSize: SigapTypography.size10,
                                  color: roleCol,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: SigapTypography.letterSpacingLabel,
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
