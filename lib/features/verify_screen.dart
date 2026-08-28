import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../api/api_client.dart';
import '../../l10n/strings.dart';
import '../../providers/providers.dart';
import '../../theme/tokens.dart';

enum RwVerdict {
  valid,
  confirmed,
  needsCompletion,
  needsSurvey,
  duplicate,
  outOfScope,
  rejected,
}

extension RwVerdictExtension on RwVerdict {
  String get label {
    switch (this) {
      case RwVerdict.valid:
        return 'Valid — Konfirmasi Laporan Benar';
      case RwVerdict.confirmed:
        return 'Confirmed — Laporan Dikonfirmasi RT/RW';
      case RwVerdict.needsCompletion:
        return 'Perlu Lengkapi — Data Warga Belum Lengkap';
      case RwVerdict.needsSurvey:
        return 'Perlu Survei — Perlu Cek Fisik Lapangan';
      case RwVerdict.duplicate:
        return 'Duplikat — Sama dengan Laporan Lain';
      case RwVerdict.outOfScope:
        return 'Di Luar Wilayah — Bukan Wewenang RT/RW';
      case RwVerdict.rejected:
        return 'Ditolak — Laporan Palsu / Tidak Valid';
    }
  }

  String get description {
    switch (this) {
      case RwVerdict.valid:
        return 'Laporan telah diperiksa dan kondisinya sesuai kenyataan di lingkungan.';
      case RwVerdict.confirmed:
        return 'RT/RW telah meninjau dan mengkonfirmasi laporan ini.';
      case RwVerdict.needsCompletion:
        return 'Warga perlu melengkapi bukti foto, keterangan, atau titik lokasi yang jelas.';
      case RwVerdict.needsSurvey:
        return 'Petugas survei lapangan perlu meninjau langsung tingkat kerusakan teknis.';
      case RwVerdict.duplicate:
        return 'Pengaduan serupa untuk masalah ini sudah pernah dilaporkan sebelumnya.';
      case RwVerdict.outOfScope:
        return 'Lokasi masalah berada di luar wilayah RT/RW atau wewenang lingkungan ini.';
      case RwVerdict.rejected:
        return 'Laporan tidak dapat diproses karena tidak relevan, hoax, atau melanggar.';
    }
  }

  IconData get icon {
    switch (this) {
      case RwVerdict.valid:
        return Icons.check_circle_outline;
      case RwVerdict.confirmed:
        return Icons.verified_outlined;
      case RwVerdict.needsCompletion:
        return Icons.edit_note;
      case RwVerdict.needsSurvey:
        return Icons.travel_explore;
      case RwVerdict.duplicate:
        return Icons.copy_outlined;
      case RwVerdict.outOfScope:
        return Icons.wrong_location_outlined;
      case RwVerdict.rejected:
        return Icons.cancel_outlined;
    }
  }

  Color get color {
    switch (this) {
      case RwVerdict.valid:
        return SigapColors.selesai;
      case RwVerdict.confirmed:
        return SigapColors.selesai;
      case RwVerdict.needsCompletion:
        return SigapColors.diproses;
      case RwVerdict.needsSurvey:
        return SigapColors.primary;
      case RwVerdict.duplicate:
        return SigapColors.warning;
      case RwVerdict.outOfScope:
        return SigapColors.textSecondary;
      case RwVerdict.rejected:
        return SigapColors.perluTindakan;
    }
  }

  String get apiValue {
    switch (this) {
      case RwVerdict.valid:
        return 'valid';
      case RwVerdict.confirmed:
        return 'confirmed';
      case RwVerdict.needsCompletion:
        return 'needs_completion';
      case RwVerdict.needsSurvey:
        return 'needs_survey';
      case RwVerdict.duplicate:
        return 'duplicate';
      case RwVerdict.outOfScope:
        return 'out_of_scope';
      case RwVerdict.rejected:
        return 'rejected';
    }
  }

  bool get requiresReason {
    return this == RwVerdict.rejected ||
        this == RwVerdict.outOfScope ||
        this == RwVerdict.needsCompletion;
  }
}

