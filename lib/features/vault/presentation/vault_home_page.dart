import 'package:flutter/material.dart';

import '../../auth/data/auth_service.dart';
import '../../auth/presentation/login_page.dart';
import '../data/vault_memory_repository.dart';
import '../domain/vault_item.dart';
import 'add_vault_item_page.dart';
import 'vault_item_details_page.dart';

class VaultHomePage extends StatefulWidget {
  const VaultHomePage({super.key});

  @override
  State<VaultHomePage> createState() => _VaultHomePageState();
}

class _VaultHomePageState extends State<VaultHomePage> {
  final _repository = VaultMemoryRepository();
  final _authService = AuthService();

  List<VaultItem> items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final loadedItems = await _repository.getItems();

    if (!mounted) return;

    setState(() {
      items = loadedItems;
      _loading = false;
    });
  }

  Future<void> _goToAddItem() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddVaultItemPage(),
      ),
    );

    if (result == true) {
      await _loadItems();
    }
  }

  Future<void> _goToDetails(VaultItem item) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VaultItemDetailsPage(item: item),
      ),
    );

    if (result == true) {
      await _loadItems();
    }
  }

  Future<void> _logout() async {
    await _authService.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu cofre'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? const Center(
                  child: Text('Nenhum item salvo ainda'),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = items[index];

                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.lock),
                        title: Text(item.title),
                        subtitle: const Text('Dados protegidos'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _goToDetails(item),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAddItem,
        child: const Icon(Icons.add),
      ),
    );
  }
}