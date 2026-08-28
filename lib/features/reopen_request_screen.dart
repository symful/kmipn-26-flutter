import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../theme/tokens.dart';

class ReopenRequestScreen extends ConsumerStatefulWidget {
  final String reportId;
  const ReopenRequestScreen({super.key, required this.reportId});

  @override
  ConsumerState<ReopenRequestScreen> createState() =>
      _ReopenRequestScreenState();
}

class _ReopenRequestScreenState extends ConsumerState<ReopenRequestScreen> {
  final _reasonController = TextEditingController();
  bool _submitting = false;
  String? _submitError;
  bool _success = false;

  bool get _canSubmit => _reasonController.text.trim().length >= 10;

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() {
      _submitting = true;
      _submitError = null;
    });
    try {
      final client = ref.read(apiClientProvider);
      await client.wargaRequestReopen(
        reportId: widget.reportId,
        reason: _reasonController.text.trim(),
      );
      setState(() => _success = true);
    } catch (e) {
      setState(() => _submitError = e.toString());
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_success) {
      return Scaffold(
        appBar: AppBar(title: const Text('Permintaan Buka Kembali')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(SigapSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: SigapColors.selesai,
                  size: 64,
                ),
                const SizedBox(height: SigapSpacing.lg),
                const Text(
                  'Permintaan berhasil diajukan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: SigapSpacing.sm),
                Text(
                  'Tim verifikator akan meninjau permintaan Anda.',
                  style: TextStyle(
                    color: SigapColors.textSecondary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: SigapSpacing.xl),
                ElevatedButton(
                  onPressed: () => context.go('/'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SigapColors.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: SigapSpacing.xl,
                      vertical: SigapSpacing.md,
                    ),
                  ),
                  child: const Text('Kembali ke Beranda'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Buka Kembali Laporan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(SigapSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(SigapSpacing.md),
              decoration: BoxDecoration(
                color: SigapColors.diproses.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(SigapRadius.md),
                border: Border.all(color: SigapColors.diproses.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: SigapColors.diproses, size: 20),
                  const SizedBox(width: SigapSpacing.sm),
                  Expanded(
                    child: Text(
                      'Anda dapat meminta pembukaan kembali laporan yang sudah ditutup jika ada informasi atau bukti tambahan.',
                      style: TextStyle(color: SigapColors.diproses, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SigapSpacing.xl),
            Text(
              'Alasan Permintaan',
              style: TextStyle(
                color: SigapColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: SigapSpacing.sm),
            TextField(
              controller: _reasonController,
              maxLines: 6,
              maxLength: 1000,
              decoration: InputDecoration(
                hintText: 'Jelaskan alasan permintaan pembukaan kembali...',
                hintStyle: TextStyle(color: SigapColors.textMuted),
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: SigapColors.primary),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: SigapSpacing.sm),
            Text(
              'Minimal 10 karakter',
              style: TextStyle(color: SigapColors.textMuted, fontSize: 12),
            ),
            if (_submitError != null) ...[
              const SizedBox(height: SigapSpacing.md),
              Container(
                padding: const EdgeInsets.all(SigapSpacing.md),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(SigapRadius.sm),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 18),
                    const SizedBox(width: SigapSpacing.sm),
                    Expanded(
                      child: Text(
                        _submitError!,
                        style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: SigapSpacing.xl),
            ElevatedButton(
              onPressed: _canSubmit && !_submitting ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: SigapColors.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: SigapSpacing.md),
                disabledBackgroundColor: SigapColors.border,
              ),
              child: _submitting
                  ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onPrimary)))
                  : const Text(
                      'Ajukan Permintaan',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
