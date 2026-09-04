import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/exceptions.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../../providers/providers.dart';
import '../../../theme/tokens.dart';
import '../../../widgets/design_system/design_system.dart';

class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key});

  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  String? _error;
  String _roleFilter = 'all';

  // NOTE: Role options are intentionally static (not fetched from API).
  // These are stable RBAC roles defined by the backend system.
  // If the backend introduces dynamic role configuration, this should be
  // refactored to fetch from /api/roles or similar endpoint.
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
        builder: (ctx, setSheetState) {
          final dl10n = AppLocalizations.of(ctx)!;
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SigapRadius.lg),
            ),
            backgroundColor: SigapColors.surface,
            title: Row(
              children: [
                const Icon(Icons.person_add, color: SigapColors.primary),
                const SizedBox(width: SigapSpacing.sm),
                Text(
                  dl10n.tambahPengguna,
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
                    dl10n.masukkanInformasi,
                    style: const TextStyle(
                      fontSize: SigapTypography.bodySmall,
                      color: SigapColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: SigapSpacing.md),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: dl10n.labelEmailWajib,
                      hintText: dl10n.hintEmail,
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        size: SigapTypography.headlineSmall,
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
                  const SizedBox(height: SigapSpacing.md),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: dl10n.namaWAJIB,
                      hintText: dl10n.hintNamaLengkap,
                      prefixIcon: const Icon(
                        Icons.badge_outlined,
                        size: SigapTypography.headlineSmall,
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
                  const SizedBox(height: SigapSpacing.md),
                  DropdownButtonFormField<String>(
                    initialValue: selectedRole,
                    decoration: InputDecoration(
                      labelText: dl10n.labelPeranRole,
                      prefixIcon: const Icon(
                        Icons.admin_panel_settings_outlined,
                        size: SigapTypography.headlineSmall,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(SigapRadius.md),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: SigapSpacing.md,
                        vertical: SigapSpacing.sm,
                      ),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'PETUGAS',
                        child: Text(dl10n.petugasLapangan),
                      ),
                      DropdownMenuItem(
                        value: 'SURVEYOR',
                        child: Text(dl10n.surveyorVerifikasiFisik),
                      ),
                      DropdownMenuItem(
                        value: 'VERIFIKATOR',
                        child: Text(dl10n.verifikatorValidasi),
                      ),
                      DropdownMenuItem(
                        value: 'OPERATOR',
                        child: Text(dl10n.operatorDisposisi),
                      ),
                      DropdownMenuItem(
                        value: 'ADMIN_DAERAH',
                        child: Text(dl10n.adminDaerah),
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
                  if (emailController.text.trim().isEmpty ||
                      nameController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(
                        content: Text(dl10n.emailNamaWajibDiisi),
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

  StatusTone _roleTone(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN_DAERAH':
        return StatusTone.danger;
      case 'OPERATOR':
      case 'VERIFIKATOR':
        return StatusTone.warning;
      case 'SURVEYOR':
        return StatusTone.info;
      case 'PETUGAS':
        return StatusTone.neutral;
      default:
        return StatusTone.neutral;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dl10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: SigapColors.bgScreen,
      appBar: AppBar(
        title: Text(dl10n.kelolaAkun),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: dl10n.segarkan,
            onPressed: _load,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createUser,
        backgroundColor: SigapColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(dl10n.tambahAkun),
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
                      ? '${dl10n.semuaRole} (${_items.length})'
                      : '${role.replaceAll('_', ' ').toUpperCase()} (${_items.where((u) => (u['role'] as String?)?.toLowerCase() == role).length})';
                  return Padding(
                    padding: const EdgeInsets.only(right: SigapSpacing.sm),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(label),
                      labelStyle: TextStyle(
                        fontSize: SigapTypography.bodySmall,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isSelected
                            ? Colors.white
                            : SigapColors.textPrimary,
                      ),
                      selectedColor: SigapColors.primary,
                      backgroundColor: SigapColors.bgSurface,
                      checkmarkColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(SigapRadius.pill),
                        side: BorderSide(
                          color: isSelected
                              ? SigapColors.primary
                              : SigapColors.border,
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
                ? Padding(
                    padding: const EdgeInsets.all(SigapSpacing.lg),
                    child: ErrorRetryView(message: _error!, onRetry: _load),
                  )
                : _filtered.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(SigapSpacing.lg),
                    child: EmptyState(
                      icon: Icons.people_outline,
                      title: dl10n.tidakAdaAkun,
                      subtitle: _roleFilter == 'all'
                          ? dl10n.belumAdaAkunPenggunaTerdaftar
                          : '${dl10n.tidakAdaPenggunaDenganPeran} "${_roleFilter.toUpperCase()}".',
                      action: OutlinedButton.icon(
                        onPressed: _createUser,
                        icon: const Icon(Icons.add),
                        label: Text(dl10n.tambahAkunBaru),
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
                        final tone = _roleTone(role);

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
                                backgroundColor: SigapColors.primary.withValues(
                                  alpha: 0.12,
                                ),
                                foregroundColor: SigapColors.primary,
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: SigapColors.primary,
                                  ),
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
                                  email,
                                  style: const TextStyle(
                                    fontSize: SigapTypography.bodySmall,
                                    color: SigapColors.textSecondary,
                                  ),
                                ),
                              ),
                              trailing: StatusPill(
                                label: role.toUpperCase(),
                                tone: tone,
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
