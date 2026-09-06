import 'package:sigap/theme/sigap_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sigap/l10n/generated/app_localizations.dart';
import 'package:sigap/providers/providers.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/widgets/design_system/design_system.dart';

/// Login screen using the unified REST API client.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final authNotifier = ref.read(authNotifierProvider.notifier);
    final success = await authNotifier.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      // Invalidate all data providers so they refetch with new auth state
      ref.invalidate(wargaReportsProvider);
      ref.invalidate(wargaStatsProvider);
      ref.invalidate(localReportsProvider);
      ref.invalidate(notificationsProvider);
      ref.invalidate(unreadCountProvider);
      ref.invalidate(categoriesProvider);

      if (!mounted) return;
      const redirectPath = '/dashboard';
      context.go(redirectPath);
    } else {
      final error = ref.read(authNotifierProvider).error;
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? l10n.loginGagal),
          backgroundColor: SigapColorScheme.of(context).perluTindakan,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ResponsiveScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(SigapSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: SigapSpacing.xl * 2),
                // Logo / Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: SigapColorScheme.of(context).primary,
                          borderRadius: BorderRadius.circular(SigapRadius.xl),
                        ),
                        child: Icon(
                          Icons.location_on,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 40,
                        ),
                      ),
                      SizedBox(height: SigapSpacing.md),
                      Text(
                        'SIGAP',
                        style: TextStyle(
                          fontSize: SigapTypography.heroText,
                          fontWeight: FontWeight.w800,
                          color: SigapColorScheme.of(context).textPrimary,
                        ),
                      ),
                      SizedBox(height: SigapSpacing.xs),
                      Text(
                        l10n.sistemInformasiGeospasial,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: SigapTypography.bodyText,
                          color: SigapColorScheme.of(context).textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: SigapSpacing.xl * 2),

                // Title
                Text(
                  l10n.masuk,
                  style: TextStyle(
                    fontSize: SigapTypography.headlineLarge,
                    fontWeight: FontWeight.w700,
                    color: SigapColorScheme.of(context).textPrimary,
                  ),
                ),
                SizedBox(height: SigapSpacing.xs),
                Text(
                  l10n.gunakanAkun,
                  style: TextStyle(
                    fontSize: SigapTypography.bodyText,
                    color: SigapColorScheme.of(context).textSecondary,
                  ),
                ),
                SizedBox(height: SigapSpacing.xl),

                // Email field
                SigapCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.emailLabel,
                        style: TextStyle(
                          fontSize: SigapTypography.bodySmall,
                          fontWeight: FontWeight.w600,
                          color: SigapColorScheme.of(context).textSecondary,
                        ),
                      ),
                      SizedBox(height: SigapSpacing.xs),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          hintText: l10n.emailHint,
                          prefixIcon: Icon(Icons.email_outlined, size: 20),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: SigapSpacing.md,
                            vertical: SigapSpacing.sm,
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return l10n.emailKosong;
                          }
                          if (!v.contains('@')) {
                            return l10n.emailTidakValid;
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: SigapSpacing.md),

                // Password field
                SigapCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.kataSandi,
                        style: TextStyle(
                          fontSize: SigapTypography.bodySmall,
                          fontWeight: FontWeight.w600,
                          color: SigapColorScheme.of(context).textSecondary,
                        ),
                      ),
                      SizedBox(height: SigapSpacing.xs),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _handleLogin(),
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          prefixIcon: Icon(Icons.lock_outline, size: 20),
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: SigapSpacing.md,
                            vertical: SigapSpacing.sm,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(
                                () => _obscurePassword = !_obscurePassword,
                              );
                            },
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return l10n.kataSandiKosong;
                          }
                          if (v.length < 6) {
                            return l10n.kataSandiMinimal6;
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: SigapSpacing.lg),

                // Login button
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SigapColorScheme.of(context).primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(SigapRadius.md),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          )
                        : Text(
                            l10n.masuk,
                            style: TextStyle(
                              fontSize: SigapTypography.headlineSmall,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: SigapSpacing.md),

                // Register link
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      '${l10n.belumPunyaAkun} ',
                      style: TextStyle(
                        color: SigapColorScheme.of(context).textSecondary,
                        fontSize: SigapTypography.bodyText,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/register'),
                      child: MinTapTarget(
                        semanticsLabel: l10n.daftar,
                        child: Text(
                          l10n.daftar,
                          style: TextStyle(
                            color: SigapColorScheme.of(context).primary,
                            fontWeight: FontWeight.w600,
                            fontSize: SigapTypography.bodySmallFine,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: SigapSpacing.xl),

                // Demo accounts
                Text(
                  l10n.akunDemo,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: SigapTypography.bodySmall,
                    fontWeight: FontWeight.w600,
                    color: SigapColorScheme.of(context).textMuted,
                  ),
                ),
                SizedBox(height: SigapSpacing.sm),
                Wrap(
                  spacing: SigapSpacing.sm,
                  runSpacing: SigapSpacing.sm,
                  alignment: WrapAlignment.center,
                  children: [
                    _DemoAccountChip(
                      label: l10n.wargaRole,
                      email: 'warga@sigap.live',
                      password: 'warga123',
                      onTap: _fillDemoCredentials,
                    ),
                    _DemoAccountChip(
                      label: l10n.petugasRole,
                      email: 'petugas@sigap.live',
                      password: 'petugas123',
                      onTap: _fillDemoCredentials,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _fillDemoCredentials(String email, String password) {
    setState(() {
      _emailController.text = email;
      _passwordController.text = password;
    });
  }
}

class _DemoAccountChip extends StatelessWidget {
  final String label;
  final String email;
  final String password;
  final void Function(String email, String password) onTap;

  const _DemoAccountChip({
    required this.label,
    required this.email,
    required this.password,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SigapColorScheme.of(context).surface,
      borderRadius: BorderRadius.circular(SigapRadius.sm),
      child: InkWell(
        onTap: () => onTap(email, password),
        borderRadius: BorderRadius.circular(SigapRadius.sm),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: SigapSpacing.md,
            vertical: SigapSpacing.xs,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: SigapColorScheme.of(context).border),
            borderRadius: BorderRadius.circular(SigapRadius.sm),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: SigapTypography.bodySmall,
              fontWeight: FontWeight.w500,
              color: SigapColorScheme.of(context).textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
