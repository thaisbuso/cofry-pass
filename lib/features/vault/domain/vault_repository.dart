import 'vault_item.dart';

abstract class VaultRepository {
  Future<List<VaultItem>> getItems();
  Future<void> addItem(VaultItem item);
  Future<void> updateItem(VaultItem item);
  Future<void> deleteItem(String id);
}
