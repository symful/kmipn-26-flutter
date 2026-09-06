import 'package:sigap/theme/sigap_color_scheme.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sigap/widgets/request_error_details.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sigap/l10n/generated/app_localizations.dart';
import 'package:sigap/providers/providers.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/utils/platform_helper.dart';
import 'package:sigap/widgets/design_system/responsive_scaffold.dart';
import 'package:sigap/widgets/design_system/sigap_app_bar.dart';

/// Evidence submission screen for adding photos/evidence to an existing case.
///
/// Triggered from SimilarCasesBanner when user chooses "Tambahkan bukti ke kasus ini"
/// or from review_kiriman_screen after submitting evidence to a duplicate case.
///
/// Flow:
/// 1. User captures/selects a photo
/// 2. User optionally adds a description
/// 3. Photo is uploaded via presigned URL
/// 4. Evidence is submitted via reportAction('lengkapi')
class ReportEvidenceScreen extends ConsumerStatefulWidget {
  final String caseId;

  const ReportEvidenceScreen({super.key, required this.caseId});

  @override
  ConsumerState<ReportEvidenceScreen> createState() =>
      _ReportEvidenceScreenState();
}

class _ReportEvidenceScreenState extends ConsumerState<ReportEvidenceScreen> {
  final _descriptionController = TextEditingController();
  final _imagePicker = ImagePicker();
  File? _selectedPhoto;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final photo = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (photo != null) {
        setState(() {
          _selectedPhoto = File(photo.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      showRequestFailure(context, e);
    }
  }

  void _showPhotoSourceDialog() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text(l10n.kamera),
              onTap: () {
                Navigator.pop(context);
                _pickPhoto(cameraSource());
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text(l10n.galeri),
              onTap: () {
                Navigator.pop(context);
                _pickPhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitEvidence() async {
    if (_selectedPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.silakanTambahFotoDahulu),
          backgroundColor: SigapColors.warning,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final client = ref.read(apiClientProvider);

      // Send the selected bytes and description through the authenticated endpoint.
      await client.addReportEvidence(
        widget.caseId,
        _selectedPhoto!.path,
        description: _descriptionController.text.trim(),
      );

      if (!mounted) return;

      // Show success and pop
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.buktiDitambahkanKeKasus),
          backgroundColor: SigapColors.primary,
        ),
      );

      context.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      showRequestFailure(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ResponsiveScaffold(
      appBar: SigapAppBar(title: l10n.fotoBukti),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(SigapSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              l10n.tambahkanBukti,
              style: TextStyle(
                fontSize: SigapTypography.titleLarge,
                color: SigapColorScheme.of(context).textPrimary,
              ),
            ),
            const SizedBox(height: SigapSpacing.xs),
            Text(
              l10n.tambahkanFotoDeskripsi,
              style: TextStyle(
                fontSize: SigapTypography.bodyMedium,
                color: SigapColorScheme.of(context).textSecondary,
              ),
            ),
            const SizedBox(height: SigapSpacing.xxl),

            // Photo section
            _buildPhotoSection(l10n),
            const SizedBox(height: SigapSpacing.xl),

            // Description field
            _buildDescriptionField(l10n),
            const SizedBox(height: SigapSpacing.xxl),

            // Submit button
            _buildSubmitButton(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.fotoBukti,
          style: TextStyle(
            fontSize: SigapTypography.titleMedium,
            color: SigapColorScheme.of(context).textPrimary,
          ),
        ),
        const SizedBox(height: SigapSpacing.sm),
        if (_selectedPhoto != null)
          _buildPhotoPreview()
        else
          _buildPhotoPicker(l10n),
      ],
    );
  }

  Widget _buildPhotoPreview() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(SigapRadius.md),
          child: Image.file(
            _selectedPhoto!,
            width: double.infinity,
            height: 250,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => setState(() => _selectedPhoto = null),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(SigapRadius.pill),
              ),
              child: Icon(
                Icons.close,
                color: SigapColorScheme.of(context).surface,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoPicker(AppLocalizations l10n) {
    return GestureDetector(
      onTap: _showPhotoSourceDialog,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: SigapColorScheme.of(context).surface,
          borderRadius: BorderRadius.circular(SigapRadius.md),
          border: Border.all(
            color: SigapColorScheme.of(context).border,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt,
              size: 48,
              color: SigapColorScheme.of(context).textMuted,
            ),
            const SizedBox(height: SigapSpacing.sm),
            Text(
              l10n.tapUntukBukaKamera,
              style: TextStyle(
                fontSize: SigapTypography.bodyMedium,
                color: SigapColorScheme.of(context).textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionField(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.deskripsiOpsional,
          style: TextStyle(
            fontSize: SigapTypography.titleMedium,
            color: SigapColorScheme.of(context).textPrimary,
          ),
        ),
        const SizedBox(height: SigapSpacing.sm),
        TextField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: l10n.jelaskanAlasanKeberatan,
            hintStyle: TextStyle(
              fontSize: SigapTypography.bodyMedium,
              color: SigapColorScheme.of(context).textMuted,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SigapRadius.md),
              borderSide: BorderSide(
                color: SigapColorScheme.of(context).border,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SigapRadius.md),
              borderSide: BorderSide(
                color: SigapColorScheme.of(context).border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SigapRadius.md),
              borderSide: BorderSide(color: SigapColors.primary, width: 2),
            ),
            filled: true,
            fillColor: SigapColorScheme.of(context).surface,
            contentPadding: const EdgeInsets.all(SigapSpacing.md),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitEvidence,
        style: ElevatedButton.styleFrom(
          backgroundColor: SigapColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: SigapSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SigapRadius.md),
          ),
          disabledBackgroundColor: SigapColorScheme.of(context).textMuted,
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                l10n.lengkapiLaporanLabel,
                style: TextStyle(
                  fontSize: SigapTypography.titleMedium,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
