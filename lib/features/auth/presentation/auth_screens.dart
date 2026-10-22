import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/config/app_constants.dart';
import '../domain/auth_controller.dart';
import '../data/auth_repository.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.menu_book_rounded, size: 42, color: Colors.white),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(AppConstants.appName, style: AppTextStyles.heading2),
              const SizedBox(height: AppSpacing.xs),
              Text(
                AppConstants.appSlogan,
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 1),
              // Illustration placeholder
              Container(
                height: 200,
                margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.auto_stories_rounded,
                        size: 80, color: AppColors.primary.withValues(alpha: 0.4)),
                    const Positioned(
                      bottom: 20, right: 30,
                      child: Icon(Icons.local_cafe_rounded,
                          size: 30, color: AppColors.primaryDark),
                    ),
                    const Positioned(
                      top: 20, right: 20,
                      child: Icon(Icons.eco_rounded, size: 24, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              Text(
                'Mulai Ceritakan Harimu.',
                style: AppTextStyles.heading2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Atur aktivitas, catat pengalaman,\ndan bangun kebiasaan positif\ndalam satu aplikasi.',
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 2),
              // CTA Buttons
              AppButton(
                label: 'Buat Akun',
                onPressed: () => context.go(AppConstants.routeRegister),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: 'Masuk',
                variant: AppButtonVariant.outlined,
                onPressed: () => context.go(AppConstants.routeLogin),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (AppConstants.isDemoMode)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.accentYellow,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.info_outline, size: 14, color: AppColors.textPrimary),
                      const SizedBox(width: 6),
                      Text('Mode Demo Aktif', style: AppTextStyles.captionMedium.copyWith(color: AppColors.textPrimary)),
                    ],
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── LOGIN ───────────────────────────────────────────────────────────────────

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref
        .read(authControllerProvider.notifier)
        .login(_emailCtrl.text.trim(), _passwordCtrl.text);
    if (ok && mounted) {
      context.go(AppConstants.routeHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final isLoading = state is AuthLoading;
    final errorMsg = state is AuthError ? state.error.message : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: AppSpacing.xl),
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                  child: const Icon(Icons.menu_book_rounded, size: 34, color: Colors.white),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(AppConstants.appName, style: AppTextStyles.heading3),
                const SizedBox(height: AppSpacing.xl),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Selamat Datang Kembali', style: AppTextStyles.heading2),
                ),
                const SizedBox(height: AppSpacing.xs),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Masuk untuk melanjutkan perjalananmu.',
                      style: AppTextStyles.bodySmall),
                ),
                const SizedBox(height: AppSpacing.xl),
                if (errorMsg != null) ...[
                  _ErrorBanner(message: errorMsg, onDismiss: () => ref.read(authControllerProvider.notifier).clearError()),
                  const SizedBox(height: AppSpacing.md),
                ],
                AppTextField(
                  controller: _emailCtrl,
                  label: 'Email',
                  hint: 'nama@contoh.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: _validateEmail,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _passwordCtrl,
                  label: 'Kata Sandi',
                  hint: 'Masukkan kata sandi',
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  onSuffixTap: () => setState(() => _obscurePassword = !_obscurePassword),
                  validator: (v) => v == null || v.isEmpty ? 'Kata sandi wajib diisi.' : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.go(AppConstants.routeForgotPassword),
                    child: Text('Lupa Kata Sandi?',
                        style: AppTextStyles.bodySmallMedium.copyWith(color: AppColors.primary)),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: isLoading ? 'Memproses...' : 'Masuk',
                  onPressed: isLoading ? null : _submit,
                  isLoading: isLoading,
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Belum punya akun? ', style: AppTextStyles.bodySmall),
                    GestureDetector(
                      onTap: () => context.go(AppConstants.routeRegister),
                      child: Text('Daftar',
                          style: AppTextStyles.bodySmallMedium.copyWith(color: AppColors.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _validateEmail(String? v) {
    if (v == null || v.isEmpty) return 'Email wajib diisi.';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(v)) return 'Format email belum valid.';
    return null;
  }
}

// ─── REGISTER ────────────────────────────────────────────────────────────────

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreed = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Kamu harus menyetujui syarat & ketentuan.'),
      ));
      return;
    }
    final ok = await ref.read(authControllerProvider.notifier).register(
        _nameCtrl.text.trim(), _emailCtrl.text.trim(), _passwordCtrl.text);
    if (ok && mounted) context.go(AppConstants.routeHome);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final isLoading = state is AuthLoading;
    final errorMsg = state is AuthError ? state.error.message : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    IconButton(onPressed: () => context.go(AppConstants.routeWelcome),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20)),
                    const Spacer(),
                    Center(
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.menu_book_rounded, size: 22, color: Colors.white),
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 40),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Center(child: Text(AppConstants.appName, style: AppTextStyles.heading4)),
                const SizedBox(height: AppSpacing.lg),
                Text('Buat Akun My Journal', style: AppTextStyles.heading2),
                const SizedBox(height: AppSpacing.xs),
                Text('Bergabunglah dan mulai perjalanan menuju versi terbaik dirimu.',
                    style: AppTextStyles.bodySmall),
                const SizedBox(height: AppSpacing.lg),
                if (errorMsg != null) ...[
                  _ErrorBanner(message: errorMsg, onDismiss: () => ref.read(authControllerProvider.notifier).clearError()),
                  const SizedBox(height: AppSpacing.md),
                ],
                AppTextField(
                  controller: _nameCtrl,
                  label: 'Nama Lengkap',
                  hint: 'Contoh: Sarah Aulia',
                  prefixIcon: Icons.person_outline,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Nama lengkap wajib diisi.' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _emailCtrl,
                  label: 'Email',
                  hint: 'nama@contoh.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: _validateEmail,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _passwordCtrl,
                  label: 'Kata Sandi',
                  hint: 'Minimal 8 karakter',
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  onSuffixTap: () => setState(() => _obscurePassword = !_obscurePassword),
                  validator: _validatePassword,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _confirmCtrl,
                  label: 'Konfirmasi Kata Sandi',
                  hint: 'Ulangi kata sandi',
                  obscureText: _obscureConfirm,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  onSuffixTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  validator: (v) => v != _passwordCtrl.text ? 'Konfirmasi kata sandi tidak cocok.' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                _PasswordHintBox(password: _passwordCtrl.text),
                const SizedBox(height: AppSpacing.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _agreed,
                      onChanged: (v) => setState(() => _agreed = v ?? false),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: RichText(
                          text: TextSpan(
                            style: AppTextStyles.bodySmall,
                            children: [
                              const TextSpan(text: 'Saya menyetujui '),
                              TextSpan(text: 'Kebijakan Privasi', style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                              const TextSpan(text: ' dan '),
                              TextSpan(text: 'Syarat & Ketentuan', style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                              const TextSpan(text: ' My Journal.'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: isLoading ? 'Membuat Akun...' : 'Buat Akun',
                  onPressed: (isLoading || !_agreed) ? null : _submit,
                  isLoading: isLoading,
                ),
                const SizedBox(height: AppSpacing.md),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Sudah punya akun? ', style: AppTextStyles.bodySmall),
                      GestureDetector(
                        onTap: () => context.go(AppConstants.routeLogin),
                        child: Text('Masuk', style: AppTextStyles.bodySmallMedium.copyWith(color: AppColors.primary)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _validateEmail(String? v) {
    if (v == null || v.isEmpty) return 'Email wajib diisi.';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) return 'Format email belum valid.';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Kata sandi wajib diisi.';
    if (v.length < 8) return 'Kata sandi minimal 8 karakter.';
    if (!RegExp(r'[A-Z]').hasMatch(v) || !RegExp(r'[a-z]').hasMatch(v)) {
      return 'Kata sandi belum memenuhi persyaratan.';
    }
    return null;
  }
}

// ─── FORGOT PASSWORD ─────────────────────────────────────────────────────────

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _sent = false;

  @override
  void dispose() { _emailCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(authControllerProvider.notifier).forgotPassword(_emailCtrl.text.trim());
    if (ok && mounted) setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final isLoading = state is AuthLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.go(AppConstants.routeLogin),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: _sent ? _SuccessView() : Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                    child: const Icon(Icons.menu_book_rounded, size: 30, color: Colors.white),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Center(child: Text(AppConstants.appName, style: AppTextStyles.heading4)),
                const SizedBox(height: AppSpacing.xl),
                Text('Lupa Kata Sandi?', style: AppTextStyles.heading2),
                const SizedBox(height: AppSpacing.sm),
                Text('Masukkan email yang kamu gunakan untuk akun My Journal. Kami akan membantu proses pemulihan kata sandi.',
                    style: AppTextStyles.bodySmall),
                const SizedBox(height: AppSpacing.xl),
                AppTextField(
                  controller: _emailCtrl,
                  label: 'Email',
                  hint: 'nama@contoh.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email wajib diisi.';
                    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) return 'Format email belum valid.';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton(label: isLoading ? 'Mengirim...' : 'Kirim Tautan Reset', onPressed: isLoading ? null : _submit, isLoading: isLoading),
                const SizedBox(height: AppSpacing.md),
                Center(
                  child: TextButton(
                    onPressed: () => context.go(AppConstants.routeLogin),
                    child: Text('Kembali ke Login', style: AppTextStyles.bodySmallMedium.copyWith(color: AppColors.primary)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120, height: 120,
            decoration: BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
            child: const Icon(Icons.mark_email_read_outlined, size: 60, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Tautan Pemulihan Terkirim', style: AppTextStyles.heading3, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          Text('Jika email terdaftar, instruksi pemulihan kata sandi akan dikirim sesuai mekanisme yang tersedia.',
              style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xl),
          AppButton(label: 'Kembali ke Login', onPressed: () => context.go(AppConstants.routeLogin)),
        ],
      ),
    );
  }
}

// ─── SHARED WIDGETS ───────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;
  const _ErrorBanner({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: const Color(0xFFFBEAEA),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: AppTextStyles.bodySmall.copyWith(color: AppColors.error))),
          GestureDetector(onTap: onDismiss, child: const Icon(Icons.close, color: AppColors.error, size: 16)),
        ],
      ),
    );
  }
}

class _PasswordHintBox extends StatelessWidget {
  final String password;
  const _PasswordHintBox({required this.password});

  @override
  Widget build(BuildContext context) {
    final hasLength = password.length >= 8;
    final hasUpper = RegExp(r'[A-Z]').hasMatch(password);
    final hasLower = RegExp(r'[a-z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Gunakan kata sandi yang kuat dan mudah kamu ingat', style: AppTextStyles.caption),
          const SizedBox(height: AppSpacing.sm),
          _HintRow(label: 'Minimal 8 karakter', met: hasLength),
          _HintRow(label: 'Mengandung huruf besar dan kecil', met: hasUpper && hasLower),
          _HintRow(label: 'Mengandung angka atau simbol', met: hasNumber),
        ],
      ),
    );
  }
}

class _HintRow extends StatelessWidget {
  final String label;
  final bool met;
  const _HintRow({required this.label, required this.met});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(met ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              size: 14, color: met ? AppColors.primary : AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.caption.copyWith(
              color: met ? AppColors.primaryDark : AppColors.textSecondary)),
        ],
      ),
    );
  }
}
