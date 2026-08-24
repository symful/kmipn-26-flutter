import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/strings.dart';
import '../../../providers/providers.dart';
import '../../../theme/tokens.dart';

class OperatorPriorityDialog extends ConsumerStatefulWidget {
  final String caseId;
  const OperatorPriorityDialog({super.key, required this.caseId});

  @override
  ConsumerState<OperatorPriorityDialog> createState() =>
      _OperatorPriorityDialogState();
}

class _OperatorPriorityDialogState
    extends ConsumerState<OperatorPriorityDialog> {
  double _priority = 50;
  final _reasonController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      final client = ref.read(apiClientProvider);
      await client.setReportPriority(
        id: widget.caseId,
        score: _priority.round(),
        reason: _reasonController.text.trim().isNotEmpty
            ? _reasonController.text.trim()
            : 'Prioritas diubah',
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

  Color get _priorityColor {
    if (_priority >= 70) return SigapColors.perluTindakan;
    if (_priority >= 40) return Colors.orange;
    return SigapColors.selesai;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Atur Prioritas'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text('Skor Prioritas: '),
                Text(
                  '${_priority.round()}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _priorityColor,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: SigapSpacing.sm),
            Slider(
              value: _priority,
              min: 0,
              max: 100,
              divisions: 20,
              label: _priority.round().toString(),
              onChanged: (v) => setState(() => _priority = v),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rendah',
                  style: TextStyle(fontSize: 11, color: SigapColors.selesai),
                ),
                Text(
                  'Tinggi',
                  style: TextStyle(
                    fontSize: 11,
                    color: SigapColors.perluTindakan,
                  ),
                ),
              ],
            ),
            const SizedBox(height: SigapSpacing.md),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Alasan perubahan',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
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
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text(Strings.simpan),
        ),
      ],
    );
  }
}
