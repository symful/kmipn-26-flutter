import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final _unitController = TextEditingController();
  final _instructionsController = TextEditingController();
  DateTime? _deadline;
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (_unitController.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      final client = ref.read(apiClientProvider);
      await client.post(
        '/api/operator/cases/${widget.caseId}/assign',
        data: {
          'unit_id': _unitController.text.trim(),
          if (_instructionsController.text.trim().isNotEmpty)
            'instructions': _instructionsController.text.trim(),
          if (_deadline != null)
            'deadline': _deadline!.toIso8601String().split('T').first,
        },
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
    _unitController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Assign Kasus'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _unitController,
              decoration: const InputDecoration(
                labelText: 'ID Unit (WAJIB)',
                hintText: 'Masukkan ID unit tugas',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: SigapSpacing.md),
            TextField(
              controller: _instructionsController,
              decoration: const InputDecoration(
                labelText: 'Instruksi (opsional)',
                border: OutlineInputBorder(),
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
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _unitController.text.trim().isEmpty || _loading
              ? null
              : _submit,
          child: _loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Assign'),
        ),
      ],
    );
  }
}
