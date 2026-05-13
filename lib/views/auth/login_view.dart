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
    await ref.read(authViewModelProvider.notifier)
        .login(_emailCtrl.text, _passCtrl.text);
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
                Text('Welcome Back', style: AppTextStyles.heading),
                const SizedBox(height: 8),
                Text('Sign in to continue learning',
                    style: AppTextStyles.body),
                const SizedBox(height: 40),
                Form(
                  key: _formKey,
                  child: Column(children: [
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          icon: Icon(_obscure
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: Validators.password,
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
                        : Text('Login', style: AppTextStyles.button),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => context.push('/register'),
                    child: Text("Don't have an account? Register",
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
