import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../view_models/auth_view_model.dart';

class RegisterView extends ConsumerWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (authState.errorMessage != null)
              Text(authState.errorMessage!, style: const TextStyle(color: Colors.red)),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            authState.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      await ref.read(authViewModelProvider.notifier).register(
                            nameController.text,
                            emailController.text,
                            passwordController.text,
                          );
                      if (ref.read(authViewModelProvider).currentUser != null) {
                        context.go('/home');
                      }
                    },
                    child: const Text('Register'),
                  ),
          ],
        ),
      ),
    );
  }
}
