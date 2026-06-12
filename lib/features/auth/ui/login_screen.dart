import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/auth_controller.dart';
import '../../../core/theme/app_theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ref.read(authControllerProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    ref.listen<AsyncValue<void>>(authControllerProvider, (_, state) {
      if (state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.error.toString()),
            backgroundColor: AppTheme.levelNegatif,
          ),
        );
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.darkBg, Color(0xFF161826)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Minimalist Logo
                    Center(
                      child: Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [AppTheme.primary, AppTheme.accent],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.3),
                              blurRadius: 20,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                        child: const Icon(
                          Icons.book_rounded,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Very Simple Diary',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Votre esprit, résumé simplement.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    // Google Login Button
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        side: const BorderSide(color: Color(0xFF2E3047)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: authState.isLoading ? null : () {
                        // Mock Google Sign-In or Firebase Auth logic
                      },
                      icon: const Icon(Icons.g_mobiledata, size: 28, color: Colors.white),
                      label: const Text(
                        'Se connecter avec Google',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    const Row(
                      children: [
                        Expanded(child: Divider(color: Color(0xFF2E3047))),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text('OU', style: TextStyle(color: AppTheme.textSecondary)),
                        ),
                        Expanded(child: Divider(color: Color(0xFF2E3047))),
                      ],
                    ),
                    
                    const SizedBox(height: 24),

                    // Form Fields
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF2E3047)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF2E3047)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Veuillez saisir votre email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Mot de passe',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF2E3047)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF2E3047)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) return 'Le mot de passe doit faire au moins 6 caractères';
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    ElevatedButton(
                      onPressed: authState.isLoading ? null : _submit,
                      child: authState.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Valider'),
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
}
