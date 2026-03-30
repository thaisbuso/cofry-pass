import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/crypto/crypto_service.dart';
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
      setState(() {
        loading = false;
      });

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

    if (result == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _deleteItem() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir item'),
          content: const Text('Tem certeza que deseja excluir este item?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _repository.deleteItem(widget.item.id);

      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  Widget _buildField(String label, String value) {
    return Card(
      child: ListTile(
        title: Text(label),
        subtitle: Text(value.isEmpty ? '-' : value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
        actions: [
          IconButton(
            onPressed: _editItem,
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: _deleteItem,
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : decryptedItem == null
              ? const Center(child: Text('Não foi possível carregar este item'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildField('Título', item.title),
                    _buildField('Usuário / Email', decryptedItem!.username),
                    _buildField('Senha', decryptedItem!.password),
                    _buildField('URL', decryptedItem!.url ?? ''),
                    _buildField('Notas', decryptedItem!.notes ?? ''),
                  ],
                ),
    );
  }
}