import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/client.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../providers/providers.dart';
import '../../../theme/tokens.dart';

class OperatorAssignDialog extends ConsumerStatefulWidget {
  final String caseId;
  const OperatorAssignDialog({super.key, required this.caseId});

  @override
  ConsumerState<OperatorAssignDialog> createState() =>
      _OperatorAssignDialogState();
}

class _OperatorAssignDialogState extends ConsumerState<OperatorAssignDialog> {
  final _instructionsController = TextEditingController();
  DateTime? _deadline;
  bool _loading = false;
  bool _loadingUnits = false;
  String? _error;
  String? _selectedUnitId;
  List<Unit> _units = [];

  @override
  void initState() {
    super.initState();
    _loadUnits();
  }

  Future<void> _loadUnits() async {
    setState(() => _loadingUnits = true);
    try {
      final client = ref.read(apiClientProvider);
      final result = await client.getUnits(limit: 100);
      setState(() {
        _units = result.entries;
        _loadingUnits = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loadingUnits = false;
      });
    }
  }

  Future<void> _submit() async {
    if (_selectedUnitId == null) return;
    setState(() => _loading = true);
    try {
      final client = ref.read(apiClientProvider);
      await client.caseAction(
        caseId: widget.caseId,
        action: 'assign',
        unitId: _selectedUnitId,
      );
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.assignKasus),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Pilih unit yang akan menangani kasus ini.',
              style: TextStyle(
                fontSize: SigapTypography.bodySmall,
                color: SigapColors.textSecondary,
              ),
            ),
            const SizedBox(height: SigapSpacing.md),
            if (_loadingUnits)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_units.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'Tidak ada unit aktif.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: SigapColors.textMuted,
                    fontSize: SigapTypography.bodySmall,
                  ),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 240),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _units.map((unit) {
                      return RadioListTile<String>(
                        value: unit.id ?? '',
                        groupValue: _selectedUnitId,
                        onChanged: (val) =>
                            setState(() => _selectedUnitId = val),
                        title: Text(
                          unit.name ?? unit.id ?? '-',
                          style: TextStyle(
                            fontSize: SigapTypography.bodyText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        activeColor: SigapColors.primary,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: SigapSpacing.sm,
                        ),
                        dense: true,
                      );
                    }).toList(),
                  ),
                ),
              ),
            const SizedBox(height: SigapSpacing.md),
            TextField(
              controller: _instructionsController,
              decoration: InputDecoration(
                labelText: l10n.labelInstruksiOpsional,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: SigapSpacing.md),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                _deadline == null
                    ? 'Batas Waktu: (belum dipilih)'
                    : 'Batas Waktu: ${_deadline!.toLocal().toString().split(' ')[0]}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate:
                      _deadline ?? DateTime.now().add(const Duration(days: 7)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() => _deadline = picked);
                }
              },
            ),
            if (_error != null) ...[
              const SizedBox(height: SigapSpacing.sm),
              Text(
                'Error: $_error',
                style: const TextStyle(
                  color: SigapColors.perluTindakan,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: Text(l10n.batal),
        ),
        ElevatedButton(
          onPressed: _selectedUnitId == null || _loading || _loadingUnits
              ? null
              : _submit,
          child: _loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.assign),
        ),
      ],
    );
  }
}
