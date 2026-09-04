import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import '../../theme/tokens.dart';

/// Provider that checks if RT/RW training has been completed.
/// Reads the rt_rw_training_complete flag from FlutterSecureStorage.
final rtRwTrainingCompleteProvider = FutureProvider<bool>((ref) async {
  const storage = FlutterSecureStorage();
  final value = await storage.read(key: 'rt_rw_training_complete');
  return value == 'true';
});

/// Notifier for managing RT/RW training state.
class RtRwTrainingNotifier extends StateNotifier<bool> {
  RtRwTrainingNotifier() : super(false);

  Future<void> completeTraining() async {
    const storage = FlutterSecureStorage();
    await storage.write(key: 'rt_rw_training_complete', value: 'true');
    state = true;
  }

  Future<void> resetTraining() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'rt_rw_training_complete');
    state = false;
  }
}

final rtRwTrainingNotifierProvider =
    StateNotifierProvider<RtRwTrainingNotifier, bool>((ref) {
      return RtRwTrainingNotifier();
    });

/// RT/RW Training Screen - mirrors web RtRwTraining.tsx
/// Shows training materials for RT/RW users including:
/// - What is SIGAP
/// - How to verify reports
/// - Understanding the dashboard
/// - Best practices
/// - FAQ
class RtRwTrainingScreen extends ConsumerStatefulWidget {
  const RtRwTrainingScreen({super.key});

  @override
  ConsumerState<RtRwTrainingScreen> createState() => _RtRwTrainingScreenState();
}

class _RtRwTrainingScreenState extends ConsumerState<RtRwTrainingScreen> {
  bool _trainingCompleted = false;

  @override
  void initState() {
    super.initState();
    _checkTrainingStatus();
  }

  Future<void> _checkTrainingStatus() async {
    const storage = FlutterSecureStorage();
    final value = await storage.read(key: 'rt_rw_training_complete');
    if (mounted) {
      setState(() {
        _trainingCompleted = value == 'true';
      });
    }
  }

