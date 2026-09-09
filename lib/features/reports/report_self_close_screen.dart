import 'package:sigap/theme/sigap_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:sigap/widgets/request_error_details.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sigap/l10n/generated/app_localizations.dart';
import 'package:sigap/providers/providers.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/utils/logger.dart';
import 'package:sigap/widgets/design_system/design_system.dart';

/// Self-close screen for warga to mark their own report as done.
///
/// This screen is accessible at `/tutup/:reportId` and allows warga
/// to close a report they created, cancelling active field tasks.
class ReportSelfCloseScreen extends ConsumerStatefulWidget {
  final String reportId;

  const ReportSelfCloseScreen({super.key, required this.reportId});

  @override
  ConsumerState<ReportSelfCloseScreen> createState() =>
      _ReportSelfCloseScreenState();
}

class _ReportSelfCloseScreenState extends ConsumerState<ReportSelfCloseScreen> {
  static final _logger = Logger('ReportSelfCloseScreen');

  final _reasonController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;
  bool _success = false;

  static const int _minReasonLength = 10;

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
        )!.selfCloseReasonTooShort(_minReasonLength);
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final client = ref.read(apiClientProvider);

      await client.reportAction(
        reportId: widget.reportId,
        action: 'self_close',
        note: _reasonController.text.trim(),
      );

      if (!mounted) return;

      setState(() => _success = true);
    } catch (e) {
      _logger.warning('Error submitting self-close', e);
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = null;
      });
      showRequestFailure(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_success) {
      return ResponsiveScaffold(
        appBar: SigapAppBar(title: l10n.selfCloseTitle),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(SigapSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: SigapColors.selesai, size: 80),
                const SizedBox(height: SigapSpacing.lg),
                Text(
                  l10n.selfCloseSuccessTitle,
                  style: TextStyle(
                    fontSize: SigapTypography.headlineMedium,
                    fontWeight: FontWeight.bold,
                    color: SigapColorScheme.of(context).textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: SigapSpacing.md),
                Text(
                  l10n.selfCloseSuccessBody,
                  style: TextStyle(
                    fontSize: SigapTypography.subtitle,
                    color: SigapColorScheme.of(context).textSecondary,
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
                      foregroundColor: Colors.white,
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
      appBar: SigapAppBar(title: l10n.selfCloseTitle),
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
                border: Border.all(color: SigapColorScheme.of(context).border),
              ),
              child: Row(
                children: [
                  Icon(
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
                          color: SigapColorScheme.of(context).textMuted,
                        ),
                      ),
                      Text(
                        widget.reportId,
                        style: TextStyle(
                          fontSize: SigapTypography.bodyMedium,
                          fontWeight: FontWeight.w600,
                          fontFamily: SigapTypography.fontFamilyMono,
                          color: SigapColorScheme.of(context).textPrimary,
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
                      Icon(
                        Icons.info_outline,
                        color: SigapColors.info,
                        size: 20,
                      ),
                      const SizedBox(width: SigapSpacing.sm),
                      Expanded(
                        child: Text(
                          l10n.selfCloseTitle,
                          style: TextStyle(
                            fontSize: SigapTypography.bodyMedium,
                            fontWeight: FontWeight.w600,
                            color: SigapColorScheme.of(context).textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: SigapSpacing.sm),
                  Text(
                    l10n.selfCloseDescription,
                    style: TextStyle(
                      fontSize: SigapTypography.bodyText,
                      color: SigapColorScheme.of(context).textSecondary,
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
                      Icon(
                        Icons.edit_note,
                        color: SigapColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: SigapSpacing.sm),
                      Expanded(
                        child: Text(
                          l10n.selfCloseReasonLabel,
                          style: TextStyle(
                            fontSize: SigapTypography.bodyMedium,
                            fontWeight: FontWeight.w600,
                            color: SigapColorScheme.of(context).textPrimary,
                          ),
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
                      hintText: l10n.selfCloseReasonHint,
                      hintStyle: TextStyle(
                        color: SigapColorScheme.of(context).textMuted,
                      ),
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
                      Expanded(
                        child: Text(
                          l10n.karakterMinimum(reasonLength, _minReasonLength),
                          style: TextStyle(
                            fontSize: SigapTypography.bodySmall,
                            color: isValid
                                ? SigapColors.selesai
                                : SigapColorScheme.of(context).textMuted,
                          ),
                        ),
                      ),
                      if (isValid)
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: SigapColors.selesai,
                              size: 16,
                            ),
                            const SizedBox(width: SigapSpacing.x4),
                            Text(
                              l10n.valid,
                              style: TextStyle(
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
                    Icon(
                      Icons.error_outline,
                      color: SigapColors.danger,
                      size: 20,
                    ),
                    const SizedBox(width: SigapSpacing.sm),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
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
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: SigapColorScheme.of(context).border,
                  disabledForegroundColor: SigapColorScheme.of(
                    context,
                  ).textMuted,
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
                    : Text(
                        l10n.selfCloseSubmit,
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
                  foregroundColor: SigapColorScheme.of(context).textSecondary,
                  side: BorderSide(color: SigapColorScheme.of(context).border),
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
