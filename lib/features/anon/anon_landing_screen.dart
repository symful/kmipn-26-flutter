import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/tokens.dart';

/// Landing screen for anonymous report submission.
/// Shows "Lapor Tanpa Akun" heading with a button to navigate to /create-anonymous.
class AnonLandingScreen extends StatelessWidget {
  const AnonLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      appBar: AppBar(
        title: const Text('Lapor Tanpa Akun'),
        backgroundColor: AppColors.bgCard,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.announcement,
                  size: 50,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Title
              const Text(
                'Lapor Tanpa Akun',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              // Description
              const Text(
                'Laporkan masalah di lingkungan Anda tanpa perlu membuat akun. '
                'Laporan Anda akan tetap diproses oleh petugas terkait.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              // CTA Button
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () => context.push('/create-anonymous'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Buat Laporan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const Spacer(),
              // Info text
              const Text(
                'Tidak memiliki akun? Tidak masalah.\n'
                'Anda tetap bisa melaporkan masalah di sekitar Anda.',
                style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
