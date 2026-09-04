import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../providers/auth_provider.dart';
import '../../../theme/tokens.dart';
import '../../../widgets/design_system/design_system.dart';

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
      const redirectPath = '/dashboard';
      context.go(redirectPath);
    } else {
      final error = ref.read(authNotifierProvider).error;
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? l10n.loginGagal),
          backgroundColor: SigapColors.perluTindakan,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: SigapColors.bgScreen,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(SigapSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: SigapSpacing.xl * 2),
                // Logo / Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: SigapColors.primary,
                          borderRadius: BorderRadius.circular(SigapRadius.xl),
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: SigapSpacing.md),
                      const Text(
                        'SIGAP',
                        style: TextStyle(
                          fontSize: SigapTypography.heroText,
                          fontWeight: FontWeight.w800,
                          color: SigapColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: SigapSpacing.xs),
                      Text(
                        l10n.sistemInformasiGeospasial,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: SigapTypography.bodyText,
                          color: SigapColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: SigapSpacing.xl * 2),

                // Title
                Text(
                  l10n.masuk,
                  style: TextStyle(
                    fontSize: SigapTypography.headlineLarge,
                    fontWeight: FontWeight.w700,
                    color: SigapColors.textPrimary,
                  ),
                ),
                const SizedBox(height: SigapSpacing.xs),
                Text(
                  l10n.gunakanAkun,
                  style: TextStyle(
                    fontSize: SigapTypography.bodyText,
                    color: SigapColors.textSecondary,
                  ),
                ),
                const SizedBox(height: SigapSpacing.xl),

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
                          color: SigapColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: SigapSpacing.xs),
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
                const SizedBox(height: SigapSpacing.md),

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
                          color: SigapColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: SigapSpacing.xs),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _handleLogin(),
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          prefixIcon: const Icon(Icons.lock_outline, size: 20),
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
                const SizedBox(height: SigapSpacing.lg),

                // Login button
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SigapColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(SigapRadius.md),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
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
                const SizedBox(height: SigapSpacing.md),

                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${l10n.belumPunyaAkun} ',
                      style: TextStyle(
                        color: SigapColors.textSecondary,
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
                            color: SigapColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: SigapTypography.bodySmallFine,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SigapSpacing.xl),

                // Demo accounts
                Text(
                  l10n.akunDemo,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: SigapTypography.bodySmall,
                    fontWeight: FontWeight.w600,
                    color: SigapColors.textMuted,
                  ),
                ),
                const SizedBox(height: SigapSpacing.sm),
                Wrap(
                  spacing: SigapSpacing.sm,
                  runSpacing: SigapSpacing.sm,
                  alignment: WrapAlignment.center,
                  children: [
                    _DemoAccountChip(
                      label: 'Warga',
                      email: 'warga@sigap.id',
                      password: 'warga123',
                      onTap: _fillDemoCredentials,
                    ),
                    _DemoAccountChip(
                      label: 'Surveyor',
                      email: 'surveyor@sigap.id',
                      password: 'surveyor123',
                      onTap: _fillDemoCredentials,
                    ),
                    _DemoAccountChip(
                      label: 'Petugas',
                      email: 'petugas@sigap.id',
                      password: 'petugas123',
                      onTap: _fillDemoCredentials,
                    ),
                    _DemoAccountChip(
                      label: 'Operator',
                      email: 'operator@sigap.id',
                      password: 'operator123',
                      onTap: _fillDemoCredentials,
                    ),
                    _DemoAccountChip(
                      label: 'Verifikator',
                      email: 'verifikator@sigap.id',
                      password: 'verifikator123',
                      onTap: _fillDemoCredentials,
                    ),
                    _DemoAccountChip(
                      label: 'Admin Daerah',
                      email: 'admin.daerah@sigap.id',
                      password: 'admin123',
                      onTap: _fillDemoCredentials,
                    ),
                    _DemoAccountChip(
                      label: 'Auditor',
                      email: 'auditor@sigap.id',
                      password: 'auditor123',
                      onTap: _fillDemoCredentials,
                    ),
                    _DemoAccountChip(
                      label: 'Eksekutif',
                      email: 'eksekutif@sigap.id',
                      password: 'exec123',
                      onTap: _fillDemoCredentials,
                    ),
                    _DemoAccountChip(
                      label: 'RT/RW',
                      email: 'rtrw@sigap.id',
                      password: 'rtrw123',
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
      color: SigapColors.surface,
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
            border: Border.all(color: SigapColors.border),
            borderRadius: BorderRadius.circular(SigapRadius.sm),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: SigapTypography.bodySmall,
              fontWeight: FontWeight.w500,
              color: SigapColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
