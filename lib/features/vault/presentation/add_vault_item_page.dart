import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

import '../../../core/crypto/crypto_service.dart';
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
        url: _urlController.text.trim().isEmpty ? null : _urlController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar item: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
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
        title: Text(isEditing ? 'Editar item' : 'Novo item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: ListView(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Usuário / Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _urlController,
                  decoration: const InputDecoration(
                    labelText: 'URL',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _notesController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Notas',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _saveItem,
                    child: Text(
                      _loading
                          ? 'Salvando...'
                          : isEditing
                              ? 'Salvar alterações'
                              : 'Salvar',
                    ),
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