import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../shared/widgets/cofry_widgets.dart';
import '../../../theme/app_theme.dart';
import '../data/auth_service.dart';
import 'master_password_page.dart';
import 'signup_page.dart';
import 'unlock_vault_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final authService = AuthService();
  final storage = const FlutterSecureStorage();

  bool loading = false;

  Future<void> login() async {
    setState(() => loading = true);

    try {
      await authService.signIn(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final hasMasterPassword = await storage.read(key: 'has_master_password');

      if (!mounted) return;

      if (hasMasterPassword == 'true') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const UnlockVaultPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MasterPasswordPage()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro no login: $e')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AuthHeader(
                    title: 'Cofry Pass',
                    subtitle: 'Acesse sua conta com segurança.',
                    horizontal: true,
                  ),
                  const SizedBox(height: 40),
                  CofryTextField(
                    controller: emailController,
                    label: 'Email',
                    prefixIcon: Icons.alternate_email_rounded,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  CofryTextField(
                    controller: passwordController,
                    label: 'Senha',
                    prefixIcon: Icons.lock_outline_rounded,
                    obscure: true,
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    label: 'Entrar',
                    loading: loading,
                    onPressed: login,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Não tem uma conta?',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SignUpPage()),
                        ),
                        child: const Text('Criar conta'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
