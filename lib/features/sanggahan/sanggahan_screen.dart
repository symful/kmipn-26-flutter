import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/generated/app_localizations.dart';
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
        _errorMessage = AppLocalizations.of(
          context,
        )!.alasanMinimalKarakter(_minReasonLength);
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
        _errorMessage = AppLocalizations.of(
          context,
        )!.gagalAjukanSanggahanError(e.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_success) {
      return ResponsiveScaffold(
        appBar: SigapAppBar(title: l10n.sanggahan),
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
                Text(
                  l10n.sanggahanBerhasil,
                  style: TextStyle(
                    fontSize: SigapTypography.headlineMedium,
                    fontWeight: FontWeight.bold,
                    color: SigapColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: SigapSpacing.md),
                Text(
                  l10n.sanggahanBerhasilDesc(widget.reportId),
                  style: const TextStyle(
                    fontSize: SigapTypography.subtitle,
                    color: SigapColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: SigapSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        context.push('/laporan/${widget.reportId}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SigapColors.primary,
                      foregroundColor: SigapColors.surface,
                      padding: const EdgeInsets.symmetric(
                        vertical: SigapSpacing.xl,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(SigapRadius.md),
                      ),
                    ),
                    child: Text(l10n.kembaliKeLaporan),
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

    return ResponsiveScaffold(
      appBar: SigapAppBar(title: l10n.sanggahan),
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
                      Text(
                        l10n.idLaporanLabel,
                        style: TextStyle(
                          fontSize: SigapTypography.bodySmall,
                          color: SigapColors.textMuted,
                        ),
                      ),
                      Text(
                        widget.reportId,
                        style: const TextStyle(
                          fontSize: SigapTypography.bodyMedium,
                          fontWeight: FontWeight.w600,
                          fontFamily: SigapTypography.fontFamilyMono,
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
                      Text(
                        l10n.apaItuSanggahan,
                        style: TextStyle(
                          fontSize: SigapTypography.bodyMedium,
                          fontWeight: FontWeight.w600,
                          color: SigapColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: SigapSpacing.sm),
                  Text(
                    l10n.sanggahanDeskripsiLengkap,
                    style: TextStyle(
                      fontSize: SigapTypography.bodyText,
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
                      Text(
                        l10n.alasanSanggahanLabel,
                        style: TextStyle(
                          fontSize: SigapTypography.bodyMedium,
                          fontWeight: FontWeight.w600,
                          color: SigapColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: SigapSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: SigapSpacing.x6,
                          vertical: SigapSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: SigapColors.danger.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(SigapRadius.x4),
                        ),
                        child: Text(
                          l10n.wajibLabel,
                          style: TextStyle(
                            fontSize: SigapTypography.captionSmall,
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
                      hintText: l10n.jelaskanAlasanSanggahanHint(
                        _minReasonLength,
                      ),
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
                        l10n.karakterMinimum(reasonLength, _minReasonLength),
                        style: TextStyle(
                          fontSize: SigapTypography.bodySmall,
                          color: isValid
                              ? SigapColors.selesai
                              : SigapColors.textMuted,
                        ),
                      ),
                      if (isValid)
                        Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: SigapColors.selesai,
                              size: 16,
                            ),
                            const SizedBox(width: SigapSpacing.x4),
                            Text(
                              l10n.valid,
                              style: const TextStyle(
                                fontSize: SigapTypography.bodySmall,
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
                          fontSize: SigapTypography.bodyText,
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
                  foregroundColor: SigapColors.surface,
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
                            SigapColors.surface,
                          ),
                        ),
                      )
                    : Text(
                        l10n.ajukanSanggahanBtn,
                        style: TextStyle(
                          fontSize: SigapTypography.titleMedium,
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
                child: Text(l10n.batal),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
