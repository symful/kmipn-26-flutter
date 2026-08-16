import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/providers.dart';
import '../../theme/tokens.dart';

enum RwVerdict {
  valid,
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
        return 'Valid — confirm laporan benar';
      case RwVerdict.needsCompletion:
        return 'Perlu Lengkapi — warga harus melengkapi';
      case RwVerdict.needsSurvey:
        return 'Perlu Survei — surveyor perlu turun lapangan';
      case RwVerdict.duplicate:
        return 'Duplikat —merge dengan laporan lain';
      case RwVerdict.outOfScope:
        return 'Diluar Jangkauan — tidak masuk wilayah/wewenang';
      case RwVerdict.rejected:
        return 'Ditolak — laporan tidak valid';
    }
  }

  String get apiValue {
    switch (this) {
      case RwVerdict.valid:
        return 'valid';
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
    return this == RwVerdict.rejected || this == RwVerdict.outOfScope;
  }
}

class RtRwVerifyScreen extends ConsumerStatefulWidget {
  final String token;
  final String reportId;
  const RtRwVerifyScreen({
    super.key,
    required this.token,
    required this.reportId,
  });
  @override
  ConsumerState<RtRwVerifyScreen> createState() => _RtRwVerifyScreenState();
}

class _RtRwVerifyScreenState extends ConsumerState<RtRwVerifyScreen> {
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
    return true;
  }

  Future<void> _submit() async {
    if (!_canSubmit) {
      setState(() {
        _error = _verdict.requiresReason
            ? 'Alasan wajib diisi untuk verdict ini'
            : null;
      });
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Verifikasi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Verdict: ${_verdict.label}'),
            if (_reasonController.text.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Alasan: ${_reasonController.text.trim()}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Konfirmasi'),
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
      final reason = _reasonController.text.trim();

      if (_verdict == RwVerdict.valid ||
          _verdict == RwVerdict.needsCompletion ||
          _verdict == RwVerdict.needsSurvey ||
          _verdict == RwVerdict.outOfScope ||
          _verdict == RwVerdict.rejected) {
        await client.verifikatorDecide(
          caseId: widget.reportId,
          decision: _verdict.apiValue,
          reason: reason.isNotEmpty ? reason : null,
        );
      } else if (_verdict == RwVerdict.duplicate) {
        await client.verifikatorDecide(
          caseId: widget.reportId,
          decision: _verdict.apiValue,
          reason: reason.isNotEmpty ? reason : null,
          duplicateOfReportId: _duplicateIdController.text.trim().isNotEmpty
              ? _duplicateIdController.text.trim()
              : null,
        );
      }

      if (_photoPath != null) {
        await client.rtRwVerify(
          verificationToken: widget.token,
          reportId: widget.reportId,
          verdict: _verdict.apiValue,
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
        appBar: AppBar(title: const Text('Verifikasi RT/RW')),
        body: const Center(
          child: Padding(
            padding: const EdgeInsets.all(SigapSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: SigapColors.selesai, size: 64),
                SizedBox(height: 16),
                Text(
                  'Verifikasi berhasil dikirim',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Verifikasi RT/RW')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SigapColors.textMuted.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Laporan: ${widget.reportId}',
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Pilih Verdict',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            RadioGroup<RwVerdict>(
              groupValue: _verdict,
              onChanged: (val) {
                if (val != null) setState(() => _verdict = val);
              },
              child: Column(
                children: RwVerdict.values
                    .map(
                      (v) => ListTile(
                        leading: Radio<RwVerdict>(value: v),
                        title: Text(
                          v.label,
                          style: const TextStyle(fontSize: 14),
                        ),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        onTap: () => setState(() => _verdict = v),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            if (_verdict == RwVerdict.duplicate) ...[
              TextField(
                controller: _duplicateIdController,
                decoration: const InputDecoration(
                  labelText: 'ID Laporan Duplikat',
                  hintText: 'Masukkan ID laporan yang duplikat',
                ),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(
                labelText: _verdict.requiresReason
                    ? 'Alasan (WAJIB)'
                    : 'Alasan (opsional)',
                hintText: 'Berikan alasan untuk verdict ini',
                errorText:
                    _verdict.requiresReason &&
                        _reasonController.text.isEmpty &&
                        _error != null
                    ? 'Alasan wajib diisi'
                    : null,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            const Text(
              'Bukti Foto (opsional)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => _pickPhoto(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Kamera'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => _pickPhoto(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galeri'),
                ),
              ],
            ),
            if (_photoPath != null) ...[
              const SizedBox(height: 8),
              Chip(
                label: Text(
                  _photoPath!.split('/').last,
                  style: const TextStyle(fontSize: 12),
                ),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => setState(() => _photoPath = null),
              ),
            ],
            const SizedBox(height: 24),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Error: $_error',
                  style: const TextStyle(
                    color: SigapColors.perluTindakan,
                    fontSize: 14,
                  ),
                ),
              ),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                _loading ? 'Mengirim...' : 'Kirim Verifikasi',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
