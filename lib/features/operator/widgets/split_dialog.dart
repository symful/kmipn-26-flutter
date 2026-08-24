import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/strings.dart';
import '../../../providers/providers.dart';
import '../../../theme/tokens.dart';

class OperatorSplitDialog extends ConsumerStatefulWidget {
  final String caseId;
  const OperatorSplitDialog({super.key, required this.caseId});

  @override
  ConsumerState<OperatorSplitDialog> createState() =>
      _OperatorSplitDialogState();
}

class _OperatorSplitDialogState extends ConsumerState<OperatorSplitDialog> {
  final _reasonController = TextEditingController();
  final _targetUnitIdController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (_reasonController.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      final client = ref.read(apiClientProvider);
      await client.separateReports(
        id: widget.caseId,
        reportIdsToSeparate: [widget.caseId],
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
    _targetUnitIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pisahkan Kasus'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Alasan Pemisahan (WAJIB)',
                hintText: Strings.alasanPemisahan,
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: SigapSpacing.md),
            TextField(
              controller: _targetUnitIdController,
              decoration: const InputDecoration(
                labelText: 'ID Unit Target (opsional)',
                hintText: 'Masukkan ID unit jika ingin langsung ditugaskan',
                border: OutlineInputBorder(),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: SigapSpacing.md),
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
          onPressed: _reasonController.text.trim().isEmpty || _loading
              ? null
              : _submit,
          child: _loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Pisahkan'),
        ),
      ],
    );
  }
}