  Future<void> _markTrainingComplete() async {
    const storage = FlutterSecureStorage();
    await storage.write(key: 'rt_rw_training_complete', value: 'true');
    if (mounted) {
      setState(() {
        _trainingCompleted = true;
      });
      ref.read(rtRwTrainingNotifierProvider.notifier).completeTraining();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SigapColors.bgScreen,
      appBar: AppBar(
        title: const Text('Pelatihan RT/RW'),
        backgroundColor: SigapColors.surface,
        foregroundColor: SigapColors.textPrimary,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => context.go('/rt-rw/training'),
            child: const Text(
              'Verifikasi Laporan',
              style: TextStyle(
                color: SigapColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(SigapSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Pelatihan SIGAP untuk RT/RW',
              style: TextStyle(
                fontSize: SigapTypography.heroText,
                fontWeight: FontWeight.bold,
                color: SigapColors.textPrimary,
                letterSpacing: SigapTypography.letterSpacingTight,
              ),
            ),
            const SizedBox(height: SigapSpacing.sm),
            const Text(
              'Panduan lengkap untuk pejabat RT dan RW dalam menggunakan sistem SIGAP',
              style: TextStyle(
                fontSize: SigapTypography.bodyMedium,
                color: SigapColors.textSecondary,
                height: SigapTypography.lineHeight145,
              ),
            ),
            const SizedBox(height: SigapSpacing.xl),

            // Section 1: What is SIGAP
            _SectionTitle(number: '1', title: 'Apa itu SIGAP?'),
            const SizedBox(height: SigapSpacing.md),
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SIGAP (Sistem Informasi Geospasial & Penanganan Laporan Desa) adalah '
                    'platform digital untuk pemetaan dan pemantauan pembangunan desa. '
                    'Sistem ini membantu mencatat, melacak, dan menyelesaikan laporan '
                    'kerusakan infrastruktur di lingkungan Anda.',
                    style: TextStyle(
                      fontSize: SigapTypography.bodyMedium,
                      color: SigapColors.textSecondary,
                      height: SigapTypography.lineHeight150,
                    ),
                  ),
                  const SizedBox(height: SigapSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          title: 'Tujuan SIGAP',
                          items: const [
                            'Memetakan kerusakan infrastruktur',
                            'Mempercepat proses perbaikan',
                            'Transparansi laporan masyarakat',
                            'Koordinasi antar tingkat pemerintah',
                          ],
                        ),
                      ),
                      const SizedBox(width: SigapSpacing.md),
                      Expanded(
                        child: _InfoCard(
                          title: 'Peran RT/RW',
                          items: const [
                            'Memverifikasi laporan kerusakan',
                            'Memberikan konfirmasi di lapangan',
                            'Melaporkan kerusakan baru',
                            'Memantau status perbaikan',
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: SigapSpacing.xl),

            // Section 2: How to Verify
            _SectionTitle(number: '2', title: 'Cara Memverifikasi Laporan'),
            const SizedBox(height: SigapSpacing.md),
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sebagai RT/RW, tugas utama Anda adalah memverifikasi laporan kerusakan '
                    'yang masuk ke sistem. Berikut langkah-langkahnya:',
                    style: TextStyle(
                      fontSize: SigapTypography.bodyMedium,
                      color: SigapColors.textSecondary,
                      height: SigapTypography.lineHeight150,
                    ),
                  ),
                  const SizedBox(height: SigapSpacing.lg),
                  _StepCard(
                    number: 1,
                    title: 'Terima Tautan Verifikasi',
                    description:
                        'Anda akan menerima tautan verifikasi melalui SMS atau WhatsApp dari sistem SIGAP. Tautan berisi token unik untuk mengakses laporan.',
                  ),
                  _StepCard(
                    number: 2,
                    title: 'Buka Tautan',
                    description:
                        'Klik tautan yang dikirimkan. Anda akan diarahkan ke halaman verifikasi SIGAP.',
                  ),
                  _StepCard(
                    number: 3,
                    title: 'Periksa Kondisi di Lapangan',
                    description:
                        'Kunjungi lokasi yang disebutkan dalam laporan. Periksa apakah kerusakan benar-benar ada dan catat kondisi sebenarnya.',
                  ),
                  _StepCard(
                    number: 4,
                    title: 'Berikan Keputusan',
                    description:
                        'Pilih \'Dikonfirmasi\' jika kerusakan benar ada, atau \'Ditolak\' jika laporan tidak valid. Berikan alasan yang jelas.',
                  ),
                  _StepCard(
                    number: 5,
                    title: 'Kirim Verifikasi',
                    description:
                        'Klik tombol \'Kirim Verifikasi\' untuk mengirimkan keputusan Anda ke sistem.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: SigapSpacing.xl),

            // Section 3: Dashboard
            _SectionTitle(number: '3', title: 'Memahami Dashboard SIGAP'),
            const SizedBox(height: SigapSpacing.md),
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dashboard SIGAP menampilkan semua laporan kerusakan yang masuk. '
                    'Berikut elemen-elemen utama yang perlu Anda ketahui:',
                    style: TextStyle(
                      fontSize: SigapTypography.bodyMedium,
                      color: SigapColors.textSecondary,
                      height: SigapTypography.lineHeight150,
                    ),
                  ),
                  const SizedBox(height: SigapSpacing.lg),
                  _StatusLegendCard(),
                  const SizedBox(height: SigapSpacing.md),
                  _ReportInfoCard(),
                ],
              ),
            ),
            const SizedBox(height: SigapSpacing.xl),

            // Section 4: Best Practices
            _SectionTitle(number: '4', title: 'Best Practice'),
            const SizedBox(height: SigapSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _BestPracticeCard(
                    title: 'Lakukan',
                    icon: Icons.check_circle,
                    color: SigapColors.success,
                    bgColor: SigapColors.primaryLight,
                    borderColor: SigapColors.successBorder,
                    items: const [
                      'Verifikasi laporan dalam 1x24 jam',
                      'Datang langsung ke lokasi',
                      'Berikan alasan yang detail',
                      'Dokumentasikan dengan foto',
                      'Laporkan jika ada kendala',
                    ],
                  ),
                ),
                const SizedBox(width: SigapSpacing.md),
                Expanded(
                  child: _BestPracticeCard(
                    title: 'Hindari',
                    icon: Icons.cancel,
                    color: SigapColors.danger,
                    bgColor: SigapColors.dangerBg,
                    borderColor: SigapColors.dangerBorder,
                    items: const [
                      'Memverifikasi tanpa ke lokasi',
                      'Memberikan alasan kosong',
                      'Menunda verifikasi terlalu lama',
                      'Menolak tanpa alasan jelas',
                      'Mengabaikan laporan masyarakat',
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: SigapSpacing.xl),

            // Section 5: FAQ
            _SectionTitle(number: '5', title: 'Pertanyaan Umum'),
            const SizedBox(height: SigapSpacing.md),
            _Card(
              child: Column(
                children: const [
                  _FaqItem(
                    question: 'Bagaimana jika lokasi sulit diakses?',
                    answer:
                        'Coba verifikasi dari titik terdekat yang memungkinkan. Jika benar-benar tidak bisa diakses, berikan alasan di sistem dan minta bantuan tetangga atau warga sekitar untuk dokumentasi.',
                  ),
                  _FaqItem(
                    question:
                        'Apa yang harus dilakukan jika laporan tidak jelas?',
                    answer:
                        'Hubungi pelapor melalui nomor yang tertera untuk meminta klarifikasi. Jika tidak bisa dihubungi, verifikasi berdasarkan informasi yang ada dan catat ketidakjelasan tersebut.',
                  ),
                  _FaqItem(
                    question: 'Berapa lama waktu verifikasi?',
                    answer:
                        'Idealnya, verifikasi dilakukan dalam 1x24 jam setelah laporan masuk. Namun, jika ada kendala, segera hubungi admin daerah.',
                  ),
                  _FaqItem(
                    question:
                        'Bagaimana jika saya tidak setuju dengan keputusan petugas?',
                    answer:
                        'Setiap keputusan sudah tercatat dalam sistem. Jika ada keberatan, silakan hubungi admin daerah atau sampaikan melalui fitur komentar yang tersedia.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: SigapSpacing.xl),

            // CTA Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(SigapSpacing.xl),
              decoration: BoxDecoration(
                color: SigapColors.primary,
                borderRadius: BorderRadius.circular(SigapRadius.lg),
              ),
              child: Column(
                children: [
                  const Text(
                    'Siap Memulai?',
                    style: TextStyle(
                      fontSize: SigapTypography.headlineMedium,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: SigapSpacing.sm),
                  const Text(
                    'Akses menu Verifikasi Laporan untuk memproses laporan kerusakan dari masyarakat.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: SigapTypography.bodyMedium,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: SigapSpacing.lg),
                  if (_trainingCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SigapSpacing.lg,
                        vertical: SigapSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(SigapRadius.md),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, color: SigapColors.success),
                          SizedBox(width: SigapSpacing.sm),
                          Text(
                            'Pelatihan Selesai',
                            style: TextStyle(
                              color: SigapColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ElevatedButton(
                      onPressed: () {
                        _markTrainingComplete();
                        context.go('/rt-rw/training');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: SigapColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: SigapSpacing.xl,
                          vertical: SigapSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(SigapRadius.md),
                        ),
                      ),
                      child: const Text(
                        'Verifikasi Laporan',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: SigapSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String number;
  final String title;

  const _SectionTitle({required this.number, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      '$number. $title',
      style: const TextStyle(
        fontSize: SigapTypography.headlineSmall,
        fontWeight: FontWeight.bold,
        color: SigapColors.textPrimary,
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SigapSpacing.lg),
      decoration: BoxDecoration(
        color: SigapColors.surface,
        borderRadius: BorderRadius.circular(SigapRadius.lg),
        border: Border.all(color: SigapColors.border),
      ),
      child: child,
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<String> items;

  const _InfoCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SigapSpacing.md),
      decoration: BoxDecoration(
        color: SigapColors.bgSoft,
        borderRadius: BorderRadius.circular(SigapRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: SigapTypography.bodyText,
              fontWeight: FontWeight.w600,
              color: SigapColors.textPrimary,
            ),
          ),
          const SizedBox(height: SigapSpacing.sm),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: SigapSpacing.xs),
              child: Text(
                '• $item',
                style: const TextStyle(
                  fontSize: SigapTypography.bodySmall,
                  color: SigapColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final int number;
  final String title;
  final String description;

  const _StepCard({
    required this.number,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SigapSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: SigapColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: SigapTypography.bodyMedium,
                ),
              ),
            ),
          ),
          const SizedBox(width: SigapSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: SigapTypography.bodyMedium,
                    fontWeight: FontWeight.w600,
                    color: SigapColors.textPrimary,
                  ),
                ),
                const SizedBox(height: SigapSpacing.xs),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: SigapTypography.bodyText,
                    color: SigapColors.textSecondary,
                    height: SigapTypography.lineHeight140,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusLegendCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SigapSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: SigapColors.border),
        borderRadius: BorderRadius.circular(SigapRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Status Laporan',
            style: TextStyle(
              fontSize: SigapTypography.bodyText,
              fontWeight: FontWeight.w600,
              color: SigapColors.primary,
            ),
          ),
          const SizedBox(height: SigapSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _StatusItem(
                  color: SigapColors.perluTindakan,
                  label: 'Perlu Tindakan',
                  sublabel: 'Laporan baru',
                ),
              ),
              Expanded(
                child: _StatusItem(
                  color: SigapColors.diproses,
                  label: 'Sedang Diproses',
                  sublabel: 'Dalam penanganan',
                ),
              ),
              Expanded(
                child: _StatusItem(
                  color: SigapColors.selesai,
                  label: 'Selesai',
                  sublabel: 'Sudah diperbaiki',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  final Color color;
  final String label;
  final String sublabel;

  const _StatusItem({
    required this.color,
    required this.label,
    required this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: SigapSpacing.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: SigapTypography.captionMedium,
                  fontWeight: FontWeight.w500,
                  color: SigapColors.textPrimary,
                ),
              ),
              Text(
                sublabel,
                style: const TextStyle(
                  fontSize: SigapTypography.captionSmall,
                  color: SigapColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReportInfoCard extends StatelessWidget {
  const _ReportInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SigapSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: SigapColors.border),
        borderRadius: BorderRadius.circular(SigapRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Informasi Laporan',
            style: TextStyle(
              fontSize: SigapTypography.bodyText,
              fontWeight: FontWeight.w600,
              color: SigapColors.primary,
            ),
          ),
          SizedBox(height: SigapSpacing.sm),
          _InfoRow(
            label: 'Kategori:',
            value: 'Jenis kerusakan (jalan, drainase, jembatan, dll)',
          ),
          _InfoRow(
            label: 'Deskripsi:',
            value: 'Penjelasan detail dari pelapor',
          ),
          _InfoRow(label: 'Foto:', value: 'Bukti foto kerusakan dari pelapor'),
          _InfoRow(label: 'Koordinat:', value: 'Lokasi tepat di peta'),
          _InfoRow(label: 'Tanggal:', value: 'Kapan laporan dibuat'),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SigapSpacing.xs),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: SigapTypography.bodySmall,
            color: SigapColors.textSecondary,
          ),
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class _BestPracticeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final Color borderColor;
  final List<String> items;

  const _BestPracticeCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.borderColor,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SigapSpacing.md),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(SigapRadius.md),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: SigapSpacing.sm),
              Text(
                title,
                style: TextStyle(
                  fontSize: SigapTypography.bodyText,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: SigapSpacing.sm),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: SigapSpacing.xs),
              child: Text(
                '• $item',
                style: TextStyle(
                  fontSize: SigapTypography.bodySmall,
                  color: color.withValues(alpha: 0.8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: SigapSpacing.md),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: SigapColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: SigapTypography.bodyMedium,
              fontWeight: FontWeight.w600,
              color: SigapColors.textPrimary,
            ),
          ),
          const SizedBox(height: SigapSpacing.xs),
          Text(
            answer,
            style: const TextStyle(
              fontSize: SigapTypography.bodyText,
              color: SigapColors.textSecondary,
              height: SigapTypography.lineHeight140,
            ),
          ),
        ],
      ),
    );
  }
}