class VerifyScreen extends ConsumerStatefulWidget {
  final String token;
  final String reportId;
  const VerifyScreen({super.key, required this.token, required this.reportId});
  @override
  ConsumerState<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends ConsumerState<VerifyScreen> {
  RwVerdict _verdict = RwVerdict.valid;
  final _reasonController = TextEditingController();
  final _duplicateIdController = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _success = false;
  String? _photoPath;

  Future<void> _pickPhoto(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, maxWidth: 1200);
    if (picked != null) {
      setState(() => _photoPath = picked.path);
    }
  }

  bool get _canSubmit {
    if (_verdict.requiresReason && _reasonController.text.trim().isEmpty) {
      return false;
    }
    if (_verdict == RwVerdict.duplicate &&
        _duplicateIdController.text.trim().isEmpty) {
      return false;
    }
    return true;
  }

  Future<void> _submit() async {
    if (!_canSubmit) {
      setState(() {
        if (_verdict.requiresReason && _reasonController.text.trim().isEmpty) {
          _error = 'Alasan verifikasi wajib diisi untuk pilihan ini';
        } else if (_verdict == RwVerdict.duplicate &&
            _duplicateIdController.text.trim().isEmpty) {
          _error = 'ID Laporan Duplikat wajib diisi';
        }
      });
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SigapRadius.lg),
        ),
        backgroundColor: SigapColors.surface,
        title: const Row(
          children: [
            Icon(Icons.verified_user, color: SigapColors.primary),
            SizedBox(width: SigapSpacing.sm),
            Text(
              'Konfirmasi Verifikasi',
              style: TextStyle(
                fontSize: SigapTypography.size16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pastikan keputusan verifikasi di bawah ini sudah sesuai:',
              style: TextStyle(fontSize: SigapTypography.size13),
            ),
            const SizedBox(height: SigapSpacing.md),
            Container(
              padding: const EdgeInsets.all(SigapSpacing.md),
              decoration: BoxDecoration(
                color: _verdict.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(SigapRadius.md),
                border: Border.all(
                  color: _verdict.color.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(_verdict.icon, color: _verdict.color, size: 20),
                      const SizedBox(width: SigapSpacing.sm),
                      Expanded(
                        child: Text(
                          _verdict.label,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _verdict.color,
                            fontSize: SigapTypography.size13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_reasonController.text.trim().isNotEmpty) ...[
                    const SizedBox(height: SigapSpacing.sm),
                    Text(
                      'Catatan: "${_reasonController.text.trim()}"',
                      style: const TextStyle(
                        fontSize: SigapTypography.size12,
                        color: SigapColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              Strings.batal,
              style: TextStyle(color: SigapColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: SigapColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SigapRadius.sm),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(Strings.konfirmasi),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final client = ref.read(apiClientProvider);
      final activeRole = ref.read(authNotifierProvider).activeRole ?? '';
      final reason = _reasonController.text.trim();

      if (_verdict == RwVerdict.valid ||
          _verdict == RwVerdict.confirmed ||
          _verdict == RwVerdict.needsCompletion ||
          _verdict == RwVerdict.needsSurvey ||
          _verdict == RwVerdict.outOfScope ||
          _verdict == RwVerdict.rejected) {
        await client.decideVerifikatorCase(
          activeRole: activeRole,
          caseId: widget.reportId,
          decision: _verdict.apiValue,
          reason: reason.isNotEmpty ? reason : '',
        );
      } else if (_verdict == RwVerdict.duplicate) {
        await client.decideVerifikatorCase(
          activeRole: activeRole,
          caseId: widget.reportId,
          decision: _verdict.apiValue,
          reason: reason.isNotEmpty ? reason : '',
          duplicateOfReportId: _duplicateIdController.text.trim().isNotEmpty
              ? _duplicateIdController.text.trim()
              : null,
        );
      }

      if (_photoPath != null) {
        await client.rtRwVerify(
          verificationToken: widget.token,
          reportId: widget.reportId,
          verdict: RtRwVerdict.fromString(_verdict.apiValue)!,
          reason: reason.isNotEmpty ? reason : null,
          photoPath: _photoPath,
        );
      }

      setState(() => _success = true);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _duplicateIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_success) {
      return Scaffold(
        backgroundColor: SigapColors.bgScreen,
        appBar: AppBar(title: const Text('Verifikasi RT/RW')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(SigapSpacing.xl),
            child: Container(
              padding: const EdgeInsets.all(SigapSpacing.xl),
              decoration: BoxDecoration(
                color: SigapColors.surface,
                borderRadius: BorderRadius.circular(SigapRadius.lg),
                border: Border.all(color: SigapColors.border),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(SigapSpacing.lg),
                    decoration: const BoxDecoration(
                      color: SigapColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: SigapColors.primary,
                      size: 64,
                    ),
                  ),
                  const SizedBox(height: SigapSpacing.lg),
                  const Text(
                    'Verifikasi Berhasil Dikirim',
                    style: TextStyle(
                      fontSize: SigapTypography.size18,
                      fontWeight: FontWeight.bold,
                      color: SigapColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: SigapSpacing.sm),
                  Text(
                    'Hasil verifikasi untuk laporan ${widget.reportId} telah dicatat oleh sistem SIGAP.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: SigapTypography.size13,
                      color: SigapColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: SigapSpacing.xl),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SigapColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: SigapSpacing.xl,
                        vertical: SigapSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(SigapRadius.md),
                      ),
                    ),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/');
                      }
                    },
                    child: const Text('Selesai'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: SigapColors.bgScreen,
      appBar: AppBar(title: const Text('Verifikasi RT/RW')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(SigapSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Report info header
            Container(
              padding: const EdgeInsets.all(SigapSpacing.md),
              decoration: BoxDecoration(
                color: SigapColors.primaryLight.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(SigapRadius.md),
                border: Border.all(
                  color: SigapColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.assignment_turned_in,
                    color: SigapColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: SigapSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Verifikasi Pengurus Lingkungan RT/RW',
                          style: TextStyle(
                            fontSize: SigapTypography.size12,
                            fontWeight: FontWeight.bold,
                            color: SigapColors.primary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'ID Laporan: ${widget.reportId}',
                          style: const TextStyle(
                            fontSize: SigapTypography.size13,
                            fontFamily: 'monospace',
                            color: SigapColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SigapSpacing.lg),

            // Section title: Verdict
            const Text(
              'Pilih Keputusan / Verdict',
              style: TextStyle(
                fontSize: SigapTypography.size15,
                fontWeight: FontWeight.bold,
                color: SigapColors.textPrimary,
              ),
            ),
            const SizedBox(height: SigapSpacing.xs),
            const Text(
              'Pilihlah status verifikasi yang paling akurat sesuai temuan nyata di lingkungan Anda.',
              style: TextStyle(
                fontSize: SigapTypography.size12,
                color: SigapColors.textSecondary,
              ),
            ),
            const SizedBox(height: SigapSpacing.md),

            // Selectable Verdict Cards
            ...RwVerdict.values.map((v) {
              final isSelected = _verdict == v;
              return Padding(
                padding: const EdgeInsets.only(bottom: SigapSpacing.sm),
                child: InkWell(
                  onTap: () => setState(() => _verdict = v),
                  borderRadius: BorderRadius.circular(SigapRadius.md),
                  child: Container(
                    padding: const EdgeInsets.all(SigapSpacing.md),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? v.color.withValues(alpha: 0.08)
                          : SigapColors.surface,
                      borderRadius: BorderRadius.circular(SigapRadius.md),
                      border: Border.all(
                        color: isSelected ? v.color : SigapColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: isSelected ? v.color : SigapColors.textMuted,
                          size: 20,
                        ),
                        const SizedBox(width: SigapSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(v.icon, size: 16, color: v.color),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      v.label,
                                      style: TextStyle(
                                        fontSize: SigapTypography.size13,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? v.color
                                            : SigapColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                v.description,
                                style: const TextStyle(
                                  fontSize: SigapTypography.size11,
                                  color: SigapColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: SigapSpacing.md),

            // Duplicate report ID field
            if (_verdict == RwVerdict.duplicate) ...[
              TextField(
                controller: _duplicateIdController,
                decoration: InputDecoration(
                  labelText: 'ID Laporan Duplikat (Wajib)',
                  hintText: 'Contoh: REP-2026-0042',
                  prefixIcon: const Icon(Icons.copy, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SigapRadius.md),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: SigapSpacing.md,
                    vertical: SigapSpacing.sm,
                  ),
                ),
              ),
              const SizedBox(height: SigapSpacing.md),
            ],

            // Reason / Notes TextField
            TextField(
              controller: _reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: _verdict.requiresReason
                    ? 'Alasan / Penjelasan (Wajib)'
                    : 'Alasan / Catatan Tambahan (Opsional)',
                hintText:
                    'Tuliskan catatan verifikasi lapangan untuk petugas daerah...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SigapRadius.md),
                ),
                contentPadding: const EdgeInsets.all(SigapSpacing.md),
              ),
            ),
            const SizedBox(height: SigapSpacing.lg),

            // Photo Attachment Section
            const Text(
              'Bukti Foto Pendukung (Opsional)',
              style: TextStyle(
                fontSize: SigapTypography.size15,
                fontWeight: FontWeight.bold,
                color: SigapColors.textPrimary,
              ),
            ),
            const SizedBox(height: SigapSpacing.xs),
            const Text(
              'Lampirkan foto kondisi terkini jika Anda berada di lokasi pengaduan.',
              style: TextStyle(
                fontSize: SigapTypography.size12,
                color: SigapColors.textSecondary,
              ),
            ),
            const SizedBox(height: SigapSpacing.sm),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: SigapSpacing.sm,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(SigapRadius.md),
                      ),
                    ),
                    onPressed: () => _pickPhoto(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt, size: 20),
                    label: const Text('Ambil Foto'),
                  ),
                ),
                const SizedBox(width: SigapSpacing.md),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: SigapSpacing.sm,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(SigapRadius.md),
                      ),
                    ),
                    onPressed: () => _pickPhoto(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library, size: 20),
                    label: const Text('Pilih Galeri'),
                  ),
                ),
              ],
            ),

            if (_photoPath != null) ...[
              const SizedBox(height: SigapSpacing.md),
              Container(
                padding: const EdgeInsets.all(SigapSpacing.sm),
                decoration: BoxDecoration(
                  color: SigapColors.surface,
                  borderRadius: BorderRadius.circular(SigapRadius.md),
                  border: Border.all(color: SigapColors.border),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(SigapRadius.sm),
                      child: Image.file(
                        File(_photoPath!),
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.image,
                          size: 48,
                          color: SigapColors.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(width: SigapSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Foto Terlampir',
                            style: TextStyle(
                              fontSize: SigapTypography.size13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _photoPath!.split(RegExp(r'[\\/]')).last,
                            style: const TextStyle(
                              fontSize: SigapTypography.size11,
                              color: SigapColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: SigapColors.perluTindakan,
                      ),
                      tooltip: 'Hapus foto',
                      onPressed: () => setState(() => _photoPath = null),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: SigapSpacing.lg),

            if (_error != null)
              Container(
                margin: const EdgeInsets.only(bottom: SigapSpacing.md),
                padding: const EdgeInsets.all(SigapSpacing.md),
                decoration: BoxDecoration(
                  color: SigapColors.perluTindakan.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(SigapRadius.md),
                  border: Border.all(
                    color: SigapColors.perluTindakan.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: SigapColors.perluTindakan,
                      size: 20,
                    ),
                    const SizedBox(width: SigapSpacing.sm),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(
                          color: SigapColors.perluTindakan,
                          fontSize: SigapTypography.size12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            ElevatedButton(
              onPressed: _loading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: SigapColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: SigapSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SigapRadius.md),
                ),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      Strings.kirimVerifikasi,
                      style: TextStyle(
                        fontSize: SigapTypography.size14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
