import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: SigapColors.primary,
          foregroundColor: SigapColors.surface,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SigapRadius.xl),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(SigapColors.surface),
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: SigapTypography.subtitle,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const SecondaryButton({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: SigapColors.textSecondary,
          padding: const EdgeInsets.symmetric(vertical: 15),
          side: const BorderSide(color: SigapColors.borderCard),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SigapRadius.md),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: SigapTypography.subtitle,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// CTA button matching PantauDesa M-05 Beranda Warga "Buat laporan" spec.
/// Exact specs: 14px radius, glow shadow, 17px vertical padding,
/// icon container 40x40 with 11px radius, two-line label.
class CtaButton extends StatelessWidget {
  final String label;
  final String? subtitle;
  final VoidCallback? onPressed;
  final bool isLoading;

  const CtaButton({
    super.key,
    required this.label,
    this.subtitle,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(boxShadow: SigapShadows.buttonPrimary),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: SigapColors.primary,
          foregroundColor: SigapColors.surface,
          padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SigapRadius.xl),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(SigapColors.surface),
                ),
              )
            : Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: SigapColors.surface.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(SigapRadius.md),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: SigapColors.surface,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            fontSize: SigapTypography.bodyLarge,
                            fontWeight: FontWeight.w700,
                            color: SigapColors.surface,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 1),
                          Text(
                            subtitle!,
                            style: TextStyle(
                              fontSize: SigapTypography.bodySmall,
                              fontWeight: FontWeight.w400,
                              color: SigapColors.surface.withValues(
                                alpha: 0.85,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class DangerButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const DangerButton({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: SigapColors.dangerTextStrong,
          padding: const EdgeInsets.symmetric(vertical: 15),
          side: const BorderSide(color: SigapColors.dangerBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SigapRadius.md),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: SigapTypography.subtitle,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
