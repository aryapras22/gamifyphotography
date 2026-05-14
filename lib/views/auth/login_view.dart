import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../core/validators.dart';
import '../../view_models/auth_view_model.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});
  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(authViewModelProvider.notifier)
        .login(_emailCtrl.text.trim(), _passCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authViewModelProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundGray,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // ── Hero Header ──────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(32, 56, 32, 40),
                  decoration: const BoxDecoration(
                    color: AppColors.brandBlue,
                    borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(36)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.camera_alt_rounded,
                          size: 48, color: AppColors.surfaceWhite),
                      const SizedBox(height: 16),
                      Text(
                        'GamifyPhoto',
                        style: AppTextStyles.display.copyWith(
                          color: AppColors.surfaceWhite,
                          fontSize: 32,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Masuk dan lanjutkan belajar fotografi',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.surfaceWhite
                              .withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Form Card ───────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: AppColors.cardBorder, width: 2),
                      boxShadow: const [
                        BoxShadow(
                            color: AppColors.cardBorder,
                            offset: Offset(0, 6)),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Login',
                              style: AppTextStyles.heading),
                          const SizedBox(height: 24),

                          // Email field
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: const Icon(
                                  Icons.email_outlined,
                                  color: AppColors.brandBlue),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                    color: AppColors.brandBlue, width: 2),
                              ),
                            ),
                            validator: Validators.email,
                          ),
                          const SizedBox(height: 16),

                          // Password field
                          TextFormField(
                            controller: _passCtrl,
                            obscureText: _obscure,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(
                                  Icons.lock_outline_rounded,
                                  color: AppColors.brandBlue),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: AppColors.secondaryText,
                                ),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                    color: AppColors.brandBlue, width: 2),
                              ),
                            ),
                            validator: Validators.password,
                          ),

                          // Error message
                          if (state.errorMessage != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.coralRed
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: AppColors.coralRed
                                        .withValues(alpha: 0.4)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline,
                                      color: AppColors.coralRed,
                                      size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      state.errorMessage!,
                                      style: AppTextStyles.body.copyWith(
                                          color: AppColors.coralRed,
                                          fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),

                          // Login button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: state.isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.brandBlue,
                                foregroundColor: AppColors.surfaceWhite,
                                disabledBackgroundColor:
                                    AppColors.brandBlue.withValues(alpha: 0.5),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                                elevation: 0,
                              ),
                              child: state.isLoading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                          color: AppColors.surfaceWhite,
                                          strokeWidth: 2.5),
                                    )
                                  : Text('MASUK',
                                      style: AppTextStyles.button),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Footer ──────────────────────────────
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: TextButton(
                    onPressed: () => context.push('/register'),
                    child: RichText(
                      text: TextSpan(
                        text: 'Belum punya akun? ',
                        style: AppTextStyles.body
                            .copyWith(color: AppColors.secondaryText),
                        children: [
                          TextSpan(
                            text: 'Daftar',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.brandBlue,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
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
