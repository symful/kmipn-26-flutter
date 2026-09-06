import 'package:sigap/theme/sigap_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sigap/api/exceptions.dart' show ApiException;
import 'package:sigap/l10n/generated/app_localizations.dart';
import 'package:sigap/providers/providers.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/widgets/design_system/design_system.dart';

/// Registration screen using the unified REST API client.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final client = ref.read(publicApiClientProvider);
      await client.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      // Auto-login after successful registration
      final authNotifier = ref.read(authNotifierProvider.notifier);
      final loginSuccess = await authNotifier.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (loginSuccess && mounted) {
        context.go('/dashboard');
      } else if (mounted) {
        context.go('/login');
      }
    } on ApiException catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        setState(() => _errorMessage = e.userMessage ?? l10n.registrasiGagal);
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        setState(() => _errorMessage = l10n.tidakDapatTerhubung);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ResponsiveScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(SigapSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.daftarAkun,
                  style: TextStyle(
                    fontSize: SigapTypography.headlineLarge,
                    fontWeight: FontWeight.w700,
                    color: SigapColorScheme.of(context).textPrimary,
                  ),
                ),
                SizedBox(height: SigapSpacing.xs),
                Text(
                  l10n.buatAkunBaru,
                  style: TextStyle(
                    fontSize: SigapTypography.bodyText,
                    color: SigapColorScheme.of(context).textSecondary,
                  ),
                ),
                SizedBox(height: SigapSpacing.xl),

                // Error message
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(SigapSpacing.md),
                    decoration: BoxDecoration(
                      color: SigapColorScheme.of(
                        context,
                      ).perluTindakan.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(SigapRadius.md),
                      border: Border.all(
                        color: SigapColorScheme.of(context).perluTindakan,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: SigapColorScheme.of(context).perluTindakan,
                          size: 20,
                        ),
                        SizedBox(width: SigapSpacing.sm),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: SigapColorScheme.of(context).perluTindakan,
                              fontSize: SigapTypography.bodyText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: SigapSpacing.md),
                ],

                // Name field
                SigapCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.namaLengkap,
                        style: TextStyle(
                          fontSize: SigapTypography.bodySmall,
                          fontWeight: FontWeight.w600,
                          color: SigapColorScheme.of(context).textSecondary,
                        ),
                      ),
                      SizedBox(height: SigapSpacing.xs),
                      TextFormField(
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          hintText: l10n.namaLengkapHint,
                          prefixIcon: Icon(Icons.person_outline, size: 20),
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: SigapSpacing.md,
                            vertical: SigapSpacing.sm,
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return l10n.namaKosong;
                          }
                          if (v.trim().length < 2) {
                            return l10n.namaMinimal2;
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: SigapSpacing.md),

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
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: SigapSpacing.md,
                            vertical: SigapSpacing.sm,
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return l10n.emailKosong;
                          }
                          if (!v.contains('@') || !v.contains('.')) {
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
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          hintText: l10n.minimal8Karakter,
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
                          if (v.length < 8) {
                            return l10n.kataSandiMinimal8;
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: SigapSpacing.md),

                // Confirm password field
                SigapCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.konfirmasiKataSandi,
                        style: TextStyle(
                          fontSize: SigapTypography.bodySmall,
                          fontWeight: FontWeight.w600,
                          color: SigapColorScheme.of(context).textSecondary,
                        ),
                      ),
                      SizedBox(height: SigapSpacing.xs),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirm,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _handleRegister(),
                        decoration: InputDecoration(
                          hintText: l10n.ulangiKataSandi,
                          prefixIcon: Icon(Icons.lock_outline, size: 20),
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: SigapSpacing.md,
                            vertical: SigapSpacing.sm,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(
                                () => _obscureConfirm = !_obscureConfirm,
                              );
                            },
                          ),
                        ),
                        validator: (v) {
                          if (v != _passwordController.text) {
                            return l10n.kataSandiTidakCocok;
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: SigapSpacing.lg),

                // Register button
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
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
                            l10n.daftar,
                            style: TextStyle(
                              fontSize: SigapTypography.subtitle,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: SigapSpacing.md),

                // Login link
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      '${l10n.sudahPunyaAkun} ',
                      style: TextStyle(
                        color: SigapColorScheme.of(context).textSecondary,
                        fontSize: SigapTypography.bodyText,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: MinTapTarget(
                        semanticsLabel: l10n.masuk,
                        child: Text(
                          l10n.masuk,
                          style: TextStyle(
                            color: SigapColorScheme.of(context).primary,
                            fontWeight: FontWeight.w600,
                            fontSize: SigapTypography.bodyText,
                          ),
                        ),
                      ),
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
}
