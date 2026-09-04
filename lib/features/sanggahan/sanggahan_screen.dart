import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../theme/tokens.dart';
import '../../utils/logger.dart';
import '../../widgets/design_system/design_system.dart';

/// Sanggahan screen for warga to formally object to a rejected report.
///
/// This screen is accessible at `/sanggahan/:reportId` and allows warga
/// to submit a formal objection (sanggahan) with a reason and optional photo evidence.
class SanggahanScreen extends ConsumerStatefulWidget {
  final String reportId;

  const SanggahanScreen({super.key, required this.reportId});

  @override
  ConsumerState<SanggahanScreen> createState() => _SanggahanScreenState();
}

class _SanggahanScreenState extends ConsumerState<SanggahanScreen> {
  static final _logger = Logger('SanggahanScreen');

  final _reasonController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;
  bool _success = false;

  static const int _minReasonLength = 30;

  bool get _isReasonValid =>
      _reasonController.text.trim().length >= _minReasonLength;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_isReasonValid) {
      setState(() {
        _errorMessage = 'Alasan harus minimal $_minReasonLength karakter';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final client = ref.read(apiClientProvider);

      // Call reportAction with sanggah action
      await client.reportAction(
        reportId: widget.reportId,
        action: 'sanggah',
        note: _reasonController.text.trim(),
      );

      if (!mounted) return;

      setState(() => _success = true);
    } catch (e) {
      _logger.warning('Error submitting sanggahan', e);
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Gagal mengajukan sanggahan: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_success) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Sanggahan'),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(SigapSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: SigapColors.selesai,
                  size: 80,
                ),
                const SizedBox(height: SigapSpacing.lg),
                const Text(
                  'Sanggahan Berhasil Diajukan',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: SigapColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: SigapSpacing.md),
                Text(
                  'Sanggahan Anda untuk laporan ${widget.reportId} telah berhasil submitted dan akan ditinjau oleh tim terkait.',
                  style: const TextStyle(
                    fontSize: 15,
                    color: SigapColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: SigapSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go('/laporan/${widget.reportId}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SigapColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(SigapRadius.md),
                      ),
                    ),
                    child: const Text('Kembali ke Laporan'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final reasonLength = _reasonController.text.trim().length;
    final isValid = _isReasonValid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajukan Sanggahan'),
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(SigapSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Report ID Card
            Container(
              padding: const EdgeInsets.all(SigapSpacing.md),
              decoration: BoxDecoration(
                color: SigapColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(SigapRadius.md),
                border: Border.all(color: SigapColors.border),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.description_outlined,
                    color: SigapColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: SigapSpacing.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ID Laporan',
                        style: TextStyle(
                          fontSize: 12,
                          color: SigapColors.textMuted,
                        ),
                      ),
                      Text(
                        widget.reportId,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                          color: SigapColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: SigapSpacing.lg),

            // Description Card
            SigapCard(
              padding: const EdgeInsets.all(SigapSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: SigapColors.info,
                        size: 20,
                      ),
                      const SizedBox(width: SigapSpacing.sm),
                      const Text(
                        'Apa itu Sanggahan?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: SigapColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: SigapSpacing.sm),
                  const Text(
                    'Sanggahan adalah cara Anda untuk mengajukan keberatan terhadap keputusan yang telah diambil terhadap laporan Anda. '
                    'Jika Anda merasa laporan Anda ditolak atau diputuskan secara tidak adil, Anda dapat mengajukan '
                    'sanggahan formal yang akan ditinjau oleh tim verifier.',
                    style: TextStyle(
                      fontSize: 13,
                      color: SigapColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SigapSpacing.lg),

            // Reason Input Card
            SigapCard(
              padding: const EdgeInsets.all(SigapSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.edit_note,
                        color: SigapColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: SigapSpacing.sm),
                      const Text(
                        'Alasan Sanggahan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: SigapColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: SigapSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: SigapColors.danger.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'WAJIB',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: SigapColors.danger,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: SigapSpacing.md),
                  TextField(
                    controller: _reasonController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText:
                          'Jelaskan alasan sanggahan Anda secara detail...\n\nMinimal $_minReasonLength karakter.',
                      hintStyle: TextStyle(color: SigapColors.textMuted),
                      border: const OutlineInputBorder(),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: SigapColors.primary),
                      ),
                      contentPadding: const EdgeInsets.all(SigapSpacing.md),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: SigapSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$reasonLength / $_minReasonLength karakter minimum',
                        style: TextStyle(
                          fontSize: 12,
                          color: isValid
                              ? SigapColors.selesai
                              : SigapColors.textMuted,
                        ),
                      ),
                      if (isValid)
                        const Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: SigapColors.selesai,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Valid',
                              style: TextStyle(
                                fontSize: 12,
                                color: SigapColors.selesai,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: SigapSpacing.lg),

            // Error message
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(SigapSpacing.md),
                decoration: BoxDecoration(
                  color: SigapColors.dangerBg,
                  borderRadius: BorderRadius.circular(SigapRadius.md),
                  border: Border.all(color: SigapColors.dangerBorder),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: SigapColors.danger,
                      size: 20,
                    ),
                    const SizedBox(width: SigapSpacing.sm),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: SigapColors.dangerTextStrong,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SigapSpacing.lg),
            ],

            // Submit Button
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: isValid && !_isSubmitting ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SigapColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: SigapColors.border,
                  disabledForegroundColor: SigapColors.textMuted,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SigapRadius.md),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Ajukan Sanggahan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: SigapSpacing.md),

            // Cancel Button
            SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: _isSubmitting ? null : () => context.pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: SigapColors.textSecondary,
                  side: const BorderSide(color: SigapColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SigapRadius.md),
                  ),
                ),
                child: const Text('Batal'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
