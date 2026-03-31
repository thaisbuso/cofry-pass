import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../shared/widgets/cofry_widgets.dart';
import '../../../theme/app_theme.dart';
import '../../vault/presentation/vault_home_page.dart';

class MasterPasswordPage extends StatefulWidget {
  const MasterPasswordPage({super.key});

  @override
  State<MasterPasswordPage> createState() => _MasterPasswordPageState();
}

class _MasterPasswordPageState extends State<MasterPasswordPage> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _storage = const FlutterSecureStorage();

  bool _loading = false;

  Future<void> _saveMasterPassword() async {
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (password.isEmpty || confirm.isEmpty) {
      _snack('Preencha os dois campos');
      return;
    }
    if (password != confirm) {
      _snack('As senhas não coincidem');
      return;
    }
    if (password.length < 6) {
      _snack('Use pelo menos 6 caracteres');
      return;
    }

    setState(() => _loading = true);

    try {
      await _storage.write(key: 'master_password', value: password);
      await _storage.write(key: 'has_master_password', value: 'true');

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const VaultHomePage()),
      );
    } catch (e) {
      _snack('Erro ao salvar senha mestra: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
                    title: 'Criar senha mestra',
                    subtitle:
                        'Esta senha criptografa todo o seu cofre. Guarde-a com cuidado — não é possível recuperá-la.',
                  ),
                  const SizedBox(height: 36),
                  CofryTextField(
                    controller: _passwordController,
                    label: 'Senha mestra',
                    prefixIcon: Icons.shield_rounded,
                    obscure: true,
                  ),
                  const SizedBox(height: 14),
                  CofryTextField(
                    controller: _confirmController,
                    label: 'Confirmar senha mestra',
                    prefixIcon: Icons.shield_outlined,
                    obscure: true,
                  ),
                  const SizedBox(height: 12),
                  _SecurityHint(),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Definir senha mestra',
                    loading: _loading,
                    onPressed: _saveMasterPassword,
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

class _SecurityHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withAlpha(40)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 15,
            color: AppColors.primaryLight,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Use no mínimo 6 caracteres combinando letras, números e símbolos.',
              style: TextStyle(
                color: AppColors.primaryLight,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
