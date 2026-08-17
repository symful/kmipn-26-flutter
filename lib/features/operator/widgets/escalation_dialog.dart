import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/strings.dart';
import '../../../providers/providers.dart';
import '../../../theme/tokens.dart';

class OperatorEscalationDialog extends ConsumerStatefulWidget {
  final String caseId;
  const OperatorEscalationDialog({super.key, required this.caseId});

  @override
  ConsumerState<OperatorEscalationDialog> createState() =>
      _OperatorEscalationDialogState();
}

class _OperatorEscalationDialogState
    extends ConsumerState<OperatorEscalationDialog> {
  final _reasonController = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _confirmed = false;

  Future<void> _submit() async {
    if (_reasonController.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      final client = ref.read(apiClientProvider);
      await client.escalateOperatorCase(
        caseId: widget.caseId,
        reason: _reasonController.text.trim(),
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
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.arrow_upward, color: SigapColors.perluTindakan),
          const SizedBox(width: 8),
          const Text('Eskalasi Kasus'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(SigapSpacing.md),
              decoration: BoxDecoration(
                color: SigapColors.perluTindakan.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(SigapRadius.sm),
                border: Border.all(
                  color: SigapColors.perluTindakan.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: SigapColors.perluTindakan,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Eskalasi akan meneruskan kasus ke level yang lebih tinggi.',
                      style: TextStyle(
                        fontSize: 12,
                        color: SigapColors.perluTindakan,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SigapSpacing.md),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Alasan Eskalsi (WAJIB)',
                hintText: 'Jelaskan alasan eskalasi',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: SigapSpacing.md),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _confirmed,
              onChanged: (v) => setState(() => _confirmed = v ?? false),
              title: const Text(
                'Saya yakin ingin mengeskalasi kasus ini',
                style: TextStyle(fontSize: 13),
              ),
              controlAffinity: ListTileControlAffinity.leading,
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
          child: const Text(Strings.batal),
        ),
        ElevatedButton(
          onPressed:
              _reasonController.text.trim().isEmpty || !_confirmed || _loading
              ? null
              : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: SigapColors.perluTindakan,
            foregroundColor: Colors.white,
          ),
          child: _loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Eskalasi'),
        ),
      ],
    );
  }
}
