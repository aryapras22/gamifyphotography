import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../core/validators.dart';
import '../../view_models/auth_view_model.dart';
import '../widgets/brutal_widgets.dart';

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
        backgroundColor: AppColors.brandBg,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Camera branding icon card
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.brandAccent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black, width: 2.0),
                        boxShadow: const [
                          BoxShadow(color: Colors.black, offset: Offset(4, 4)),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        size: 32,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Buat Akun Baru',
                      style: AppTextStyles.display.copyWith(fontSize: 26),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Mulai gratis, naik level setiap hari',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.secondaryText,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Inputs Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Nama Lengkap'),
                        _buildField(
                          controller: _nameCtrl,
                          hintText: 'Adi Pratama',
                          keyboardType: TextInputType.name,
                          validator: Validators.name,
                        ),
                        const SizedBox(height: 16),

                        _buildLabel('Email'),
                        _buildField(
                          controller: _emailCtrl,
                          hintText: 'kamu@email.com',
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.email,
                        ),
                        const SizedBox(height: 16),

                        _buildLabel('Kata Sandi'),
                        _buildField(
                          controller: _passCtrl,
                          hintText: 'Minimal 8 karakter',
                          obscure: _obscurePass,
                          onToggleObscure: () => setState(() => _obscurePass = !_obscurePass),
                          validator: Validators.password,
                        ),
                        const SizedBox(height: 16),

                        _buildLabel('Konfirmasi Kata Sandi'),
                        _buildField(
                          controller: _confirmPassCtrl,
                          hintText: 'Ulangi kata sandi',
                          obscure: _obscureConfirm,
                          onToggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          validator: (v) => Validators.confirmPassword(v, _passCtrl.text),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Error Notification Container
                    if (state.errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2), // light red
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black, width: 2.0),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, color: AppColors.brandDanger, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                state.errorMessage!,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.brandDanger,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Submit button
                    BrutalButton(
                      fullWidth: true,
                      onPressed: state.isLoading ? null : _submit,
                      variant: BrutalButtonVariant.primary,
                      child: state.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0),
                            )
                          : const Text('DAFTAR'),
                    ),
                    const SizedBox(height: 24),

                    // Footer Link
                    TextButton(
                      onPressed: () => context.pop(),
                      child: RichText(
                        text: TextSpan(
                          text: 'Sudah punya akun? ',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.secondaryText,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            TextSpan(
                              text: 'Masuk',
                              style: GoogleFonts.inter(
                                color: AppColors.brandPrimary,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: AppColors.secondaryText,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool? obscure,
    VoidCallback? onToggleObscure,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure ?? false,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.brandInk,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: AppColors.disabled),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: obscure != null
            ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: AppColors.secondaryText,
                  size: 20,
                ),
                onPressed: onToggleObscure,
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 2.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.brandDanger, width: 2.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.brandDanger, width: 2.0),
        ),
      ),
      validator: validator,
    );
  }
}
