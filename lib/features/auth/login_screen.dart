import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Login gagal'),
          backgroundColor: SigapColors.perluTindakan,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                          fontSize: SigapTypography.size28,
                          fontWeight: FontWeight.w800,
                          color: SigapColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: SigapSpacing.xs),
                      const Text(
                        'Sistem Informasi Geospasial\n& Penanganan Laporan',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: SigapTypography.size13,
                          color: SigapColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: SigapSpacing.xl * 2),

                // Title
                const Text(
                  'Masuk',
                  style: TextStyle(
                    fontSize: SigapTypography.size24,
                    fontWeight: FontWeight.w700,
                    color: SigapColors.textPrimary,
                  ),
                ),
                const SizedBox(height: SigapSpacing.xs),
                const Text(
                  'Gunakan akun您您 untuk mengakses laporan.',
                  style: TextStyle(
                    fontSize: SigapTypography.size13,
                    color: SigapColors.textSecondary,
                  ),
                ),
                const SizedBox(height: SigapSpacing.xl),

                // Email field
                SigapCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Email',
                        style: TextStyle(
                          fontSize: SigapTypography.size12,
                          fontWeight: FontWeight.w600,
                          color: SigapColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: SigapSpacing.xs),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText: 'email@contoh.com',
                          prefixIcon: Icon(Icons.email_outlined, size: 20),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: SigapSpacing.md,
                            vertical: SigapSpacing.sm,
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Email tidak boleh kosong';
                          }
                          if (!v.contains('@')) {
                            return 'Format email tidak valid';
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
                      const Text(
                        'Kata Sandi',
                        style: TextStyle(
                          fontSize: SigapTypography.size12,
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
                            return 'Kata sandi tidak boleh kosong';
                          }
                          if (v.length < 6) {
                            return 'Kata sandi minimal 6 karakter';
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
                        : const Text(
                            'Masuk',
                            style: TextStyle(
                              fontSize: SigapTypography.size15,
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
                    const Text(
                      'Belum punya akun? ',
                      style: TextStyle(
                        color: SigapColors.textSecondary,
                        fontSize: SigapTypography.size13,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/register'),
                      child: MinTapTarget(
                        semanticsLabel: 'Daftar',
                        child: const Text(
                          'Daftar',
                          style: TextStyle(
                            color: SigapColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: SigapTypography.size13,
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
