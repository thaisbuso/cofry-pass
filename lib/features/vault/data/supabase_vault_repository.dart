import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/vault_item.dart';
import '../domain/vault_repository.dart';

class SupabaseVaultRepository implements VaultRepository {
  final SupabaseClient _client = Supabase.instance.client;

  String get _userId => _client.auth.currentUser!.id;

  @override
  Future<List<VaultItem>> getItems() async {
    final rows = await _client
        .from('vault_items')
        .select()
        .eq('user_id', _userId)
        .order('created_at', ascending: true);

    return rows.map(_fromRow).toList();
  }

  @override
  Future<void> addItem(VaultItem item) async {
    await _client.from('vault_items').insert(_toRow(item));
  }

  @override
  Future<void> updateItem(VaultItem item) async {
    await _client
        .from('vault_items')
        .update(_toRow(item)..remove('user_id')..remove('created_at'))
        .eq('id', item.id)
        .eq('user_id', _userId);
  }

  @override
  Future<void> deleteItem(String id) async {
    await _client
        .from('vault_items')
        .delete()
        .eq('id', id)
        .eq('user_id', _userId);
  }

  Map<String, dynamic> _toRow(VaultItem item) {
    return {
      'id': item.id,
      'user_id': _userId,
      'title': item.title,
      'encrypted_data': item.encryptedData,
      'nonce': item.nonce,
      'mac': item.mac,
    };
  }

  VaultItem _fromRow(Map<String, dynamic> row) {
    return VaultItem(
      id: row['id'] as String,
      title: row['title'] as String,
      encryptedData: row['encrypted_data'] as String,
      nonce: row['nonce'] as String,
      mac: row['mac'] as String,
    );
  }
}
