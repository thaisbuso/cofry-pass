import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/crypto/crypto_service.dart';
import '../../../shared/widgets/cofry_widgets.dart';
import '../../../theme/app_theme.dart';
import '../data/vault_memory_repository.dart';
import '../domain/decrypted_vault_item.dart';
import '../domain/vault_item.dart';
import 'add_vault_item_page.dart';

class VaultItemDetailsPage extends StatefulWidget {
  final VaultItem item;

  const VaultItemDetailsPage({
    super.key,
    required this.item,
  });

  @override
  State<VaultItemDetailsPage> createState() => _VaultItemDetailsPageState();
}

class _VaultItemDetailsPageState extends State<VaultItemDetailsPage> {
  final _repository = VaultMemoryRepository();
  final _storage = const FlutterSecureStorage();
  final _cryptoService = CryptoService();

  DecryptedVaultItem? decryptedItem;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _decryptItem();
  }

  Future<void> _decryptItem() async {
    try {
      final masterPassword = await _storage.read(key: 'master_password');

      if (masterPassword == null) {
        throw Exception('Senha mestra não encontrada');
      }

      final decryptedJson = await _cryptoService.decryptText(
        cipherText: widget.item.encryptedData,
        nonce: widget.item.nonce,
        mac: widget.item.mac,
        password: masterPassword,
      );

      final map = jsonDecode(decryptedJson) as Map<String, dynamic>;

      setState(() {
        decryptedItem = DecryptedVaultItem.fromMap(map);
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao descriptografar item: $e')),
      );
    }
  }

  Future<void> _editItem() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddVaultItemPage(existingItem: widget.item),
      ),
    );
    if (result == true && mounted) Navigator.pop(context, true);
  }

  Future<void> _deleteItem() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir item'),
        content: Text(
          'Tem certeza que deseja excluir "${widget.item.title}"? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              minimumSize: const Size(100, 42),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _repository.deleteItem(widget.item.id);
      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(item.title),
        actions: [
          IconButton(
            onPressed: _editItem,
            icon: const Icon(Icons.edit_outlined, size: 20),
            tooltip: 'Editar',
          ),
          IconButton(
            onPressed: _deleteItem,
            icon: const Icon(
              Icons.delete_outline_rounded,
              size: 20,
              color: AppColors.error,
            ),
            tooltip: 'Excluir',
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : decryptedItem == null
              ? _buildError()
              : _buildContent(decryptedItem!),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 40, color: AppColors.error),
          const SizedBox(height: 12),
          const Text(
            'Não foi possível carregar este item',
            style: TextStyle(color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(DecryptedVaultItem data) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          children: [
            _buildItemHeader(),
            const SizedBox(height: 24),
            _sectionLabel('Credenciais'),
            const SizedBox(height: 10),
            DetailFieldCard(
              label: 'Usuário / Email',
              value: data.username,
              icon: Icons.person_outline_rounded,
              canCopy: true,
            ),
            const SizedBox(height: 10),
            DetailFieldCard(
              label: 'Senha',
              value: data.password,
              icon: Icons.lock_outline_rounded,
              canObscure: true,
              canCopy: true,
            ),
            if ((data.url ?? '').isNotEmpty) ...[
              const SizedBox(height: 24),
              _sectionLabel('Site'),
              const SizedBox(height: 10),
              DetailFieldCard(
                label: 'URL',
                value: data.url ?? '',
                icon: Icons.link_rounded,
                canCopy: true,
              ),
            ],
            if ((data.notes ?? '').isNotEmpty) ...[
              const SizedBox(height: 24),
              _sectionLabel('Notas'),
              const SizedBox(height: 10),
              DetailFieldCard(
                label: 'Notas',
                value: data.notes ?? '',
                icon: Icons.notes_rounded,
              ),
            ],
            const SizedBox(height: 32),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _editItem,
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('Editar item'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemHeader() {
    return Row(
      children: [
        VaultItemAvatar(title: widget.item.title, size: 52),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.item.title,
                style: const TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Dados criptografados',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: AppColors.muted,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }
}
