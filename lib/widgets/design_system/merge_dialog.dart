import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../providers/providers.dart';
import '../../../theme/tokens.dart';

class OperatorMergeDialog extends ConsumerStatefulWidget {
  final String caseId;
  const OperatorMergeDialog({super.key, required this.caseId});

  @override
  ConsumerState<OperatorMergeDialog> createState() =>
      _OperatorMergeDialogState();
}

class _OperatorMergeDialogState extends ConsumerState<OperatorMergeDialog> {
  final _targetIdController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (_targetIdController.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      final client = ref.read(apiClientProvider);
      await client.caseAction(
        caseId: widget.caseId,
        action: 'merge',
        intoCaseId: _targetIdController.text.trim(),
        note: _reasonController.text.trim().isNotEmpty
            ? _reasonController.text.trim()
            : null,
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
    _targetIdController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.mergeKasus),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _targetIdController,
              decoration: InputDecoration(
                labelText: l10n.labelIdKasusTarget,
                hintText: l10n.alasanMerge,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: SigapSpacing.md),
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(
                labelText: l10n.labelAlasanOpsional,
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            if (_error != null) ...[
              const SizedBox(height: SigapSpacing.md),
              Text(
                l10n.errorGeneric(_error ?? ""),
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
          onPressed: _targetIdController.text.trim().isEmpty || _loading
              ? null
              : _submit,
          child: _loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.merge),
        ),
      ],
    );
  }
}
