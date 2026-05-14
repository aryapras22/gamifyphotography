import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../core/validators.dart';
import '../../view_models/auth_view_model.dart';

class RegisterView extends ConsumerStatefulWidget {
  const RegisterView({super.key});
  @override
  ConsumerState<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authViewModelProvider.notifier).register(
          _nameCtrl.text.trim(),
          _emailCtrl.text.trim(),
          _passCtrl.text,
        );
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
                  padding: const EdgeInsets.fromLTRB(32, 48, 32, 36),
                  decoration: const BoxDecoration(
                    color: AppColors.brandBlue,
                    borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(36)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: const Icon(Icons.arrow_back_rounded,
                            color: AppColors.surfaceWhite, size: 28),
                      ),
                      const SizedBox(height: 20),
                      const Icon(Icons.camera_alt_rounded,
                          size: 44, color: AppColors.surfaceWhite),
                      const SizedBox(height: 12),
                      Text(
                        'Daftar Akun Baru',
                        style: AppTextStyles.display.copyWith(
                          color: AppColors.surfaceWhite,
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Bergabung dan mulai perjalanan fotografi',
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
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
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
                          Text('Isi Data Diri',
                              style: AppTextStyles.heading),
                          const SizedBox(height: 20),

                          _buildField(
                            controller: _nameCtrl,
                            label: 'Nama Lengkap',
                            icon: Icons.person_outline_rounded,
                            keyboardType: TextInputType.name,
                            validator: Validators.name,
                          ),
                          const SizedBox(height: 14),
                          _buildField(
                            controller: _emailCtrl,
                            label: 'Email',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: Validators.email,
                          ),
                          const SizedBox(height: 14),
                          _buildField(
                            controller: _passCtrl,
                            label: 'Password',
                            icon: Icons.lock_outline_rounded,
                            obscure: _obscurePass,
                            onToggleObscure: () =>
                                setState(() => _obscurePass = !_obscurePass),
                            validator: Validators.password,
                          ),
                          const SizedBox(height: 14),
                          _buildField(
                            controller: _confirmPassCtrl,
                            label: 'Konfirmasi Password',
                            icon: Icons.lock_outline_rounded,
                            obscure: _obscureConfirm,
                            onToggleObscure: () => setState(
                                () => _obscureConfirm = !_obscureConfirm),
                            validator: (v) =>
                                Validators.confirmPassword(v, _passCtrl.text),
                          ),

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
                                      color: AppColors.coralRed, size: 18),
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
                                  : Text('DAFTAR',
                                      style: AppTextStyles.button),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: TextButton(
                    onPressed: () => context.pop(),
                    child: RichText(
                      text: TextSpan(
                        text: 'Sudah punya akun? ',
                        style: AppTextStyles.body
                            .copyWith(color: AppColors.secondaryText),
                        children: [
                          TextSpan(
                            text: 'Masuk',
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

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool? obscure,
    VoidCallback? onToggleObscure,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure ?? false,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.brandBlue),
        suffixIcon: obscure != null
            ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.secondaryText,
                ),
                onPressed: onToggleObscure,
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.brandBlue, width: 2),
        ),
      ),
      validator: validator,
    );
  }
}
