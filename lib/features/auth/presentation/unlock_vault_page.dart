import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/widgets/cofry_widgets.dart';
import '../../../theme/app_theme.dart';
import '../../vault/presentation/vault_home_page.dart';

class UnlockVaultPage extends StatefulWidget {
  const UnlockVaultPage({super.key});

  @override
  State<UnlockVaultPage> createState() => _UnlockVaultPageState();
}

class _UnlockVaultPageState extends State<UnlockVaultPage> {
  final _passwordController = TextEditingController();
  final _storage = const FlutterSecureStorage();

  bool _loading = false;

  String get _userEmail =>
      Supabase.instance.client.auth.currentUser?.email ?? '';

  Future<void> _unlockVault() async {
    setState(() => _loading = true);

    try {
      final savedPassword = await _storage.read(key: 'master_password');
      final typedPassword = _passwordController.text.trim();

      if (savedPassword == typedPassword) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const VaultHomePage()),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Senha mestra incorreta')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao desbloquear cofre: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onForgotPassword() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Esqueceu a senha mestra?',
          style: TextStyle(color: AppColors.onSurface, fontSize: 17),
        ),
        content: const Text(
          'A senha mestra é usada localmente para proteger seu cofre. '
          'Ela não pode ser recuperada remotamente. Se você a esqueceu, '
          'precisará redefinir seu cofre.',
          style: TextStyle(color: AppColors.muted, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Brand mark ──
                  const Center(child: AppLogoMark(size: 44)),
                  const SizedBox(height: 32),

                  // ── Title ──
                  const Text(
                    'Digite sua senha mestra',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Account selector pill ──
                  Center(child: _AccountSelectorPill(email: _userEmail)),
                  const SizedBox(height: 16),

                  // ── Password field ──
                  CofryTextField(
                    controller: _passwordController,
                    label: 'Senha mestra',
                    prefixIcon: Icons.lock_rounded,
                    obscure: true,
                  ),
                  const SizedBox(height: 20),

                  // ── Unlock button ──
                  PrimaryButton(
                    label: 'Desbloquear cofre',
                    loading: _loading,
                    onPressed: _unlockVault,
                  ),
                  const SizedBox(height: 24),

                  // ── Forgot password ──
                  Center(
                    child: TextButton(
                      onPressed: _onForgotPassword,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryLight,
                        textStyle: const TextStyle(fontSize: 13),
                      ),
                      child: const Text('Esqueci minha senha mestra'),
                    ),
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

// ─────────────────────────────────────────────
// Account selector pill (NordPass style)
// ─────────────────────────────────────────────

class _AccountSelectorPill extends StatelessWidget {
  final String email;

  const _AccountSelectorPill({required this.email});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _EmailAvatar(email: email, size: 36),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              email.isNotEmpty ? email : '—',
              style: const TextStyle(
                color: AppColors.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.1,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 6),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.muted,
            size: 20,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Circular avatar with email initial
// ─────────────────────────────────────────────

class _EmailAvatar extends StatelessWidget {
  final String email;
  final double size;

  const _EmailAvatar({required this.email, this.size = 64});

  @override
  Widget build(BuildContext context) {
    final initial = email.isNotEmpty ? email[0].toUpperCase() : '?';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDim],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: AppColors.onPrimary,
            fontSize: size * 0.40,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }
}
