import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/onboarding_provider.dart';
import '../../theme/tokens.dart';

/// Onboarding screen with 3-step PageView for permission requests.
/// Steps: Location → Camera → Notifications
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _skipAndComplete() async {
    await ref.read(onboardingNotifierProvider.notifier).completeOnboarding();
    if (mounted) {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: SigapColors.bgSurface,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button at top right
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _skipAndComplete,
                child: Text(
                  l10n.lewatI,
                  style: const TextStyle(
                    color: SigapColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            // PageView for 3 steps
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _PermissionStep(
                    icon: Icons.location_on,
                    title: l10n.aksesLokasi,
                    body: l10n.aksesLokasiBody,
                    permission: Permission.location,
                    stepIndex: 0,
                  ),
                  _PermissionStep(
                    icon: Icons.camera_alt,
                    title: l10n.aksesKamera,
                    body: l10n.aksesKameraBody,
                    permission: Permission.camera,
                    stepIndex: 1,
                  ),
                  _PermissionStep(
                    icon: Icons.notifications,
                    title: l10n.notifikasi,
                    body: l10n.notifikasiBody,
                    permission: Permission.notification,
                    stepIndex: 2,
                  ),
                ],
              ),
            ),
            // Page indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: SigapSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? SigapColors.primary
                          : SigapColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionStep extends ConsumerWidget {
  final IconData icon;
  final String title;
  final String body;
  final Permission permission;
  final int stepIndex;

  const _PermissionStep({
    required this.icon,
    required this.title,
    required this.body,
    required this.permission,
    required this.stepIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SigapSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: SigapColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 60, color: SigapColors.primary),
          ),
          const SizedBox(height: SigapSpacing.xxl),
          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: SigapColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SigapSpacing.md),
          // Body
          Text(
            body,
            style: const TextStyle(
              fontSize: 14,
              color: SigapColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SigapSpacing.xxl),
          // Action button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => _requestPermission(context, ref),
              style: ElevatedButton.styleFrom(
                backgroundColor: SigapColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SigapRadius.md),
                ),
                elevation: 0,
              ),
              child: Text(
                l10n.izinkan,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _requestPermission(BuildContext context, WidgetRef ref) async {
    // Capture the page controller before the async call
    final pageController = _findPageController(context);

    final status = await permission.request();

    if (status.isGranted || status.isLimited) {
      // Permission granted, proceed to next step or complete
      if (stepIndex < 2) {
        // Use the captured page controller
        if (pageController != null) {
          pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      } else {
        // Last step - complete onboarding
        await ref
            .read(onboardingNotifierProvider.notifier)
            .completeOnboarding();
        if (context.mounted) {
          context.go('/dashboard');
        }
      }
    } else if (status.isPermanentlyDenied) {
      // Show dialog to open settings
      if (context.mounted) {
        _showSettingsDialog(context);
      }
    }
    // If denied but not permanently, just stay on the page
  }

  PageController? _findPageController(BuildContext context) {
    // Find the page controller from the parent PageView
    // This is a workaround since we're inside the PageView
    final pageView = context.findAncestorWidgetOfExactType<PageView>();
    return pageView?.controller;
  }

  void _showSettingsDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.izinDiperlukan),
        content: Text(l10n.izinDiperlukanPesan(title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.batal),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text(l10n.bukaPengaturan),
          ),
        ],
      ),
    );
  }
}
