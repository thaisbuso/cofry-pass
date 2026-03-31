import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

import '../../../core/crypto/crypto_service.dart';
import '../../../shared/widgets/cofry_widgets.dart';
import '../../../theme/app_theme.dart';
import '../data/vault_memory_repository.dart';
import '../domain/decrypted_vault_item.dart';
import '../domain/vault_item.dart';

class AddVaultItemPage extends StatefulWidget {
  final VaultItem? existingItem;

  const AddVaultItemPage({super.key, this.existingItem});

  @override
  State<AddVaultItemPage> createState() => _AddVaultItemPageState();
}

class _AddVaultItemPageState extends State<AddVaultItemPage> {
  final _titleController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _urlController = TextEditingController();
  final _notesController = TextEditingController();

  final _repository = VaultMemoryRepository();
  final _uuid = const Uuid();
  final _storage = const FlutterSecureStorage();
  final _cryptoService = CryptoService();

  bool _loading = false;

  bool get isEditing => widget.existingItem != null;

  @override
  void initState() {
    super.initState();
    _loadExistingItemIfNeeded();
  }

  Future<void> _loadExistingItemIfNeeded() async {
    final item = widget.existingItem;
    if (item == null) return;

    final masterPassword = await _storage.read(key: 'master_password');
    if (masterPassword == null) return;

    final decryptedJson = await _cryptoService.decryptText(
      cipherText: item.encryptedData,
      nonce: item.nonce,
      mac: item.mac,
      password: masterPassword,
    );

    final map = jsonDecode(decryptedJson) as Map<String, dynamic>;
    final decryptedItem = DecryptedVaultItem.fromMap(map);

    _titleController.text = item.title;
    _usernameController.text = decryptedItem.username;
    _passwordController.text = decryptedItem.password;
    _urlController.text = decryptedItem.url ?? '';
    _notesController.text = decryptedItem.notes ?? '';
    if (mounted) setState(() {});
  }

  Future<void> _saveItem() async {
    if (_titleController.text.trim().isEmpty ||
        _usernameController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha título, usuário e senha')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final masterPassword = await _storage.read(key: 'master_password');

      if (masterPassword == null || masterPassword.isEmpty) {
        throw Exception('Senha mestra não encontrada');
      }

      final decryptedItem = DecryptedVaultItem(
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        url: _urlController.text.trim().isEmpty
            ? null
            : _urlController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      final jsonPayload = jsonEncode(decryptedItem.toMap());

      final encrypted = await _cryptoService.encryptText(
        plainText: jsonPayload,
        password: masterPassword,
      );

      final item = VaultItem(
        id: widget.existingItem?.id ?? _uuid.v4(),
        title: _titleController.text.trim(),
        encryptedData: encrypted['cipherText']!,
        nonce: encrypted['nonce']!,
        mac: encrypted['mac']!,
      );

      if (isEditing) {
        await _repository.updateItem(item);
      } else {
        await _repository.addItem(item);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar item: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _urlController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(isEditing ? 'Editar item' : 'Novo item'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            children: [
              _FormSection(
                label: 'Identificação',
                children: [
                  CofryTextField(
                    controller: _titleController,
                    label: 'Título',
                    prefixIcon: Icons.label_outline_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _FormSection(
                label: 'Credenciais',
                children: [
                  CofryTextField(
                    controller: _usernameController,
                    label: 'Usuário / Email',
                    prefixIcon: Icons.person_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),
                  CofryTextField(
                    controller: _passwordController,
                    label: 'Senha',
                    prefixIcon: Icons.lock_outline_rounded,
                    obscure: true,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _FormSection(
                label: 'Detalhes opcionais',
                children: [
                  CofryTextField(
                    controller: _urlController,
                    label: 'URL',
                    prefixIcon: Icons.link_rounded,
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 14),
                  CofryTextField(
                    controller: _notesController,
                    label: 'Notas',
                    prefixIcon: Icons.notes_rounded,
                    maxLines: 4,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: isEditing ? 'Salvar alterações' : 'Salvar item',
                loading: _loading,
                onPressed: _saveItem,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  final String label;
  final List<Widget> children;

  const _FormSection({required this.label, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ],
    );
  }
}
