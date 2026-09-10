import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../widgets/app_textfield.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit(AuthProvider auth) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter email and password');
      return;
    }

    final success = _isSignUp ? await auth.registerWithEmail(email, password) : await auth.signInWithEmail(email, password);

    if (!success && auth.errorMessage != null && mounted) {
      _showError(auth.errorMessage!);
      auth.clearError();
    }
  }

  Future<void> _submitGoogle(AuthProvider auth) async {
    final success = await auth.signInWithGoogle();
    if (!success && auth.errorMessage != null && mounted) {
      _showError(auth.errorMessage!);
      auth.clearError();
    }
  }

  void _showForgotPasswordDialog(AuthProvider auth) {
    final controller = TextEditingController(text: _emailController.text.trim());
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        title: const Text('Reset password', style: TextStyle(color: AppTheme.darkText)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: AppTheme.darkText),
          decoration: const InputDecoration(hintText: 'your@email.com'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              Navigator.of(dialogContext).pop();
              try {
                await auth.sendPasswordReset(controller.text.trim());
                if (mounted) _showError('Reset email sent — check your inbox.');
              } catch (e) {
                if (mounted) _showError(e.toString());
              }
            },
            child: const Text('Send', style: TextStyle(color: AppTheme.lime)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Consumer<AuthProvider>(
            builder: (context, auth, _) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(color: AppTheme.lime, shape: BoxShape.circle),
                      child: const Icon(Icons.fitness_center, color: Colors.black, size: 32),
                    ),
                    const SizedBox(height: 24),
                    Text(_isSignUp ? 'Create your account' : 'Welcome back',
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
                    const SizedBox(height: 6),
                    Text(
                      _isSignUp ? 'Sign up to start tracking your fitness journey.' : 'Sign in to continue.',
                      style: const TextStyle(fontSize: 13, color: AppTheme.darkTextSecondary),
                    ),
                    const SizedBox(height: 32),
                    AppTextField(
                      label: 'Email',
                      hint: 'your@email.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    AppTextField(
                      label: 'Password',
                      hint: 'At least 6 characters',
                      controller: _passwordController,
                      obscureText: true,
                    ),
                    if (!_isSignUp)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => _showForgotPasswordDialog(auth),
                          child: const Text('Forgot password?', style: TextStyle(color: AppTheme.lime, fontSize: 12)),
                        ),
                      ),
                    const SizedBox(height: 12),
                    AppButton(
                      label: _isSignUp ? 'Create Account' : 'Sign In',
                      isLoading: auth.isLoading,
                      onPressed: () => _submit(auth),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('OR', style: TextStyle(color: AppTheme.darkTextSecondary, fontSize: 11)),
                        ),
                        Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
                      ],
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: auth.isLoading ? null : () => _submitGoogle(auth),
                      icon: const Icon(Icons.g_mobiledata, size: 24),
                      label: const Text('Continue with Google'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        foregroundColor: AppTheme.darkText,
                        side: const BorderSide(color: Colors.white24),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Center(
                      child: TextButton(
                        onPressed: () => setState(() => _isSignUp = !_isSignUp),
                        child: Text.rich(
                          TextSpan(
                            text: _isSignUp ? 'Already have an account? ' : 'Don\'t have an account? ',
                            style: const TextStyle(color: AppTheme.darkTextSecondary, fontSize: 13),
                            children: [
                              TextSpan(
                                text: _isSignUp ? 'Sign In' : 'Sign Up',
                                style: const TextStyle(color: AppTheme.lime, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}