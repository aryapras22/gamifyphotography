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
  bool _obscureConfirmPass = true;

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
      _nameCtrl.text,
      _emailCtrl.text,
      _passCtrl.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authViewModelProvider);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.surfaceWhite,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 56),
                const Icon(Icons.camera_alt_rounded,
                    size: 64, color: AppColors.brandBlue),
                const SizedBox(height: 16),
                Text('Create Account', style: AppTextStyles.heading),
                const SizedBox(height: 8),
                Text('Join and start learning',
                    style: AppTextStyles.body),
                const SizedBox(height: 40),
                Form(
                  key: _formKey,
                  child: Column(children: [
                    TextFormField(
                      controller: _nameCtrl,
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: Validators.name,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: _obscurePass,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePass
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () =>
                              setState(() => _obscurePass = !_obscurePass),
                        ),
                      ),
                      validator: Validators.password,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPassCtrl,
                      obscureText: _obscureConfirmPass,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirmPass
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () =>
                              setState(() => _obscureConfirmPass = !_obscureConfirmPass),
                        ),
                      ),
                      validator: (v) => Validators.confirmPassword(v, _passCtrl.text),
                    ),
                  ]),
                ),
                if (state.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.coralRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(state.errorMessage!,
                        style: AppTextStyles.body
                            .copyWith(color: AppColors.coralRed)),
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
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: state.isLoading
                        ? const SizedBox(
                            height: 20, width: 20,
                            child: CircularProgressIndicator(
                                color: AppColors.surfaceWhite,
                                strokeWidth: 2))
                        : Text('Register', style: AppTextStyles.button),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => context.push('/login'),
                    child: Text("Already have an account? Login",
                        style: AppTextStyles.body
                            .copyWith(color: AppColors.brandBlue)),
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
